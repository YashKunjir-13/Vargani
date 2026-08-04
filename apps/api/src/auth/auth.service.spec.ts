import { Test, TestingModule } from "@nestjs/testing";
import { JwtService } from "@nestjs/jwt";
import { AuthProvider, OtpPurpose, PrismaService } from "@pauti-pustak/backend-database";
import { HashingService, PanEncryptionService } from "@pauti-pustak/backend-security";
import { BadRequestException, ForbiddenException, UnauthorizedException } from "@nestjs/common";
import { AuthService } from "./auth.service";
import { AuditService } from "../audit/audit.service";

describe("AuthService (Phase 0 Unit Tests)", () => {
  let service: AuthService;
  let prisma: any;
  let hashingService: HashingService;
  let auditService: AuditService;

  beforeEach(async () => {
    prisma = {
      user: {
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        findUniqueOrThrow: jest.fn(),
        create: jest.fn(),
      },
      authIdentity: {
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        updateMany: jest.fn(),
      },
      otpChallenge: {
        count: jest.fn().mockResolvedValue(0),
        create: jest.fn(),
        findFirst: jest.fn(),
        update: jest.fn(),
      },
      refreshSession: {
        create: jest.fn().mockResolvedValue({ id: "s-1" }),
        findFirst: jest.fn(),
        update: jest.fn(),
        updateMany: jest.fn(),
      },
      organizationMembership: {
        findFirst: jest.fn().mockResolvedValue(null),
      },
      donorProfile: {
        findUnique: jest.fn().mockResolvedValue(null),
      },
      $transaction: jest.fn((callback) => callback(prisma)),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: prisma },
        {
          provide: JwtService,
          useValue: { signAsync: jest.fn().mockResolvedValue("jwt.test.token") },
        },
        {
          provide: AuditService,
          useValue: { log: jest.fn().mockResolvedValue({ id: "audit-1" }) },
        },
        HashingService,
        PanEncryptionService,
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    hashingService = module.get<HashingService>(HashingService);
    auditService = module.get<AuditService>(AuditService);
  });

  describe("OTP Challenges", () => {
    it("creates a rate-limited OTP challenge and hashes OTP with Argon2id", async () => {
      prisma.otpChallenge.create.mockResolvedValue({
        id: "otp-123",
        expiresAt: new Date(Date.now() + 300000),
      });

      const res = await service.requestOtp({
        phoneNumber: "+919876543210",
        purpose: OtpPurpose.LOGIN,
      });

      expect(res.challengeId).toBe("otp-123");
      expect(prisma.otpChallenge.create).toHaveBeenCalled();
      const createData = prisma.otpChallenge.create.mock.calls[0][0].data;
      expect(createData.otpHash).toBeDefined();
      expect(createData.otpHash).not.toBe("123456");
    });

    it("rejects OTP request if 5 recent requests exist in 15 mins", async () => {
      prisma.otpChallenge.count.mockResolvedValue(5);

      await expect(
        service.requestOtp({
          phoneNumber: "+919876543210",
          purpose: OtpPurpose.LOGIN,
        }),
      ).rejects.toThrow(ForbiddenException);
    });

    it("verifies OTP and issues access/refresh sessions", async () => {
      const otpHash = await hashingService.hashPassword("123456");
      prisma.otpChallenge.findFirst.mockResolvedValue({
        id: "otp-1",
        normalizedMobile: "+919876543210",
        purpose: OtpPurpose.LOGIN,
        otpHash,
        attemptCount: 0,
        maxAttempts: 5,
        expiresAt: new Date(Date.now() + 300000),
        consumedAt: null,
      });

      prisma.user.findFirst.mockResolvedValue({
        id: "usr-1",
        displayName: "Test User",
        primaryMobile: "+919876543210",
        platformRole: "USER",
        status: "ACTIVE",
        tokenVersion: 1,
      });
      prisma.user.findUniqueOrThrow.mockResolvedValue({
        id: "usr-1",
        platformRole: "USER",
        tokenVersion: 1,
      });

      const res = await service.verifyOtp({
        phoneNumber: "+919876543210",
        otp: "123456",
        purpose: OtpPurpose.LOGIN,
      });

      expect(res.accessToken).toBe("jwt.test.token");
      expect(res.refreshToken).toBeDefined();
      expect(prisma.otpChallenge.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: "otp-1" },
          data: { consumedAt: expect.any(Date) },
        }),
      );
    });
  });

  describe("Password Login & Lockout", () => {
    it("locks account after 5 consecutive password failures", async () => {
      const passwordHash = await hashingService.hashPassword("CorrectPass#123");
      prisma.authIdentity.findFirst.mockResolvedValue({
        id: "ident-1",
        passwordHash,
        failedLoginCount: 4,
        lockedUntil: null,
        user: { id: "u-1", status: "ACTIVE" },
      });

      await expect(
        service.login({
          phoneNumber: "+919876543210",
          password: "WrongPassword#123",
          role: "DONOR",
        }),
      ).rejects.toThrow(UnauthorizedException);

      expect(prisma.authIdentity.update).toHaveBeenCalledWith({
        where: { id: "ident-1" },
        data: { failedLoginCount: 5, lockedUntil: expect.any(Date) },
      });
    });
  });

  describe("Refresh Token Family Reuse Detection", () => {
    it("marks entire token family COMPROMISED on reuse detection", async () => {
      prisma.refreshSession.findFirst.mockResolvedValue({
        id: "sess-revoked",
        tokenFamilyId: "family-999",
        status: "REVOKED",
        expiresAt: new Date(Date.now() + 100000),
        user: { id: "u-1", status: "ACTIVE" },
      });

      await expect(
        service.refresh({ refreshToken: "revoked-token-value" }),
      ).rejects.toThrow(ForbiddenException);

      expect(prisma.refreshSession.updateMany).toHaveBeenCalledWith({
        where: { tokenFamilyId: "family-999" },
        data: { status: "COMPROMISED", revocationReason: "reuse_detected" },
      });
    });
  });
});
