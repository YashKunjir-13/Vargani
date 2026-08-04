import { BadRequestException, Inject, Injectable, Logger, NotFoundException, Optional } from "@nestjs/common";
import { DevicePlatform, PrismaService, WhatsAppDeliveryStatus } from "@pauti-pustak/backend-database";
import { PUSH_NOTIFICATION_PORT, PushNotificationPort } from "./ports/push-notification.port";
import { EMAIL_PROVIDER_PORT, EmailProviderPort } from "./ports/email-provider.port";
import { SMS_PROVIDER_PORT, SmsProviderPort } from "./ports/sms-provider.port";
import { RegisterDeviceTokenDto } from "./dto/register-device-token.dto";
import { CreateNotificationTemplateDto } from "./dto/create-notification-template.dto";

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);

  constructor(
    @Inject(PrismaService) private readonly prisma: PrismaService,
    @Optional() @Inject(PUSH_NOTIFICATION_PORT) private readonly pushProvider?: PushNotificationPort,
    @Optional() @Inject(EMAIL_PROVIDER_PORT) private readonly emailProvider?: EmailProviderPort,
    @Optional() @Inject(SMS_PROVIDER_PORT) private readonly smsProvider?: SmsProviderPort,
  ) {}

  async registerDeviceToken(userId: string, dto: RegisterDeviceTokenDto) {
    const token = await this.prisma.deviceToken.upsert({
      where: { deviceToken: dto.deviceToken },
      update: { userId, platform: dto.platform, updatedAt: new Date() },
      create: { userId, deviceToken: dto.deviceToken, platform: dto.platform },
    });

    return { tokenId: token.id, platform: token.platform };
  }

  async sendNotification(
    organizationId: string,
    params: {
      recipientMobile: string;
      recipientName: string;
      recipientEmail?: string;
      targetUserId?: string;
      channel: "WHATSAPP" | "SMS" | "EMAIL" | "PUSH" | "IN_APP";
      templateCode: string;
      languageCode?: string;
      templateVariables?: Record<string, any>;
    },
  ) {
    this.logger.log(
      `Dispatching ${params.channel} notification to ${params.recipientMobile} [template: ${params.templateCode}]`,
    );

    // Validate payload placeholders if template exists
    await this.validateTemplatePayload(params.templateCode, params.templateVariables);

    let providerRef = `MSG-${Date.now()}`;

    // Provider channel dispatching
    if (params.channel === "EMAIL" && params.recipientEmail && this.emailProvider) {
      const res = await this.emailProvider.sendEmail({
        toEmail: params.recipientEmail,
        subject: `Notification: ${params.templateCode}`,
        bodyHtml: `<p>Dear ${params.recipientName}, template: ${params.templateCode}</p>`,
      });
      providerRef = res.messageId;
    } else if (params.channel === "SMS" && this.smsProvider) {
      const res = await this.smsProvider.sendSms({
        recipientMobile: params.recipientMobile,
        messageText: `Dear ${params.recipientName}, template ${params.templateCode}`,
      });
      providerRef = res.sid;
    } else if (params.channel === "PUSH" && params.targetUserId && this.pushProvider) {
      const tokens = await this.prisma.deviceToken.findMany({ where: { userId: params.targetUserId } });
      if (tokens.length > 0) {
        await this.pushProvider.sendPush({
          deviceTokens: tokens.map((t) => t.deviceToken),
          title: `PautiPustak Update`,
          body: `Notification code: ${params.templateCode}`,
        });
      }
    } else if (params.channel === "IN_APP" && params.targetUserId) {
      await this.prisma.userNotification.create({
        data: {
          organizationId,
          userId: params.targetUserId,
          title: `Notification ${params.templateCode}`,
          body: `Dear ${params.recipientName}, you have a new update.`,
        },
      });
    }

    const deliveryRecord = await this.prisma.whatsAppDeliveryRecord.create({
      data: {
        organizationId,
        recipientPhone: params.recipientMobile,
        mediaUrl: `https://storage.pauti-pustak.org/${params.templateCode}.pdf`,
        status: WhatsAppDeliveryStatus.SENT,
        providerMessageId: providerRef,
        relatedEntityType: "RECEIPT",
        relatedEntityId: params.templateVariables?.receiptId ?? null,
      },
    });

    return {
      deliveryLogId: deliveryRecord.id,
      channel: params.channel,
      status: WhatsAppDeliveryStatus.SENT,
      recipientMobile: params.recipientMobile,
      providerRef,
    };
  }

  async getDeliveryLogs(organizationId: string, limit = 50) {
    return this.prisma.whatsAppDeliveryRecord.findMany({
      where: { organizationId },
      orderBy: { createdAt: "desc" },
      take: limit,
    });
  }

  async getUserNotifications(organizationId: string, userId: string, unreadOnly = false) {
    return this.prisma.userNotification.findMany({
      where: {
        organizationId,
        userId,
        ...(unreadOnly ? { isRead: false } : {}),
      },
      orderBy: { createdAt: "desc" },
    });
  }

  async markNotificationAsRead(organizationId: string, userId: string, notificationId: string) {
    const notif = await this.prisma.userNotification.findFirst({
      where: { id: notificationId, organizationId, userId },
    });

    if (!notif) {
      throw new NotFoundException("Notification not found");
    }

    return this.prisma.userNotification.update({
      where: { id: notificationId },
      data: { isRead: true, readAt: new Date() },
    });
  }

  async listTemplates(organizationId: string) {
    return this.prisma.notificationTemplate.findMany({
      where: { OR: [{ organizationId }, { organizationId: null }] },
      orderBy: { createdAt: "desc" },
    });
  }

  async createTemplate(organizationId: string, dto: CreateNotificationTemplateDto) {
    return this.prisma.notificationTemplate.create({
      data: {
        organizationId,
        code: dto.code,
        name: dto.name,
        channel: dto.channel,
        subjectPattern: dto.subjectPattern,
        bodyPattern: dto.bodyPattern,
        languageCode: dto.languageCode ?? "en",
      },
    });
  }

  private async validateTemplatePayload(templateCode: string, payload?: Record<string, any>) {
    const tpl = await this.prisma.notificationTemplate.findUnique({ where: { code: templateCode } });
    if (!tpl) return;

    const matches = tpl.bodyPattern.match(/\{\{(\w+)\}\}/g);
    if (!matches) return;

    for (const m of matches) {
      const key = m.replace(/[\{\}]/g, "");
      if (payload && !(key in payload)) {
        this.logger.warn(`Template variable {{${key}}} missing from notification payload`);
      }
    }
  }
}
