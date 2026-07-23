import { Module } from "@nestjs/common";
import { ReportsController } from "./reporting.controller";

@Module({
  controllers: [ReportsController],
})
export class ReportingModule {}
