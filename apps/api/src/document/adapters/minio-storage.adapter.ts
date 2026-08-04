import { Injectable, Logger } from "@nestjs/common";
import { ObjectStoragePort } from "../ports/object-storage.port";

@Injectable()
export class MinioStorageAdapter implements ObjectStoragePort {
  private readonly logger = new Logger(MinioStorageAdapter.name);

  private readonly endpoint = process.env.MINIO_ENDPOINT || "localhost";
  private readonly port = process.env.MINIO_PORT || "9000";
  private readonly bucket = process.env.MINIO_BUCKET || "pauti-pustak-minio";
  private readonly useSsl = process.env.MINIO_USE_SSL === "true";

  async getUploadUrl(objectKey: string, contentType: string, expiresInSeconds: number): Promise<string> {
    const protocol = this.useSsl ? "https" : "http";
    this.logger.log(`Generating MinIO upload URL for key: ${objectKey}`);
    return `${protocol}://${this.endpoint}:${this.port}/${this.bucket}/${objectKey}?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Expires=${expiresInSeconds}`;
  }

  async getDownloadUrl(objectKey: string, expiresInSeconds: number): Promise<string> {
    const protocol = this.useSsl ? "https" : "http";
    return `${protocol}://${this.endpoint}:${this.port}/${this.bucket}/${objectKey}?X-Amz-Expires=${expiresInSeconds}`;
  }

  async deleteObject(objectKey: string): Promise<void> {
    this.logger.log(`Deleting MinIO object: ${objectKey}`);
  }

  async copyObject(sourceKey: string, destinationKey: string): Promise<void> {
    this.logger.log(`Copying MinIO object from ${sourceKey} to ${destinationKey}`);
  }
}
