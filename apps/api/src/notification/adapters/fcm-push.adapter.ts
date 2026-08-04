import { Injectable, Logger } from "@nestjs/common";
import { PushNotificationPort, SendPushParams } from "../ports/push-notification.port";

@Injectable()
export class FcmPushAdapter implements PushNotificationPort {
  private readonly logger = new Logger(FcmPushAdapter.name);

  async sendPush(params: SendPushParams): Promise<{ successCount: number; failureCount: number }> {
    this.logger.log(
      `[FCM Push] Sending push notification to ${params.deviceTokens.length} devices [title: ${params.title}]`,
    );

    // Development/Fallback mock
    return {
      successCount: params.deviceTokens.length,
      failureCount: 0,
    };
  }
}
