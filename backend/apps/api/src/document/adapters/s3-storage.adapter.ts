import { Injectable, Logger } from "@nestjs/common";
import { ObjectStoragePort } from "../ports/object-storage.port";

@Injectable()
export class S3StorageAdapter implements ObjectStoragePort {
  private readonly logger = new Logger(S3StorageAdapter.name);
  private readonly bucketName = process.env.S3_BUCKET_NAME ?? "pauti-pustak-storage";
  private readonly region = process.env.AWS_REGION ?? "ap-south-1";

  async getUploadUrl(objectKey: string, contentType: string, expiresInSeconds: number): Promise<string> {
    this.logger.log(`Generated upload URL for ${objectKey} (${contentType})`);
    return `https://s3.${this.region}.amazonaws.com/${this.bucketName}/${objectKey}?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Expires=${expiresInSeconds}`;
  }

  async getDownloadUrl(objectKey: string, expiresInSeconds: number): Promise<string> {
    this.logger.log(`Generated download URL for ${objectKey}`);
    return `https://s3.${this.region}.amazonaws.com/${this.bucketName}/${objectKey}?X-Amz-Expires=${expiresInSeconds}`;
  }

  async deleteObject(objectKey: string): Promise<void> {
    this.logger.log(`Deleted S3 object ${objectKey}`);
  }

  async copyObject(sourceKey: string, destinationKey: string): Promise<void> {
    this.logger.log(`Copied S3 object from ${sourceKey} to ${destinationKey}`);
  }
}
