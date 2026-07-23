import { Module } from "@nestjs/common";
import { EventsController } from "./event.controller";

@Module({
  controllers: [EventsController],
})
export class EventModule {}
