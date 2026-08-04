import { Test, TestingModule } from "@nestjs/testing";
import { DonorProfileStatus, PrismaService } from "@pauti-pustak/backend-database";
import { PanEncryptionService } from "@pauti-pustak/backend-security";
import { BadRequestException, ConflictException } from "@nestjs/common";
import { DonorService } from "./donor.service";

describe("DonorService (Phase 1 Unit Tests)", () => {
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
      contributorAccount: {
        findMany: jest.fn(),
        updateMany: jest.fn(),
      },
      donorAlias: {
        create: jest.fn(),
      },
      donorMergeLog: {
        create: jest.fn(),
      },
      collectionRecord: {
        findMany: jest.fn(),
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

  describe("Candidate Match & Creation", () => {
    it("rejects creation if neither mobile nor email is provided", async () => {
      await expect(
        service.createDonor("u-1", "org-1", { fullName: "Anonymous Donor" }),
      ).rejects.toThrow(BadRequestException);
    });

    it("returns existing candidate profile if mobile match is found", async () => {
      const existing = { id: "d-existing", fullName: "Ramesh", mobile: "+919876543210" };
      prisma.donorProfile.findFirst.mockResolvedValue(existing);

      const res = await service.createDonor("u-1", "org-1", {
        fullName: "Ramesh Sharma",
        mobile: "+919876543210",
      });

      expect(res).toEqual(existing);
      expect(prisma.donorProfile.create).not.toHaveBeenCalled();
    });
  });

  describe("Duplicate Profile Merging", () => {
    it("re-points contributor accounts, creates merge log and alias, and deactivates duplicate", async () => {
      const surviving = { id: "d-surviving", fullName: "Survivor", status: DonorProfileStatus.ACTIVE, mobile: "+919876543210" };
      const merged = { id: "d-merged", fullName: "Duplicate", status: DonorProfileStatus.UNCLAIMED, mobile: "+919876543211" };

      prisma.donorProfile.findUnique.mockImplementation(({ where }: any) => {
        if (where.id === "d-surviving") return Promise.resolve(surviving);
        if (where.id === "d-merged") return Promise.resolve(merged);
        return Promise.resolve(null);
      });

      prisma.contributorAccount.updateMany.mockResolvedValue({ count: 2 });
      prisma.donorMergeLog.create.mockResolvedValue({ id: "log-1" });

      const res = await service.mergeDonors("admin-1", {
        survivingDonorId: "d-surviving",
        mergedDonorId: "d-merged",
        reason: "Duplicate entry offline",
      });

      expect(res.reassignedAccountsCount).toBe(2);
      expect(prisma.donorAlias.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          survivingDonorId: "d-surviving",
          mergedDonorId: "d-merged",
          previousMobile: "+919876543211",
        }),
      });
      expect(prisma.donorProfile.update).toHaveBeenCalledWith({
        where: { id: "d-merged" },
        data: expect.objectContaining({ status: DonorProfileStatus.MERGED }),
      });
    });
  });
});
