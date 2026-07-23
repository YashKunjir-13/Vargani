import { Module } from "@nestjs/common";
import { ContributionsController } from "./contribution.controller";

@Module({
  controllers: [ContributionsController],
})
export class ContributionModule {}
