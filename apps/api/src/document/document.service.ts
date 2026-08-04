import { BadRequestException, ConflictException, Inject, Injectable, Logger, NotFoundException, Optional } from "@nestjs/common";
import { DocumentAsset, DocumentPurpose, DocumentStatus, PrismaService } from "@pauti-pustak/backend-database";
import { randomUUID } from "crypto";
import { OBJECT_STORAGE_PORT, ObjectStoragePort } from "./ports/object-storage.port";
import { ConfirmUploadDto } from "./dto/confirm-upload.dto";
import { ReplaceDocumentDto } from "./dto/replace-document.dto";

const ALLOWED_MIME_TYPES = [
  "application/pdf",
  "image/jpeg",
  "image/png",
  "image/webp",
];

const MAX_FILE_SIZE_BYTES = 25 * 1024 * 1024; // 25 MB

@Injectable()
export class DocumentService {
  private readonly logger = new Logger(DocumentService.name);

  constructor(
    @Inject(PrismaService) private readonly prisma: PrismaService,
    @Optional() @Inject(OBJECT_STORAGE_PORT) private readonly storage?: ObjectStoragePort,
  ) {}

  async createPresignedUpload(
    organizationId: string,
    userId: string,
    params: { filename: string; contentType: string; purpose: DocumentPurpose; sha256?: string },
  ) {
    if (!ALLOWED_MIME_TYPES.includes(params.contentType)) {
      throw new BadRequestException(`Unsupported MIME type: ${params.contentType}`);
    }

    // Checksum duplicate detection
    if (params.sha256) {
      const duplicate = await this.prisma.documentAsset.findFirst({
        where: {
          organizationId,
          sha256: params.sha256,
          status: DocumentStatus.AVAILABLE,
        },
      });

      if (duplicate) {
        this.logger.log(`Duplicate checksum match found for ${params.sha256} (${duplicate.id})`);
        return {
          documentId: duplicate.id,
          objectKey: duplicate.objectKey,
          uploadUrl: null,
          isDuplicate: true,
          expiresInSeconds: 0,
        };
      }
    }

    const documentId = randomUUID();
    const objectKey = `orgs/${organizationId}/${params.purpose.toLowerCase()}/${documentId}-${params.filename}`;

    const uploadUrl = this.storage
      ? await this.storage.getUploadUrl(objectKey, params.contentType, 900)
      : `https://s3.ap-south-1.amazonaws.com/pauti-pustak-storage/${objectKey}?X-Amz-Expires=900`;

    const doc = await this.prisma.documentAsset.create({
      data: {
        id: documentId,
        organizationId,
        ownerUserId: userId,
        purpose: params.purpose,
        objectKey,
        originalFileName: params.filename,
        mimeType: params.contentType,
        fileSizeBytes: BigInt(0),
        sha256: params.sha256 ?? "pending_sha256",
        status: DocumentStatus.UPLOAD_PENDING,
      },
    });

    return {
      documentId: doc.id,
      objectKey,
      uploadUrl,
      isDuplicate: false,
      expiresInSeconds: 900,
    };
  }

  async confirmUpload(organizationId: string, documentId: string, dto: ConfirmUploadDto) {
    const doc = await this.requireOwnedDocument(organizationId, documentId);

    const sizeBytes = BigInt(dto.fileSizeBytes);
    if (sizeBytes > BigInt(MAX_FILE_SIZE_BYTES)) {
      throw new BadRequestException(`File size exceeds max limit of 25MB`);
    }

    const updated = await this.prisma.documentAsset.update({
      where: { id: documentId },
      data: {
        fileSizeBytes: sizeBytes,
        sha256: dto.sha256,
        status: DocumentStatus.AVAILABLE,
      },
    });

    return {
      documentId: updated.id,
      status: updated.status,
      fileSizeBytes: updated.fileSizeBytes.toString(),
      sha256: updated.sha256,
    };
  }

  async getPresignedDownloadUrl(organizationId: string, documentId: string) {
    const doc = await this.requireOwnedDocument(organizationId, documentId);

    if (doc.status === DocumentStatus.REJECTED || doc.status === DocumentStatus.DELETED) {
      throw new NotFoundException("Document not found or unavailable");
    }

    const downloadUrl = this.storage
      ? await this.storage.getDownloadUrl(doc.objectKey, 900)
      : `https://s3.ap-south-1.amazonaws.com/pauti-pustak-storage/${doc.objectKey}?X-Amz-Expires=900`;

    return {
      documentId: doc.id,
      filename: doc.originalFileName,
      contentType: doc.mimeType,
      downloadUrl,
      expiresInSeconds: 900,
    };
  }

  async previewDocument(organizationId: string, documentId: string) {
    const doc = await this.requireOwnedDocument(organizationId, documentId);

    const isImage = doc.mimeType.startsWith("image/");
    const isPdf = doc.mimeType === "application/pdf";

    const downloadUrl = this.storage
      ? await this.storage.getDownloadUrl(doc.objectKey, 900)
      : `https://s3.ap-south-1.amazonaws.com/pauti-pustak-storage/${doc.objectKey}?X-Amz-Expires=900`;

    return {
      documentId: doc.id,
      filename: doc.originalFileName,
      mimeType: doc.mimeType,
      fileSizeBytes: doc.fileSizeBytes.toString(),
      isImage,
      isPdf,
      previewUrl: downloadUrl,
      status: doc.status,
    };
  }

  async replaceDocument(organizationId: string, documentId: string, userId: string, dto: ReplaceDocumentDto) {
    const existing = await this.requireOwnedDocument(organizationId, documentId);

    if (existing.status === DocumentStatus.DELETED) {
      throw new ConflictException("Cannot replace a deleted document");
    }

    // Mark previous version as DELETED
    await this.prisma.documentAsset.update({
      where: { id: documentId },
      data: { status: DocumentStatus.DELETED },
    });

    // Create new version
    const newDocResult = await this.createPresignedUpload(organizationId, userId, {
      filename: dto.filename,
      contentType: dto.contentType,
      purpose: existing.purpose,
    });

    return {
      previousDocumentId: documentId,
      newDocumentId: newDocResult.documentId,
      uploadUrl: newDocResult.uploadUrl,
      replacementReason: dto.reason,
    };
  }

  async deleteDocument(organizationId: string, documentId: string) {
    const doc = await this.requireOwnedDocument(organizationId, documentId);

    await this.prisma.documentAsset.update({
      where: { id: documentId },
      data: { status: DocumentStatus.DELETED },
    });

    if (this.storage) {
      await this.storage.deleteObject(doc.objectKey);
    }

    return {
      documentId,
      status: "DELETED_AND_ARCHIVED",
    };
  }

  async getDocumentStats(organizationId: string) {
    const docs = await this.prisma.documentAsset.findMany({
      where: { organizationId },
      select: { purpose: true, fileSizeBytes: true, status: true },
    });

    let totalSizeBytes = BigInt(0);
    const purposeCountMap: Record<string, number> = {};

    for (const d of docs) {
      if (d.status === DocumentStatus.AVAILABLE) {
        totalSizeBytes += d.fileSizeBytes;
        purposeCountMap[d.purpose] = (purposeCountMap[d.purpose] ?? 0) + 1;
      }
    }

    return {
      totalDocumentsCount: docs.length,
      availableDocumentsCount: docs.filter((d) => d.status === DocumentStatus.AVAILABLE).length,
      totalStorageBytes: totalSizeBytes.toString(),
      documentsByPurpose: purposeCountMap,
    };
  }

  private async requireOwnedDocument(organizationId: string, documentId: string): Promise<DocumentAsset> {
    const doc = await this.prisma.documentAsset.findFirst({
      where: { id: documentId, organizationId },
    });

    if (!doc) {
      throw new NotFoundException("Document asset not found");
    }

    return doc;
  }
}
