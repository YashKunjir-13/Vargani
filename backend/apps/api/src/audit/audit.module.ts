import { Module } from "@nestjs/common";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { AuditController } from "./audit.controller";
import { AuditService } from "./audit.service";

@Module({
  imports: [PrismaModule],
  controllers: [AuditController],
  providers: [AuditService],
  exports: [AuditService],
})
export class AuditModule {}
