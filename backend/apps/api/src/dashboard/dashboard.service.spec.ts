import { Test, TestingModule } from "@nestjs/testing";
import { PrismaService } from "@pauti-pustak/backend-database";
import { DashboardService } from "./dashboard.service";

describe("DashboardService", () => {
  let service: DashboardService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      event: {
        count: jest.fn().mockResolvedValue(3),
        findMany: jest.fn().mockResolvedValue([
          {
            id: "evt-1",
            code: "ORG1-2026-001",
            name: "Ganesh Utsav 2026",
            status: "ACTIVE",
            targetAmountPaise: BigInt(5000000),
          },
        ]),
      },
      volunteer: {
        count: jest.fn().mockResolvedValue(12),
        findMany: jest.fn().mockResolvedValue([
          { id: "vol-1", volunteerCode: "VOL-001", fullName: "Rahul Sharma", type: "COLLECTOR" },
        ]),
      },
      collectionRecord: {
        aggregate: jest.fn().mockResolvedValue({
          _sum: { amountPaise: BigInt(2500000) },
          _count: { id: 15 },
        }),
        findMany: jest.fn().mockResolvedValue([
          { id: "c-1", amountPaise: BigInt(1500000), mode: "UPI", status: "CONFIRMED", createdAt: new Date(), collectedAt: new Date() },
        ]),
        groupBy: jest.fn().mockResolvedValue([
          { collectorVolunteerId: "vol-1", _sum: { amountPaise: BigInt(1500000) }, _count: { id: 8 } },
        ]),
        count: jest.fn().mockResolvedValue(2),
      },
      expense: {
        aggregate: jest.fn().mockResolvedValue({
          _sum: { approvedAmountPaise: BigInt(1000000), paidAmountPaise: BigInt(500000) },
          _count: { id: 4 },
        }),
        findMany: jest.fn().mockResolvedValue([]),
      },
      contributionBill: {
        aggregate: jest.fn().mockResolvedValue({
          _sum: { requestedAmountPaise: BigInt(300000) },
          _count: { id: 2 },
        }),
      },
      contributorAccount: {
        count: jest.fn().mockResolvedValue(5),
      },
      auditLog: {
        findMany: jest.fn().mockResolvedValue([
          {
            id: "audit-1",
            actionType: "LOGIN_SUCCESS",
            performedByUserId: "user-1",
            targetType: "auth_identities",
            targetId: "ident-1",
            createdAt: new Date(),
          },
        ]),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DashboardService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get<DashboardService>(DashboardService);
  });

  it("calculates Executive Dashboard KPIs", async () => {
    const res = await service.getExecutiveDashboard("org-1");

    expect(res.activeEventsCount).toBe(3);
    expect(res.activeVolunteersCount).toBe(12);
    expect(res.totalCollectionsPaise).toBe("2500000");
    expect(res.paidExpensesPaise).toBe("500000");
    expect(res.netLiquidityBalancePaise).toBe("2000000");
  });

  it("calculates Finance & Treasury Dashboard KPIs", async () => {
    const res = await service.getFinanceDashboard("org-1");

    expect(res.totalCollectionsPaise).toBe("1500000");
    expect(res.collectionsByMode["UPI"]).toBe("1500000");
    expect(res.outstandingBillsCount).toBe(2);
    expect(res.availableCashBalancePaise).toBe("1000000");
  });

  it("returns Event Operations Dashboard list", async () => {
    const res = await service.getEventsDashboard("org-1");

    expect(res.events.length).toBe(1);
    expect(res.events[0].code).toBe("ORG1-2026-001");
    expect(res.events[0].progressPercentage).toBe(50);
  });

  it("calculates Volunteer Operations Dashboard leaderboard", async () => {
    const res = await service.getVolunteersDashboard("org-1");

    expect(res.activeVolunteersCount).toBe(1);
    expect(res.leaderboard[0].volunteerCode).toBe("VOL-001");
    expect(res.leaderboard[0].totalCollectedPaise).toBe("1500000");
  });

  it("returns Desk Operations Dashboard metrics", async () => {
    const res = await service.getOperationsDashboard("org-1");

    expect(res.pendingDraftsCount).toBe(2);
    expect(res.todayCollectionsCount).toBe(15);
  });

  it("returns Compliance & Audit Dashboard stream", async () => {
    const res = await service.getAuditDashboard("org-1");

    expect(res.auditLogStream.length).toBe(1);
    expect(res.taxExemptDonorsCount).toBe(5);
  });

  it("returns financial trend chart series", async () => {
    const res = await service.getFinancialTrendChart("org-1");
    expect(res.series.length).toBe(12);
  });

  it("returns mode breakdown chart metrics", async () => {
    const res = await service.getModeBreakdownChart("org-1");
    expect(res.grandTotalPaise).toBe("1500000");
    expect(res.breakdown[0].mode).toBe("UPI");
  });

  it("returns recent operations stream paginated items", async () => {
    const res = await service.getRecentOperationsStream("org-1");
    expect(res.items.length).toBe(1);
    expect(res.total).toBe(2);
  });

  it("returns active events progress summary table dataset", async () => {
    const res = await service.getEventsProgressTable("org-1");
    expect(res.items.length).toBe(1);
    expect(res.items[0].progressPercentage).toBe(50);
  });

  it("returns compliance audit stream paginated items", async () => {
    prisma.paymentReceiptAuditEvent = {
      count: jest.fn().mockResolvedValue(1),
      findMany: jest.fn().mockResolvedValue([{ id: "ae-1", actionType: "REPLACED" }]),
    };
    const res = await service.getAuditStream("org-1");
    expect(res.items.length).toBe(1);
    expect(res.items[0].actionType).toBe("REPLACED");
  });

  it("returns volunteer performance leaderboard paginated items", async () => {
    const res = await service.getVolunteersLeaderboard("org-1");
    expect(res.items.length).toBe(1);
    expect(res.items[0].volunteerCode).toBe("VOL-001");
  });
});
