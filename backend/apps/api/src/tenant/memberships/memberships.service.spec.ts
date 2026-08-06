import { Test, TestingModule } from "@nestjs/testing";
import { MembershipStatus, PrismaService } from "@pauti-pustak/backend-database";
import { HashingService } from "@pauti-pustak/backend-security";
import { ConflictException, ForbiddenException } from "@nestjs/common";
import { MembershipsService } from "./memberships.service";

describe("MembershipsService (Phase 0 Unit Tests)", () => {
  let service: MembershipsService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      organizationMembership: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      organizationInvitation: {
        create: jest.fn(),
        findFirst: jest.fn(),
        update: jest.fn(),
      },
      organizationRole: {
        findFirst: jest.fn(),
      },
      organization: {
        update: jest.fn(),
      },
      user: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
        findUniqueOrThrow: jest.fn(),
        create: jest.fn(),
      },
      authIdentity: {
        findFirst: jest.fn(),
        create: jest.fn(),
      },
      refreshSession: {
        updateMany: jest.fn(),
      },
      $transaction: jest.fn((callback) => (typeof callback === "function" ? callback(prisma) : Promise.all(callback))),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MembershipsService,
        { provide: PrismaService, useValue: prisma },
        HashingService,
      ],
    }).compile();

    service = module.get<MembershipsService>(MembershipsService);
  });

  describe("Single Active Membership Constraint (FR45)", () => {
    it("rejects direct member creation if user already has an active membership elsewhere", async () => {
      prisma.organizationRole.findFirst.mockResolvedValue({ id: "r-1", name: "Member" });
      prisma.authIdentity.findFirst.mockResolvedValue({ userId: "u-existing" });
      prisma.user.findUnique.mockResolvedValue({ id: "u-existing", displayName: "Existing User" });
      prisma.organizationMembership.findFirst.mockResolvedValue({
        id: "m-active-elsewhere",
        organizationId: "org-other",
        status: MembershipStatus.ACTIVE,
      });

      await expect(
        service.createDirectMember("org-1", "owner-1", {
          displayName: "Existing User",
          mobile: "+919876543210",
          roleId: "r-1",
        }),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe("Atomic Ownership Transfer", () => {
    it("transfers ownership atomically and updates ownerUserId", async () => {
      prisma.organizationMembership.findFirst.mockImplementation(({ where }: any) => {
        if (where.isOwner) {
          return Promise.resolve({ id: "m-owner", organizationId: "org-1", userId: "owner-1", isOwner: true });
        }
        if (where.userId === "member-1") {
          return Promise.resolve({ id: "m-target", organizationId: "org-1", userId: "member-1", isOwner: false });
        }
        return Promise.resolve(null);
      });

      prisma.organizationRole.findFirst.mockImplementation(({ where }: any) => {
        if (where.isOwnerRole) {
          return Promise.resolve({ id: "role-owner", isOwnerRole: true });
        }
        return Promise.resolve({ id: "role-president", name: "President", isOwnerRole: false });
      });

      const res = await service.transferOwnership("org-1", "owner-1", {
        newOwnerUserId: "member-1",
        reason: "Elected new President for 2026",
      });

      expect(res.newOwnerUserId).toBe("member-1");
      expect(prisma.organizationMembership.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: "m-target" },
          data: expect.objectContaining({ isOwner: true }),
        }),
      );
      expect(prisma.organizationMembership.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: "m-owner" },
          data: expect.objectContaining({ isOwner: false }),
        }),
      );
      expect(prisma.organization.update).toHaveBeenCalledWith({
        where: { id: "org-1" },
        data: { ownerUserId: "member-1" },
      });
    });
  });
});
