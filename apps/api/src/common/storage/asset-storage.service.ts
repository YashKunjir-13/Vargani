import { createHash } from "node:crypto";
import { Injectable } from "@nestjs/common";
import { DocumentPurpose, DocumentStatus, PrismaService } from "@pauti-pustak/backend-database";
import { S3StorageService } from "@pauti-pustak/backend-shared-kernel";

export interface UploadAssetParams {
  organizationId: string;
  ownerUserId: string;
  purpose: DocumentPurpose;
  filename: string;
  body: Buffer;
  contentType: string;
}

export interface UploadedAsset {
  documentId: string;
  objectKey: string;
  url: string;
}

/**
 * Thin domain wrapper around S3StorageService: every caller (templates,
 * certificate photos, bill photos, stamps/signatures, ...) goes through
 * this one service, which persists only the resulting storage key/URL in
 * Postgres (DocumentAsset.objectKey) -- binary bytes are never stored in
 * the database, only in S3-compatible object storage.
 */
@Injectable()
export class AssetStorageService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly s3StorageService: S3StorageService,
  ) {}

  async uploadAsset(params: UploadAssetParams): Promise<UploadedAsset> {
    const checksumSha256 = createHash("sha256").update(params.body).digest("hex");

    const { storageKey, size } = await this.s3StorageService.uploadFile({
      tenantId: params.organizationId,
      filename: params.filename,
      body: params.body,
      contentType: params.contentType,
      checksumSha256,
    });

    const document = await this.prisma.documentAsset.create({
      data: {
        organizationId: params.organizationId,
        ownerUserId: params.ownerUserId,
        purpose: params.purpose,
        status: DocumentStatus.AVAILABLE,
        objectKey: storageKey,
        originalFileName: params.filename,
        mimeType: params.contentType,
        fileSizeBytes: BigInt(size),
        sha256: checksumSha256,
        uploadedAt: new Date(),
      },
    });

    const url = await this.s3StorageService.getPresignedDownloadUrl(storageKey);

    return { documentId: document.id, objectKey: storageKey, url };
  }

  getDownloadUrl(objectKey: string, expiresInSeconds?: number): Promise<string> {
    return this.s3StorageService.getPresignedDownloadUrl(objectKey, expiresInSeconds);
  }
}
