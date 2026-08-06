export interface SendSmsParams {
  recipientMobile: string;
  messageText: string;
  templateId?: string;
}

export interface SmsProviderPort {
  sendSms(params: SendSmsParams): Promise<{ sid: string }>;
}

export const SMS_PROVIDER_PORT = Symbol("SMS_PROVIDER_PORT");
