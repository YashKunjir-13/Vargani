import { GetObjectCommand, PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { Injectable } from "@nestjs/common";

export interface UploadOptions {
  tenantId: string;
  filename: string;
  body: Buffer;
  contentType: string;
  checksumSha256?: string;
}

@Injectable()
export class S3StorageService {
  private readonly s3Client: S3Client;
  private readonly bucket: string;

  constructor() {
    const endpoint = process.env.S3_ENDPOINT || "http://localhost:9000";
    const region = process.env.S3_REGION || "us-east-1";
    const accessKeyId = process.env.S3_ACCESS_KEY || "minioadmin";
    const secretAccessKey = process.env.S3_SECRET_KEY || "minioadmin";
    const forcePathStyle = process.env.S3_FORCE_PATH_STYLE === "true";

    this.bucket = process.env.S3_BUCKET || "pauti-pustak-assets";
    this.s3Client = new S3Client({
      endpoint,
      region,
      credentials: { accessKeyId, secretAccessKey },
      forcePathStyle,
    });
  }

  generateTenantKey(tenantId: string, filename: string): string {
    const sanitizedFilename = filename.replace(/[^a-zA-Z0-9.\-_]/g, "_");
    const timestamp = Date.now();
    return `tenants/${tenantId}/${timestamp}_${sanitizedFilename}`;
  }

  async uploadFile(options: UploadOptions): Promise<{ storageKey: string; size: number }> {
    const storageKey = this.generateTenantKey(options.tenantId, options.filename);

    const command = new PutObjectCommand({
      Bucket: this.bucket,
      Key: storageKey,
      Body: options.body,
      ContentType: options.contentType,
      ContentLength: options.body.length,
      Metadata: {
        tenantId: options.tenantId,
        checksumSha256: options.checksumSha256 || "",
      },
    });

    await this.s3Client.send(command);

    return {
      storageKey,
      size: options.body.length,
    };
  }

  async getPresignedDownloadUrl(storageKey: string, expiresInSeconds = 900): Promise<string> {
    const command = new GetObjectCommand({
      Bucket: this.bucket,
      Key: storageKey,
    });

    return getSignedUrl(this.s3Client, command, { expiresIn: expiresInSeconds });
  }
}
