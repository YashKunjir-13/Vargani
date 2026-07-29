import { Inject, Injectable, Logger } from "@nestjs/common";
import { PrismaService, WhatsAppDeliveryStatus } from "@pauti-pustak/backend-database";
import { WHATSAPP_PROVIDER_CLIENT, WhatsAppProviderClient } from "./whatsapp-provider.client";

export interface SendWhatsAppDocumentParams {
  organizationId: string;
  recipientPhone: string;
  mediaUrl: string;
  relatedEntityType?: string;
  relatedEntityId?: string;
}

const MAX_RETRY_COUNT = 3;

/**
 * Shared, internal (not user-facing) delivery of a rendered PDF/image over
 * WhatsApp. Every public method here is fire-and-forget relative to
 * whatever caused the send -- delivery failure is tracked in
 * WhatsAppDeliveryRecord (Pending/Sent/Failed + retryCount) and is always
 * retryable later, but it must NEVER throw or otherwise block/roll back the
 * caller (e.g. receipt generation) that triggered it.
 */
@Injectable()
export class WhatsAppDeliveryService {
  private readonly logger = new Logger(WhatsAppDeliveryService.name);

  constructor(
    private readonly prisma: PrismaService,
    @Inject(WHATSAPP_PROVIDER_CLIENT) private readonly providerClient: WhatsAppProviderClient,
  ) {}

  async sendDocument(params: SendWhatsAppDocumentParams): Promise<{ deliveryId: string }> {
    const record = await this.prisma.whatsAppDeliveryRecord.create({
      data: {
        organizationId: params.organizationId,
        recipientPhone: params.recipientPhone,
        mediaUrl: params.mediaUrl,
        relatedEntityType: params.relatedEntityType,
        relatedEntityId: params.relatedEntityId,
        status: WhatsAppDeliveryStatus.PENDING,
      },
    });

    await this.attemptDelivery(record.id, params.recipientPhone, params.mediaUrl);

    return { deliveryId: record.id };
  }

  /** Re-attempts a previously FAILED delivery, up to MAX_RETRY_COUNT. Never throws. */
  async retryDelivery(deliveryId: string): Promise<void> {
    const record = await this.prisma.whatsAppDeliveryRecord.findUnique({ where: { id: deliveryId } });
    if (!record || record.status === WhatsAppDeliveryStatus.SENT) {
      return;
    }
    if (record.retryCount >= MAX_RETRY_COUNT) {
      return;
    }
    await this.attemptDelivery(record.id, record.recipientPhone, record.mediaUrl);
  }

  private async attemptDelivery(
    deliveryId: string,
    recipientPhone: string,
    mediaUrl: string,
  ): Promise<void> {
    try {
      const result = await this.providerClient.sendMediaMessage({ recipientPhone, mediaUrl });
      await this.prisma.whatsAppDeliveryRecord.update({
        where: { id: deliveryId },
        data: { status: WhatsAppDeliveryStatus.SENT, providerMessageId: result.providerMessageId },
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      this.logger.warn(`WhatsApp delivery ${deliveryId} failed: ${message}`);

      // Even a failure to *persist* the failure must not propagate -- this
      // method's contract to its caller is unconditional: never throw.
      await this.prisma.whatsAppDeliveryRecord
        .update({
          where: { id: deliveryId },
          data: {
            status: WhatsAppDeliveryStatus.FAILED,
            retryCount: { increment: 1 },
            lastError: message,
          },
        })
        .catch((updateError: unknown) => {
          this.logger.error(
            `Failed to persist WhatsApp delivery failure for ${deliveryId}`,
            updateError instanceof Error ? updateError.stack : String(updateError),
          );
        });
    }
  }
}
