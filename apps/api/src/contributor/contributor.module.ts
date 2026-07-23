import { Module } from "@nestjs/common";
import { ContributorsController } from "./contributor.controller";

@Module({
  controllers: [ContributorsController],
})
export class ContributorModule {}
