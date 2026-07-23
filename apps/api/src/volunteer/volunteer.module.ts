import { Module } from "@nestjs/common";
import { VolunteersController } from "./volunteer.controller";

@Module({
  controllers: [VolunteersController],
})
export class VolunteerModule {}
