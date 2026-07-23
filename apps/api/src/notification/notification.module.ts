import { Module } from "@nestjs/common";
import { NotificationsController } from "./notification.controller";

@Module({
  controllers: [NotificationsController],
})
export class NotificationModule {}
