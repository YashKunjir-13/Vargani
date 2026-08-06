import { Module } from "@nestjs/common";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { PanEncryptionService } from "@pauti-pustak/backend-security";
import { FinanceController } from "./finance.controller";
import { FinanceService } from "./finance.service";

@Module({
  imports: [PrismaModule],
  controllers: [FinanceController],
  providers: [FinanceService, PanEncryptionService],
  exports: [FinanceService],
})
export class FinanceModule {}
