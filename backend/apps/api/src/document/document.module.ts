import { Module } from "@nestjs/common";
import { DocumentController } from "./document.controller";
import { DocumentService } from "./document.service";
import { S3StorageAdapter } from "./adapters/s3-storage.adapter";
import { MinioStorageAdapter } from "./adapters/minio-storage.adapter";
import { LocalStorageAdapter } from "./adapters/local-storage.adapter";
import { OBJECT_STORAGE_PORT } from "./ports/object-storage.port";

@Module({
  controllers: [DocumentController],
  providers: [
    DocumentService,
    S3StorageAdapter,
    MinioStorageAdapter,
    LocalStorageAdapter,
    {
      provide: OBJECT_STORAGE_PORT,
      useFactory: (s3: S3StorageAdapter, minio: MinioStorageAdapter, local: LocalStorageAdapter) => {
        const driver = (process.env.STORAGE_DRIVER || "s3").toLowerCase();
        if (driver === "minio") return minio;
        if (driver === "local") return local;
        return s3;
      },
      inject: [S3StorageAdapter, MinioStorageAdapter, LocalStorageAdapter],
    },
  ],
  exports: [DocumentService, OBJECT_STORAGE_PORT],
})
export class DocumentModule {}
