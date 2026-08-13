"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.S3StorageService = void 0;
const client_s3_1 = require("@aws-sdk/client-s3");
const s3_request_presigner_1 = require("@aws-sdk/s3-request-presigner");
const common_1 = require("@nestjs/common");
let S3StorageService = class S3StorageService {
    s3Client;
    bucket;
    constructor() {
        const endpoint = process.env.S3_ENDPOINT || "http://localhost:9000";
        const region = process.env.S3_REGION || "us-east-1";
        const accessKeyId = process.env.S3_ACCESS_KEY || "minioadmin";
        const secretAccessKey = process.env.S3_SECRET_KEY || "minioadmin";
        const forcePathStyle = process.env.S3_FORCE_PATH_STYLE === "true";
        this.bucket = process.env.S3_BUCKET || "pauti-pustak-assets";
        this.s3Client = new client_s3_1.S3Client({
            endpoint,
            region,
            credentials: { accessKeyId, secretAccessKey },
            forcePathStyle,
        });
    }
    generateTenantKey(tenantId, filename) {
        const sanitizedFilename = filename.replace(/[^a-zA-Z0-9.\-_]/g, "_");
        const timestamp = Date.now();
        return `tenants/${tenantId}/${timestamp}_${sanitizedFilename}`;
    }
    async uploadFile(options) {
        const storageKey = this.generateTenantKey(options.tenantId, options.filename);
        const command = new client_s3_1.PutObjectCommand({
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
    async getPresignedDownloadUrl(storageKey, expiresInSeconds = 900) {
        const command = new client_s3_1.GetObjectCommand({
            Bucket: this.bucket,
            Key: storageKey,
        });
        return (0, s3_request_presigner_1.getSignedUrl)(this.s3Client, command, { expiresIn: expiresInSeconds });
    }
};
exports.S3StorageService = S3StorageService;
exports.S3StorageService = S3StorageService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], S3StorageService);
//# sourceMappingURL=s3-storage.service.js.map