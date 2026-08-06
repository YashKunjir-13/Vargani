import { Module } from "@nestjs/common";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { ReportingController } from "./reporting.controller";
import { ReportingService } from "./reporting.service";

@Module({
  imports: [PrismaModule],
  controllers: [ReportingController],
  providers: [ReportingService],
  exports: [ReportingService],
})
export class ReportingModule {}
