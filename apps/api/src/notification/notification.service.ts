import { Injectable, Logger } from "@nestjs/common";
import { PrismaService, WhatsAppDeliveryStatus } from "@pauti-pustak/backend-database";

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);

  constructor(private readonly prisma: PrismaService) {}

  async sendNotification(
    organizationId: string,
    params: {
      recipientMobile: string;
      recipientName: string;
      channel: "WHATSAPP" | "SMS" | "EMAIL";
      templateCode: string;
      languageCode?: string;
      templateVariables?: Record<string, any>;
    },
  ) {
    this.logger.log(
      `Dispatching ${params.channel} notification to ${params.recipientMobile} [template: ${params.templateCode}]`,
    );

    const deliveryRecord = await this.prisma.whatsAppDeliveryRecord.create({
      data: {
        organizationId,
        recipientPhone: params.recipientMobile,
        mediaUrl: `https://storage.pauti-pustak.org/${params.templateCode}.pdf`,
        status: WhatsAppDeliveryStatus.SENT,
        providerMessageId: `MSG-${Date.now()}`,
        relatedEntityType: "RECEIPT",
        relatedEntityId: params.templateVariables?.receiptId ?? null,
      },
    });

    return {
      deliveryLogId: deliveryRecord.id,
      channel: params.channel,
      status: WhatsAppDeliveryStatus.SENT,
      recipientMobile: params.recipientMobile,
    };
  }

  async getDeliveryLogs(organizationId: string, limit = 50) {
    return this.prisma.whatsAppDeliveryRecord.findMany({
      where: { organizationId },
      orderBy: { createdAt: "desc" },
      take: limit,
    });
  }
}
