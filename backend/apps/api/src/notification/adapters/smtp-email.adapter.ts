import { Injectable, Logger } from "@nestjs/common";
import { EmailProviderPort, SendEmailParams } from "../ports/email-provider.port";

@Injectable()
export class SmtpEmailAdapter implements EmailProviderPort {
  private readonly logger = new Logger(SmtpEmailAdapter.name);

  async sendEmail(params: SendEmailParams): Promise<{ messageId: string }> {
    this.logger.log(`[SMTP Email] Sending email to ${params.toEmail} [subject: ${params.subject}]`);
    return {
      messageId: `SMTP-MSG-${Date.now()}`,
    };
  }
}
