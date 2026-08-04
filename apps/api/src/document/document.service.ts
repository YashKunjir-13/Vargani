import { BadRequestException, Injectable, NotFoundException } from "@nestjs/common";
import { DocumentAsset, DocumentPurpose, DocumentStatus, PrismaService } from "@pauti-pustak/backend-database";
import { randomUUID } from "crypto";

@Injectable()
export class DocumentService {
  constructor(private readonly prisma: PrismaService) {}

  async createPresignedUpload(
    organizationId: string,
    userId: string,
    params: { filename: string; contentType: string; purpose: DocumentPurpose },
  ) {
    const allowedMimeTypes = [
      "application/pdf",
      "image/jpeg",
      "image/png",
      "image/webp",
    ];

    if (!allowedMimeTypes.includes(params.contentType)) {
      throw new BadRequestException(`Unsupported MIME type: ${params.contentType}`);
    }

    const documentId = randomUUID();
    const objectKey = `orgs/${organizationId}/${params.purpose.toLowerCase()}/${documentId}-${params.filename}`;
    const mockPresignedUploadUrl = `https://s3.ap-south-1.amazonaws.com/pauti-pustak-storage/${objectKey}?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Expires=900`;

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
        sha256: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        status: DocumentStatus.UPLOAD_PENDING,
      },
    });

    return {
      documentId: doc.id,
      objectKey,
      uploadUrl: mockPresignedUploadUrl,
      expiresInSeconds: 900,
    };
  }

  async getPresignedDownloadUrl(organizationId: string, documentId: string) {
    const doc = await this.prisma.documentAsset.findFirst({
      where: { id: documentId, organizationId },
    });

    if (!doc || doc.status === DocumentStatus.REJECTED) {
      throw new NotFoundException("Document not found or unavailable");
    }

    const mockPresignedDownloadUrl = `https://s3.ap-south-1.amazonaws.com/pauti-pustak-storage/${doc.objectKey}?X-Amz-Expires=900`;

    return {
      documentId: doc.id,
      filename: doc.originalFileName,
      contentType: doc.mimeType,
      downloadUrl: mockPresignedDownloadUrl,
      expiresInSeconds: 900,
    };
  }
}
