import { Test, TestingModule } from "@nestjs/testing";
import { DonorProfileStatus, PrismaService } from "@pauti-pustak/backend-database";
import { PanEncryptionService } from "@pauti-pustak/backend-security";
import { BadRequestException, ForbiddenException, NotFoundException } from "@nestjs/common";
import { DonorService } from "./donor.service";

describe("DonorService (Phase 1, Self-Profile & Portal Unit Tests)", () => {
  let service: DonorService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      donorProfile: {
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        findMany: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      user: {
        findUnique: jest.fn(),
      },
      organization: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
      },
      event: {
        findMany: jest.fn(),
      },
      contributorAccount: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        create: jest.fn(),
        updateMany: jest.fn(),
      },
      contributionBill: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
      },
      collectionRecord: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
        aggregate: jest.fn(),
      },
      donorAlias: {
        create: jest.fn(),
      },
      donorMergeLog: {
        create: jest.fn(),
      },
      $transaction: jest.fn((callback) => callback(prisma)),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DonorService,
        { provide: PrismaService, useValue: prisma },
        PanEncryptionService,
      ],
    }).compile();

    service = module.get<DonorService>(DonorService);
  });

  describe("Self-Profile Management", () => {
    it("returns existing profile linked to user", async () => {
      const existing = { id: "d-1", userId: "u-1", fullName: "Self Donor" };
      prisma.donorProfile.findUnique.mockResolvedValue(existing);

      const res = await service.getSelfProfile("u-1");
      expect(res).toEqual(existing);
    });

    it("claims existing unclaimed profile if mobile matches user", async () => {
      prisma.donorProfile.findUnique.mockResolvedValue(null);
      prisma.user.findUnique.mockResolvedValue({ id: "u-1", primaryMobile: "+919876543210", displayName: "Ramesh" });
      const candidate = { id: "d-unclaimed", mobile: "+919876543210", status: DonorProfileStatus.UNCLAIMED };
      prisma.donorProfile.findFirst.mockResolvedValue(candidate);
      prisma.donorProfile.update.mockResolvedValue({ ...candidate, userId: "u-1", status: DonorProfileStatus.ACTIVE });

      const res = await service.getSelfProfile("u-1");
      expect(res.userId).toBe("u-1");
    });
  });

  describe("My Organizations & Mandal Selection", () => {
    it("returns list of organizations where donor has accounts", async () => {
      const profile = { id: "d-1", userId: "u-1" };
      prisma.donorProfile.findUnique.mockResolvedValue(profile);
      prisma.contributorAccount.findMany.mockResolvedValue([{ organizationId: "org-1" }]);
      prisma.organization.findMany.mockResolvedValue([{ id: "org-1", name: "Shree Ganesh Mandal" }]);

      const orgs = await service.getDonorOrganizations("u-1");
      expect(orgs.length).toBe(1);
      expect(orgs[0].name).toBe("Shree Ganesh Mandal");
    });

    it("selects organization context if donor belongs to it", async () => {
      const profile = { id: "d-1", userId: "u-1" };
      prisma.donorProfile.findUnique.mockResolvedValue(profile);
      prisma.contributorAccount.findFirst.mockResolvedValue({ id: "acc-1" });
      prisma.organization.findUnique.mockResolvedValue({ id: "org-1", name: "Shree Ganesh Mandal" });

      const res = await service.selectOrganization("u-1", "org-1");
      expect(res.selectedOrganization.name).toBe("Shree Ganesh Mandal");
    });

    it("throws ForbiddenException when selecting organization donor does not belong to", async () => {
      const profile = { id: "d-1", userId: "u-1" };
      prisma.donorProfile.findUnique.mockResolvedValue(profile);
      prisma.contributorAccount.findFirst.mockResolvedValue(null);

      await expect(service.selectOrganization("u-1", "org-999")).rejects.toThrow(ForbiddenException);
    });
  });

  describe("Pending Bills & Checkout Payment", () => {
    it("rejects bill detail access if user does not own bill", async () => {
      const profile = { id: "d-1", userId: "u-1" };
      prisma.donorProfile.findUnique.mockResolvedValue(profile);
      prisma.contributionBill.findUnique.mockResolvedValue({ id: "b-1", contributorAccountId: "acc-other" });
      prisma.contributorAccount.findUnique.mockResolvedValue({ id: "acc-other", donorProfileId: "d-other" });

      await expect(service.getDonorBillDetails("u-1", "b-1")).rejects.toThrow(ForbiddenException);
    });

    it("processes online payment checkout and updates bill status", async () => {
      const profile = { id: "d-1", userId: "u-1", fullName: "Ramesh" };
      prisma.donorProfile.findUnique.mockResolvedValue(profile);
      prisma.contributorAccount.findFirst.mockResolvedValue({ id: "acc-1", donorProfileId: "d-1" });
      prisma.collectionRecord.create.mockResolvedValue({
        id: "col-1",
        amountPaise: BigInt(500000),
        status: "CONFIRMED",
        collectedAt: new Date(),
      });

      const res = await service.checkoutPayment("u-1", {
        organizationId: "org-1",
        eventId: "evt-1",
        amountPaise: "500000",
        mode: "UPI" as any,
      });

      expect(res.collectionRecordId).toBe("col-1");
      expect(res.amountPaise).toBe("500000");
    });
  });

  describe("Donor Aggregation Dashboard & Trust Analytics", () => {
    it("returns aggregated donor portal dashboard metrics", async () => {
      const profile = { id: "d-1", userId: "u-1", fullName: "Ramesh" };
      prisma.donorProfile.findUnique.mockResolvedValue(profile);
      prisma.contributorAccount.findMany.mockResolvedValue([{ id: "acc-1", organizationId: "org-1" }]);
      prisma.collectionRecord.aggregate.mockResolvedValue({ _sum: { amountPaise: BigInt(1500000) }, _count: { id: 3 } });
      prisma.contributionBill.findMany.mockResolvedValue([]);
      prisma.collectionRecord.findMany.mockResolvedValue([
        { id: "col-1", receiptId: "REC-001", organizationId: "org-1", amountPaise: BigInt(500000), mode: "UPI", collectedAt: new Date() },
      ]);

      const res = await service.getDonorDashboard("u-1");
      expect(res.activeMandalsCount).toBe(1);
      expect(res.ytdTotalContributedPaise).toBe("1500000");
      expect(res.recentReceipts.length).toBe(1);
    });

    it("returns trust-wide donor analytics and top donors leaderboard", async () => {
      prisma.contributorAccount.findMany.mockResolvedValue([
        { id: "acc-1", donorProfileId: "d-1", displayName: "Ramesh" },
      ]);
      prisma.collectionRecord.findMany.mockResolvedValue([
        { contributorAccountId: "acc-1", amountPaise: BigInt(2000000), mode: "UPI" },
      ]);

      const res = await service.getTrustDonorAnalytics("org-1");
      expect(res.totalDonorsCount).toBe(1);
      expect(res.totalCollectionsPaise).toBe("2000000");
      expect(res.topDonorsLeaderboard[0].displayName).toBe("Ramesh");
    });

    it("returns detailed trust-wide history for a specific donor profile", async () => {
      const profile = { id: "d-1", fullName: "Ramesh" };
      prisma.donorProfile.findUnique.mockResolvedValue(profile);
      prisma.contributorAccount.findMany.mockResolvedValue([{ id: "acc-1", donorProfileId: "d-1", requestedAmountPaise: BigInt(500000) }]);
      prisma.contributionBill.findMany.mockResolvedValue([]);
      prisma.collectionRecord.findMany.mockResolvedValue([]);

      const res = await service.getTrustDonorHistory("org-1", "d-1");
      expect(res.donorProfile.fullName).toBe("Ramesh");
      expect(res.contributorAccounts.length).toBe(1);
    });
  });
});
