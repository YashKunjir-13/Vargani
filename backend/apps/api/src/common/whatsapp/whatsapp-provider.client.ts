export interface WhatsAppSendResult {
  providerMessageId: string;
}

export interface SendMediaMessageParams {
  recipientPhone: string;
  mediaUrl: string;
}

export interface WhatsAppProviderClient {
  sendMediaMessage(params: SendMediaMessageParams): Promise<WhatsAppSendResult>;
}

/** DI token so the provider client is swappable/mockable independent of WhatsAppDeliveryService. */
export const WHATSAPP_PROVIDER_CLIENT = Symbol("WHATSAPP_PROVIDER_CLIENT");

/**
 * Default provider client: a thin HTTP wrapper around a WhatsApp Business
 * API-shaped send endpoint, configured entirely via env vars. No specific
 * BSP is assumed -- swap this implementation (still behind
 * WhatsAppProviderClient) once a real provider is chosen.
 */
export class HttpWhatsAppProviderClient implements WhatsAppProviderClient {
  async sendMediaMessage({ recipientPhone, mediaUrl }: SendMediaMessageParams): Promise<WhatsAppSendResult> {
    const apiUrl = process.env.WHATSAPP_API_URL;
    const apiToken = process.env.WHATSAPP_API_TOKEN;
    const senderNumber = process.env.WHATSAPP_SENDER_NUMBER;

    if (!apiUrl || !apiToken) {
      throw new Error("WhatsApp provider is not configured (WHATSAPP_API_URL/WHATSAPP_API_TOKEN missing)");
    }

    const response = await fetch(apiUrl, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: senderNumber,
        to: recipientPhone,
        type: "document",
        document: { link: mediaUrl },
      }),
    });

    if (!response.ok) {
      throw new Error(`WhatsApp provider responded with ${response.status}: ${await response.text()}`);
    }

    const body = (await response.json()) as { messageId?: string; id?: string };
    return { providerMessageId: body.messageId ?? body.id ?? "" };
  }
}
