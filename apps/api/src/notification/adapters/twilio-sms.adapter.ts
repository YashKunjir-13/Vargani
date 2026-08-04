import { Injectable, Logger } from "@nestjs/common";
import { SendSmsParams, SmsProviderPort } from "../ports/sms-provider.port";

@Injectable()
export class TwilioSmsAdapter implements SmsProviderPort {
  private readonly logger = new Logger(TwilioSmsAdapter.name);

  async sendSms(params: SendSmsParams): Promise<{ sid: string }> {
    this.logger.log(`[Twilio SMS] Sending SMS to ${params.recipientMobile}`);
    return {
      sid: `SMS-SID-${Date.now()}`,
    };
  }
}
