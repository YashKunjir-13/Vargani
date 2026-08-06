import { Test, TestingModule } from "@nestjs/testing";
import { PrismaService, PublicVisibility } from "@pauti-pustak/backend-database";
import { NotFoundException } from "@nestjs/common";
import { PublicQueryService } from "./public-query.service";

describe("PublicQueryService (Phase 4 Unit Tests)", () => {
  let service: PublicQueryService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      publicEventPage: {
        findUnique: jest.fn(),
      },
      event: {
        findUnique: jest.fn(),
      },
      organization: {
        findUnique: jest.fn(),
      },
      collectionRecord: {
        aggregate: jest.fn(),
        groupBy: jest.fn(),
      },
      contributorAccount: {
        findMany: jest.fn(),
      },
      expense: {
        groupBy: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PublicQueryService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get<PublicQueryService>(PublicQueryService);
  });

  describe("Public Event Overview & Financials", () => {
    it("returns public event overview with calculated live progress", async () => {
      prisma.publicEventPage.findUnique.mockResolvedValue({
        id: "page-1",
        organizationId: "org-1",
        eventId: "evt-1",
        publicSlug: "ganesh-2026",
        status: "PUBLISHED",
        showLiveTotals: true,
        showDonorList: true,
        showExpenseSummary: true,
      });

      prisma.event.findUnique.mockResolvedValue({
        id: "evt-1",
        name: "Ganesh Utsav 2026",
        eventTypeCode: "GANPATI",
        status: "ACTIVE",
        targetAmountPaise: BigInt(10000000), // 100,000 INR
      });

      prisma.organization.findUnique.mockResolvedValue({ id: "org-1", name: "Shiv Mandal" });
      prisma.collectionRecord.aggregate.mockResolvedValue({
        _sum: { amountPaise: BigInt(5000000) }, // 50,000 INR
        _count: { id: 10 },
      });

      const res = await service.getPublicEventPage("ganesh-2026");

      expect(res.eventName).toBe("Ganesh Utsav 2026");
      expect(res.financials?.confirmedCollectionsPaise).toBe("5000000");
      expect(res.financials?.progressPercentage).toBe(50);
    });

    it("throws NotFoundException if public page is not published", async () => {
      prisma.publicEventPage.findUnique.mockResolvedValue({ status: "DRAFT" });

      await expect(service.getPublicEventPage("draft-slug")).rejects.toThrow(NotFoundException);
    });
  });

  describe("Donor Privacy Redactions", () => {
    it("redacts PRIVATE accounts as Well-Wisher and hides individual amount", async () => {
      prisma.publicEventPage.findUnique.mockResolvedValue({
        id: "page-1",
        eventId: "evt-1",
        organizationId: "org-1",
        status: "PUBLISHED",
        showDonorList: true,
      });

      prisma.contributorAccount.findMany.mockResolvedValue([
        { id: "acc-1", displayName: "Ramesh Sharma", publicVisibility: PublicVisibility.NAME_AND_AMOUNT },
        { id: "acc-2", displayName: "Secret Contributor", publicVisibility: PublicVisibility.PRIVATE },
      ]);

      prisma.collectionRecord.groupBy.mockResolvedValue([
        { contributorAccountId: "acc-1", _sum: { amountPaise: BigInt(500000) } },
        { contributorAccountId: "acc-2", _sum: { amountPaise: BigInt(1000000) } },
      ]);

      const list = await service.getPublicEventDonors("ganesh-2026");

      expect(list[0]).toEqual({ displayName: "Ramesh Sharma", amountPaise: "500000", isPrivate: false });
      expect(list[1]).toEqual({ displayName: "Well-Wisher", amountPaise: null, isPrivate: true });
    });
  });

  describe("Category-wise Expense Breakdown", () => {
    it("returns category-wise approved & paid expense summary", async () => {
      prisma.publicEventPage.findUnique.mockResolvedValue({
        id: "page-1",
        eventId: "evt-1",
        organizationId: "org-1",
        status: "PUBLISHED",
        showExpenseSummary: true,
      });

      prisma.expense.groupBy.mockResolvedValue([
        { categoryCode: "DECORATION", _sum: { approvedAmountPaise: BigInt(5000000), paidAmountPaise: BigInt(5000000) } },
        { categoryCode: "SOUND", _sum: { approvedAmountPaise: BigInt(2000000), paidAmountPaise: BigInt(1000000) } },
      ]);

      const summary = await service.getPublicEventExpenses("ganesh-2026");

      expect(summary.totalExpensePaise).toBe("7000000");
      expect(summary.categories).toHaveLength(2);
    });
  });
});
