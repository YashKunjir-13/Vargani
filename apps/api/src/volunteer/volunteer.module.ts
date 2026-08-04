import { Module } from "@nestjs/common";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { PanEncryptionService } from "@pauti-pustak/backend-security";
import { VolunteerController } from "./volunteer.controller";
import { VolunteerService } from "./volunteer.service";

@Module({
  imports: [PrismaModule],
  controllers: [VolunteerController],
  providers: [VolunteerService, PanEncryptionService],
  exports: [VolunteerService],
})
export class VolunteerModule {}
