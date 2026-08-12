import { Module } from "@nestjs/common";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { PanEncryptionService } from "@pauti-pustak/backend-security";
import { ReceiptsModule } from "../receipts/receipts.module";
import { DonorController } from "./donor.controller";
import { DonorService } from "./donor.service";

@Module({
  imports: [PrismaModule, ReceiptsModule],
  controllers: [DonorController],
  providers: [DonorService, PanEncryptionService],
  exports: [DonorService],
})
export class DonorModule {}
