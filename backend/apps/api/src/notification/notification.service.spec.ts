import { Test, TestingModule } from "@nestjs/testing";
import { DevicePlatform, PrismaService, WhatsAppDeliveryStatus } from "@pauti-pustak/backend-database";
import { NotificationService } from "./notification.service";
import { PUSH_NOTIFICATION_PORT } from "./ports/push-notification.port";
import { EMAIL_PROVIDER_PORT } from "./ports/email-provider.port";
import { SMS_PROVIDER_PORT } from "./ports/sms-provider.port";

describe("NotificationService (Enterprise Unit Tests)", () => {
  let service: NotificationService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      deviceToken: {
        upsert: jest.fn(),
        findMany: jest.fn(),
      },
      whatsAppDeliveryRecord: {
        create: jest.fn(),
        findMany: jest.fn(),
      },
      userNotification: {
        create: jest.fn(),
        findMany: jest.fn(),
        findFirst: jest.fn(),
        update: jest.fn(),
      },
      notificationTemplate: {
        findUnique: jest.fn(),
        findMany: jest.fn(),
        create: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationService,
        { provide: PrismaService, useValue: prisma },
        {
          provide: PUSH_NOTIFICATION_PORT,
          useValue: { sendPush: jest.fn().mockResolvedValue({ successCount: 1, failureCount: 0 }) },
        },
        {
          provide: EMAIL_PROVIDER_PORT,
          useValue: { sendEmail: jest.fn().mockResolvedValue({ messageId: "EMAIL-123" }) },
        },
        {
          provide: SMS_PROVIDER_PORT,
          useValue: { sendSms: jest.fn().mockResolvedValue({ sid: "SMS-123" }) },
        },
      ],
    }).compile();

    service = module.get<NotificationService>(NotificationService);
  });

  describe("Device Token Registration & Push Notifications", () => {
    it("registers or updates FCM device token", async () => {
      prisma.deviceToken.upsert.mockResolvedValue({
        id: "token-1",
        platform: DevicePlatform.ANDROID,
      });

      const res = await service.registerDeviceToken("user-1", {
        deviceToken: "fcm_xyz_123",
        platform: DevicePlatform.ANDROID,
      });

      expect(res.tokenId).toBe("token-1");
      expect(prisma.deviceToken.upsert).toHaveBeenCalled();
    });

    it("dispatches multi-channel notification (Email)", async () => {
      prisma.whatsAppDeliveryRecord.create.mockResolvedValue({
        id: "log-1",
        status: WhatsAppDeliveryStatus.SENT,
      });

      const res = await service.sendNotification("org-1", {
        recipientMobile: "+919876543210",
        recipientName: "Ramesh Sharma",
        recipientEmail: "ramesh@example.com",
        channel: "EMAIL",
        templateCode: "RECEIPT_ISSUED",
      });

      expect(res.status).toBe(WhatsAppDeliveryStatus.SENT);
      expect(res.providerRef).toBe("EMAIL-123");
    });
  });

  describe("In-App Notification Inbox & Templates", () => {
    it("retrieves in-app inbox feed for user", async () => {
      prisma.userNotification.findMany.mockResolvedValue([
        { id: "notif-1", title: "Receipt Generated", isRead: false },
      ]);

      const feed = await service.getUserNotifications("org-1", "user-1", true);
      expect(feed).toHaveLength(1);
      expect(feed[0].isRead).toBe(false);
    });

    it("marks in-app notification as read", async () => {
      prisma.userNotification.findFirst.mockResolvedValue({ id: "notif-1", organizationId: "org-1", userId: "user-1" });
      prisma.userNotification.update.mockResolvedValue({ id: "notif-1", isRead: true });

      const updated = await service.markNotificationAsRead("org-1", "user-1", "notif-1");
      expect(updated.isRead).toBe(true);
    });

    it("creates custom notification template", async () => {
      prisma.notificationTemplate.create.mockResolvedValue({
        id: "tpl-1",
        code: "BILL_ISSUED_V2",
      });

      const tpl = await service.createTemplate("org-1", {
        code: "BILL_ISSUED_V2",
        name: "Bill Issued Template",
        channel: "WHATSAPP",
        bodyPattern: "Hello {{name}}, your bill of {{amount}} is ready.",
      });

      expect(tpl.code).toBe("BILL_ISSUED_V2");
    });
  });
});
