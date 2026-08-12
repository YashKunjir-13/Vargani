export interface UploadOptions {
    tenantId: string;
    filename: string;
    body: Buffer;
    contentType: string;
    checksumSha256?: string;
}
export declare class S3StorageService {
    private readonly s3Client;
    private readonly bucket;
    constructor();
    generateTenantKey(tenantId: string, filename: string): string;
    uploadFile(options: UploadOptions): Promise<{
        storageKey: string;
        size: number;
    }>;
    getPresignedDownloadUrl(storageKey: string, expiresInSeconds?: number): Promise<string>;
}
