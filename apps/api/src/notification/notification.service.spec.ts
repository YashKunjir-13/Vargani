import { Test, TestingModule } from "@nestjs/testing";
import { PrismaService, WhatsAppDeliveryStatus } from "@pauti-pustak/backend-database";
import { NotificationService } from "./notification.service";

describe("NotificationService (Phase 5 Unit Tests)", () => {
  let service: NotificationService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      whatsAppDeliveryRecord: {
        create: jest.fn(),
        findMany: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get<NotificationService>(NotificationService);
  });

  describe("Notification Dispatch & Logging", () => {
    it("dispatches notification and creates delivery record", async () => {
      prisma.whatsAppDeliveryRecord.create.mockResolvedValue({
        id: "log-1",
        status: WhatsAppDeliveryStatus.SENT,
      });

      const res = await service.sendNotification("org-1", {
        recipientMobile: "+919876543210",
        recipientName: "Ramesh Sharma",
        channel: "WHATSAPP",
        templateCode: "RECEIPT_ISSUED",
      });

      expect(res.status).toBe(WhatsAppDeliveryStatus.SENT);
      expect(prisma.whatsAppDeliveryRecord.create).toHaveBeenCalled();
    });
  });
});
