export interface SendPushParams {
  deviceTokens: string[];
  title: string;
  body: string;
  data?: Record<string, string>;
}

export interface PushNotificationPort {
  sendPush(params: SendPushParams): Promise<{ successCount: number; failureCount: number }>;
}

export const PUSH_NOTIFICATION_PORT = Symbol("PUSH_NOTIFICATION_PORT");
