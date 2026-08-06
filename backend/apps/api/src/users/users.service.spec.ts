import { Test, TestingModule } from "@nestjs/testing";
import { PrismaService, UserStatus } from "@pauti-pustak/backend-database";
import { HashingService, PlatformRole } from "@pauti-pustak/backend-security";
import { ConflictException, ForbiddenException, NotFoundException } from "@nestjs/common";
import { UsersService } from "./users.service";

describe("UsersService (Phase 0 Unit Tests)", () => {
  let service: UsersService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      user: {
        findUnique: jest.fn(),
        findFirst: jest.fn(),
        update: jest.fn(),
        create: jest.fn(),
      },
      authIdentity: {
        findFirst: jest.fn(),
        create: jest.fn(),
      },
      otpChallenge: {
        create: jest.fn().mockResolvedValue({ id: "otp-ch-1" }),
      },
      organizationMembership: {
        findFirst: jest.fn().mockResolvedValue(null),
      },
      refreshSession: {
        updateMany: jest.fn(),
      },
      $transaction: jest.fn((callback) => callback(prisma)),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: PrismaService, useValue: prisma },
        HashingService,
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  describe("getMe", () => {
    it("returns user profile and active context", async () => {
      prisma.user.findUnique.mockResolvedValue({
        id: "u-1",
        displayName: "User One",
        primaryMobile: "+919876543210",
        primaryEmail: "user@example.com",
        preferredLanguage: "EN",
        platformRole: PlatformRole.USER,
        status: UserStatus.ACTIVE,
        createdAt: new Date(),
        identities: [],
      });

      const res = await service.getMe("u-1");
      expect(res.id).toBe("u-1");
      expect(res.displayName).toBe("User One");
    });
  });

  describe("Contact Change Verification", () => {
    it("initiates email change verification challenge", async () => {
      prisma.user.findFirst.mockResolvedValue(null);

      const res = await service.beginEmailChange("u-1", { newEmail: "new@example.com" });
      expect(res.challengeId).toBe("otp-ch-1");
      expect(prisma.otpChallenge.create).toHaveBeenCalled();
    });

    it("rejects email change if email is already in use", async () => {
      prisma.user.findFirst.mockResolvedValue({ id: "u-other" });

      await expect(
        service.beginEmailChange("u-1", { newEmail: "existing@example.com" }),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe("Platform Administrative Control", () => {
    it("deactivates user and invalidates all active sessions", async () => {
      prisma.user.findUnique.mockResolvedValue({ id: "u-2", platformRole: PlatformRole.USER });
      prisma.user.update.mockResolvedValue({
        id: "u-2",
        status: UserStatus.DEACTIVATED,
        deactivatedAt: new Date(),
        deactivationReason: "Violation",
      });

      const res = await service.updatePlatformUserStatus("u-2", {
        status: UserStatus.DEACTIVATED,
        reason: "Violation of guidelines",
      });

      expect(res.status).toBe(UserStatus.DEACTIVATED);
      expect(prisma.refreshSession.updateMany).toHaveBeenCalledWith({
        where: { userId: "u-2", status: "ACTIVE" },
        data: expect.objectContaining({ status: "REVOKED" }),
      });
    });

    it("prevents deactivating Platform Super Admin accounts", async () => {
      prisma.user.findUnique.mockResolvedValue({ id: "u-admin", platformRole: PlatformRole.SUPER_ADMIN });

      await expect(
        service.updatePlatformUserStatus("u-admin", {
          status: UserStatus.DEACTIVATED,
          reason: "Attempted deactivation",
        }),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
