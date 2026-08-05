import { Module } from "@nestjs/common";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { TenancyModule } from "../common/tenancy/tenancy.module";
import { FestivalYearModule } from "../common/festival-year/festival-year.module";
import { SequenceModule } from "../common/sequence/sequence.module";
import { WhatsAppModule } from "../common/whatsapp/whatsapp.module";
import { AuditModule } from "../audit/audit.module";
import { TemplatesModule } from "../templates/templates.module";
import { ContributionModule } from "../contribution/contribution.module";
import { ContributionReceiptsController } from "./contribution-receipts.controller";
import {
  ContributionReceiptsRepository,
  ContributionReceiptsService,
} from "./contribution-receipts.service";

@Module({
  imports: [
    PrismaModule,
    TenancyModule,
    FestivalYearModule,
    SequenceModule,
    WhatsAppModule,
    AuditModule,
    TemplatesModule,
    ContributionModule,
  ],
  controllers: [ContributionReceiptsController],
  providers: [ContributionReceiptsRepository, ContributionReceiptsService],
  exports: [ContributionReceiptsService],
})
export class ContributionReceiptsModule {}
