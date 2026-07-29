import { Module } from "@nestjs/common";
import { S3StorageService } from "@pauti-pustak/backend-shared-kernel";
import { AssetStorageService } from "./asset-storage.service";

@Module({
  providers: [AssetStorageService, S3StorageService],
  exports: [AssetStorageService],
})
export class StorageModule {}
