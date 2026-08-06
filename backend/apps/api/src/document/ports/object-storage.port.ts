export interface ObjectStoragePort {
  getUploadUrl(objectKey: string, contentType: string, expiresInSeconds: number): Promise<string>;
  getDownloadUrl(objectKey: string, expiresInSeconds: number): Promise<string>;
  deleteObject(objectKey: string): Promise<void>;
  copyObject(sourceKey: string, destinationKey: string): Promise<void>;
}

export const OBJECT_STORAGE_PORT = Symbol("OBJECT_STORAGE_PORT");
