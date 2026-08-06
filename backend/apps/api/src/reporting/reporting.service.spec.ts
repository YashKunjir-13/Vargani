import { Test, TestingModule } from "@nestjs/testing";
import { PrismaService } from "@pauti-pustak/backend-database";
import { NotFoundException } from "@nestjs/common";
import { ReportingService } from "./reporting.service";

describe("ReportingService (Phase 5 Unit Tests)", () => {
  let service: ReportingService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      event: {
        findFirst: jest.fn(),
      },
      collectionRecord: {
        aggregate: jest.fn(),
        findMany: jest.fn(),
        groupBy: jest.fn(),
      },
      expense: {
        aggregate: jest.fn(),
      },
      volunteer: {
        findMany: jest.fn(),
      },
      contributorAccount: {
        findMany: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReportingService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get<ReportingService>(ReportingService);
  });

  describe("Event Financial Summary", () => {
    it("returns summary report with net available and projected balances", async () => {
      prisma.event.findFirst.mockResolvedValue({
        id: "evt-1",
        name: "Ganesh Utsav 2026",
        status: "ACTIVE",
        targetAmountPaise: BigInt(10000000),
      });

      prisma.collectionRecord.aggregate.mockResolvedValue({
        _sum: { amountPaise: BigInt(5000000) },
        _count: { id: 10 },
      });

      prisma.expense.aggregate.mockResolvedValue({
        _sum: { approvedAmountPaise: BigInt(2000000), paidAmountPaise: BigInt(1000000) },
        _count: { id: 2 },
      });

      const summary = await service.getEventFinancialSummary("org-1", "evt-1");

      expect(summary.confirmedCollectionsPaise).toBe("5000000");
      expect(summary.approvedExpensesPaise).toBe("2000000");
      expect(summary.paidExpensesPaise).toBe("1000000");
      expect(summary.netAvailableBalancePaise).toBe("4000000"); // 50k - 10k
      expect(summary.netProjectedBalancePaise).toBe("3000000"); // 50k - 20k
    });

    it("throws NotFoundException if event does not exist", async () => {
      prisma.event.findFirst.mockResolvedValue(null);

      await expect(service.getEventFinancialSummary("org-1", "evt-invalid")).rejects.toThrow(NotFoundException);
    });
  });

  describe("Daily Collection Breakdown", () => {
    it("groups collections date-wise and mode-wise", async () => {
      prisma.collectionRecord.findMany.mockResolvedValue([
        { amountPaise: BigInt(500000), mode: "UPI", collectedAt: new Date("2026-09-01T10:00:00.000Z") },
        { amountPaise: BigInt(200000), mode: "CASH", collectedAt: new Date("2026-09-01T14:00:00.000Z") },
      ]);

      const report = await service.getDailyCollectionReport("org-1", "evt-1");

      expect(report).toHaveLength(1);
      expect(report[0].date).toBe("2026-09-01");
      expect(report[0].totalAmountPaise).toBe("700000");
      expect(report[0].byMode).toEqual({ UPI: "500000", CASH: "200000" });
    });
  });
});
