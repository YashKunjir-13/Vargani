export interface SendEmailParams {
  toEmail: string;
  subject: string;
  bodyHtml: string;
  attachments?: Array<{ filename: string; url: string }>;
}

export interface EmailProviderPort {
  sendEmail(params: SendEmailParams): Promise<{ messageId: string }>;
}

export const EMAIL_PROVIDER_PORT = Symbol("EMAIL_PROVIDER_PORT");
