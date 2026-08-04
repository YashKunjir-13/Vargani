import { Test, TestingModule } from "@nestjs/testing";
import { BillingMode, ContributorAccountStatus, PrismaService } from "@pauti-pustak/backend-database";
import { ForbiddenException, NotFoundException } from "@nestjs/common";
import { ContributorService } from "./contributor.service";

describe("ContributorService (Phase 1 Unit Tests)", () => {
  let service: ContributorService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      contributorAccount: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        updateMany: jest.fn(),
      },
      donorProfile: {
        findUnique: jest.fn(),
      },
      event: {
        findFirst: jest.fn(),
      },
      volunteer: {
        findFirst: jest.fn(),
      },
      contributionBill: {
        count: jest.fn().mockResolvedValue(1),
        updateMany: jest.fn(),
      },
      collectionRecord: {
        count: jest.fn().mockResolvedValue(2),
        updateMany: jest.fn(),
      },
      $transaction: jest.fn((callback) => callback(prisma)),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ContributorService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get<ContributorService>(ContributorService);
  });

  describe("Account Creation & Prospective Collector Reassignment", () => {
    it("creates contributor account with unique code and billing mode", async () => {
      prisma.donorProfile.findUnique.mockResolvedValue({ id: "donor-1", fullName: "Ramesh Sharma", mobile: "+919876543210" });
      prisma.event.findFirst.mockResolvedValue({ id: "evt-1", status: "ACTIVE" });
      prisma.contributorAccount.findUnique.mockResolvedValue(null);
      prisma.contributorAccount.create.mockResolvedValue({
        id: "acc-1",
        organizationId: "org-1",
        eventId: "evt-1",
        donorProfileId: "donor-1",
        accountCode: "ACC-1234",
        type: "INDIVIDUAL",
        status: ContributorAccountStatus.ACTIVE,
        displayName: "Sharma Household",
        requestedAmountPaise: BigInt(500000),
      });

      const res = await service.createAccount("org-1", "evt-1", "user-1", {
        donorProfileId: "donor-1",
        type: "INDIVIDUAL" as any,
        displayName: "Sharma Household",
        requestedAmountPaise: "500000",
      });

      expect(res.accountCode).toBe("ACC-1234");
      expect(res.requestedAmountPaise).toBe("500000");
    });

    it("reassigns collector prospectively", async () => {
      prisma.contributorAccount.findFirst.mockResolvedValue({ id: "acc-1", organizationId: "org-1" });
      prisma.volunteer.findFirst.mockResolvedValue({ id: "vol-1", status: "ACTIVE" });
      prisma.contributorAccount.update.mockResolvedValue({ id: "acc-1", assignedVolunteerId: "vol-1" });

      const res = await service.reassignCollector("org-1", "acc-1", "vol-1");
      expect(res.assignedVolunteerId).toBe("vol-1");
    });
  });

  describe("Merge Preview & Execution", () => {
    it("returns impact preview report for contributor account merge", async () => {
      prisma.contributorAccount.findFirst.mockImplementation(({ where }: any) => {
        if (where.id === "acc-surviving") return Promise.resolve({ id: "acc-surviving", accountCode: "ACC-1", displayName: "Survivor" });
        if (where.id === "acc-merged") return Promise.resolve({ id: "acc-merged", accountCode: "ACC-2", displayName: "Duplicate" });
        return Promise.resolve(null);
      });

      const preview = await service.mergePreview("org-1", "acc-surviving", "acc-merged");
      expect(preview.impactReport.billsToReassign).toBe(1);
      expect(preview.impactReport.collectionsToReassign).toBe(2);
    });
  });
});
