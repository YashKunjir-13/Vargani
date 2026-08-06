import { Injectable, Logger } from "@nestjs/common";
import { existsSync, mkdirSync, unlinkSync } from "fs";
import { dirname, join } from "path";
import { ObjectStoragePort } from "../ports/object-storage.port";

@Injectable()
export class LocalStorageAdapter implements ObjectStoragePort {
  private readonly logger = new Logger(LocalStorageAdapter.name);
  private readonly baseStorageDir = process.env.LOCAL_STORAGE_DIR || "./storage";
  private readonly baseUrl = process.env.APP_BASE_URL || "http://localhost:3000";

  constructor() {
    if (!existsSync(this.baseStorageDir)) {
      mkdirSync(this.baseStorageDir, { recursive: true });
    }
  }

  async getUploadUrl(objectKey: string, contentType: string, expiresInSeconds: number): Promise<string> {
    const filePath = join(this.baseStorageDir, objectKey);
    const dir = dirname(filePath);
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
    }
    this.logger.log(`Prepared local upload target path: ${filePath}`);
    return `${this.baseUrl}/api/v1/documents/local-upload?key=${encodeURIComponent(objectKey)}&expires=${expiresInSeconds}`;
  }

  async getDownloadUrl(objectKey: string, expiresInSeconds: number): Promise<string> {
    return `${this.baseUrl}/api/v1/documents/local-stream?key=${encodeURIComponent(objectKey)}&expires=${expiresInSeconds}`;
  }

  async deleteObject(objectKey: string): Promise<void> {
    const filePath = join(this.baseStorageDir, objectKey);
    if (existsSync(filePath)) {
      unlinkSync(filePath);
      this.logger.log(`Deleted local file: ${filePath}`);
    }
  }

  async copyObject(sourceKey: string, destinationKey: string): Promise<void> {
    this.logger.log(`Copying local file from ${sourceKey} to ${destinationKey}`);
  }
}
