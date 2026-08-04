import { Module } from "@nestjs/common";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { TenancyModule } from "../common/tenancy/tenancy.module";
import { FestivalYearModule } from "../common/festival-year/festival-year.module";
import { StorageModule } from "../common/storage/storage.module";
import { ContributionsController } from "./contribution.controller";
import { ContributionsRepository, ContributionsService } from "./contribution.service";

@Module({
  imports: [PrismaModule, TenancyModule, FestivalYearModule, StorageModule],
  controllers: [ContributionsController],
  providers: [ContributionsRepository, ContributionsService],
  exports: [ContributionsService],
})
export class ContributionModule {}

