import { Module } from "@nestjs/common";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { NotificationController } from "./notification.controller";
import { NotificationService } from "./notification.service";
import { FcmPushAdapter } from "./adapters/fcm-push.adapter";
import { SmtpEmailAdapter } from "./adapters/smtp-email.adapter";
import { TwilioSmsAdapter } from "./adapters/twilio-sms.adapter";
import { PUSH_NOTIFICATION_PORT } from "./ports/push-notification.port";
import { EMAIL_PROVIDER_PORT } from "./ports/email-provider.port";
import { SMS_PROVIDER_PORT } from "./ports/sms-provider.port";

@Module({
  imports: [PrismaModule],
  controllers: [NotificationController],
  providers: [
    NotificationService,
    FcmPushAdapter,
    SmtpEmailAdapter,
    TwilioSmsAdapter,
    { provide: PUSH_NOTIFICATION_PORT, useClass: FcmPushAdapter },
    { provide: EMAIL_PROVIDER_PORT, useClass: SmtpEmailAdapter },
    { provide: SMS_PROVIDER_PORT, useClass: TwilioSmsAdapter },
  ],
  exports: [NotificationService, PUSH_NOTIFICATION_PORT, EMAIL_PROVIDER_PORT, SMS_PROVIDER_PORT],
})
export class NotificationModule {}
