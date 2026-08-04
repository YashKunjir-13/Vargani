import { Test, TestingModule } from "@nestjs/testing";
import { EventStatus, PrismaService } from "@pauti-pustak/backend-database";
import { BadRequestException, ForbiddenException } from "@nestjs/common";
import { EventService } from "./event.service";

describe("EventService (Phase 1 Unit Tests)", () => {
  let service: EventService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      event: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      organization: {
        findUnique: jest.fn(),
      },
      collectionRecord: {
        aggregate: jest.fn().mockResolvedValue({ _sum: { amountPaise: BigInt(500000) } }),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        EventService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get<EventService>(EventService);
  });

  describe("Event Creation & Balances", () => {
    it("creates draft event with unique code and returns balance calculations", async () => {
      prisma.organization.findUnique.mockResolvedValue({ code: "ORG1" });
      prisma.event.findUnique.mockResolvedValue(null);
      prisma.event.create.mockResolvedValue({
        id: "evt-1",
        organizationId: "org-1",
        code: "ORG1-2026-123",
        name: "Ganesh Utsav 2026",
        status: EventStatus.DRAFT,
        targetAmountPaise: BigInt(5000000),
      });

      const res = await service.createEvent("org-1", "user-1", {
        eventTypeCode: "GANPATI",
        name: "Ganesh Utsav 2026",
        financialYearStart: 2026,
        targetAmountPaise: "5000000",
      });

      expect(res.id).toBe("evt-1");
      expect(res.confirmedCollectionsPaise).toBe("500000");
      expect(res.availableBalancePaise).toBe("500000");
    });
  });

  describe("Lifecycle State Machine", () => {
    it("enforces DRAFT -> ACTIVE transition", async () => {
      prisma.event.findFirst.mockResolvedValue({
        id: "evt-1",
        organizationId: "org-1",
        status: EventStatus.DRAFT,
      });
      prisma.event.update.mockResolvedValue({
        id: "evt-1",
        status: EventStatus.ACTIVE,
      });

      const res = await service.activateEvent("org-1", "evt-1", "owner-1");
      expect(res.status).toBe(EventStatus.ACTIVE);
    });

    it("rejects invalid direct transition (DRAFT -> COMPLETED)", async () => {
      prisma.event.findFirst.mockResolvedValue({
        id: "evt-1",
        organizationId: "org-1",
        status: EventStatus.DRAFT,
      });

      await expect(service.completeEvent("org-1", "evt-1", "owner-1")).rejects.toThrow(BadRequestException);
    });

    it("allows reopening FINANCIALLY_CLOSED -> ACTIVE with mandatory reason", async () => {
      prisma.event.findFirst.mockResolvedValue({
        id: "evt-1",
        organizationId: "org-1",
        status: EventStatus.FINANCIALLY_CLOSED,
      });
      prisma.event.update.mockResolvedValue({
        id: "evt-1",
        status: EventStatus.ACTIVE,
      });

      const res = await service.reopenEvent("org-1", "evt-1", "owner-1", {
        reason: "Reopening to process late collections",
      });

      expect(res.status).toBe(EventStatus.ACTIVE);
      expect(prisma.event.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: "evt-1" },
          data: expect.objectContaining({ reopenedReason: "Reopening to process late collections" }),
        }),
      );
    });

    it("blocks updating archived events", async () => {
      prisma.event.findFirst.mockResolvedValue({
        id: "evt-archived",
        organizationId: "org-1",
        status: EventStatus.ARCHIVED,
      });

      await expect(
        service.updateEvent("org-1", "evt-archived", { name: "New Name" }),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
