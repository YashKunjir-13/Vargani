import { Module } from "@nestjs/common";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { ContributorController } from "./contributor.controller";
import { ContributorService } from "./contributor.service";

@Module({
  imports: [PrismaModule],
  controllers: [ContributorController],
  providers: [ContributorService],
  exports: [ContributorService],
})
export class ContributorModule {}
