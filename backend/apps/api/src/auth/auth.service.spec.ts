/**
 * AuthService — Unit Tests
 *
 * Structure: GIVEN-WHEN-THEN behavioral contracts.
 * Mock source: @pauti-pustak/backend-testing (no inline mock construction).
 */
import { Test, TestingModule } from "@nestjs/testing";
import { JwtService } from "@nestjs/jwt";
import { OtpPurpose, PrismaService } from "@pauti-pustak/backend-database";
import { HashingService, PanEncryptionService } from "@pauti-pustak/backend-security";
import { ForbiddenException, UnauthorizedException } from "@nestjs/common";
import {
  createMockPrisma,
  createMockUser,
  TEST_USER_TREASURER,
} from "@pauti-pustak/backend-testing";
import { AuthService } from "./auth.service";
import { AuditService } from "../audit/audit.service";

describe("AuthService", () => {
  let service: AuthService;
  let prisma: ReturnType<typeof createMockPrisma>;
  let hashingService: HashingService;
  let auditService: AuditService;

  beforeEach(async () => {
    prisma = createMockPrisma([
      "user",
      "authIdentity",
      "otpChallenge",
      "refreshSession",
      "organizationMembership",
      "donorProfile",
    ]);

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
    it("GIVEN a valid phone number WHEN requestOtp is called THEN creates rate-limited challenge and hashes OTP with Argon2id", async () => {
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

    it("GIVEN 5 recent OTP requests within 15 minutes WHEN requestOtp is called THEN throws ForbiddenException (rate limit)", async () => {
      prisma.otpChallenge.count.mockResolvedValue(5);

      await expect(
        service.requestOtp({
          phoneNumber: "+919876543210",
          purpose: OtpPurpose.LOGIN,
        }),
      ).rejects.toThrow(ForbiddenException);
    });

    it("GIVEN a valid OTP challenge WHEN verifyOtp is called THEN marks challenge consumed and issues access/refresh sessions", async () => {
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

      prisma.user.findFirst.mockResolvedValue(
        createMockUser({
          id: TEST_USER_TREASURER,
          displayName: "Test User",
          primaryMobile: "+919876543210",
        }),
      );
      prisma.user.findUniqueOrThrow.mockResolvedValue(
        createMockUser({
          id: TEST_USER_TREASURER,
        }),
      );
      prisma.refreshSession.create.mockResolvedValue({ id: "s-1" });

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
    it("GIVEN 4 previous failed logins WHEN 5th failure occurs THEN locks the account and throws UnauthorizedException", async () => {
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
    it("GIVEN a REVOKED refresh token WHEN reuse is attempted THEN marks entire token family COMPROMISED", async () => {
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

  describe("MPIN Authentication & Governance", () => {
    it("GIVEN a valid 6-digit MPIN WHEN createMpin is called THEN hashes MPIN with Argon2id and clears lockout state", async () => {
      prisma.authIdentity.findFirst.mockResolvedValue({
        id: "ident-1",
        userId: TEST_USER_TREASURER,
      });
      prisma.authIdentity.update.mockResolvedValue({ id: "ident-1" });

      const res = await service.createMpin(TEST_USER_TREASURER, { mpin: "123456" });
      expect(res.hasMpin).toBe(true);
      expect(prisma.authIdentity.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: "ident-1" },
          data: expect.objectContaining({
            failedMpinCount: 0,
            mpinLockedUntil: null,
          }),
        }),
      );
    });

    it("GIVEN correct MPIN credentials WHEN loginMpin is called THEN issues access token and logs audit success", async () => {
      const mpinHash = await hashingService.hashPassword("123456");
      prisma.authIdentity.findFirst.mockResolvedValue({
        id: "ident-1",
        userId: "u-1",
        mpinHash,
        failedMpinCount: 0,
        mpinLockedUntil: null,
        user: {
          id: "u-1",
          displayName: "MPIN User",
          primaryMobile: "9876543210",
          platformRole: "USER",
          status: "ACTIVE",
          tokenVersion: 1,
        },
      });
      prisma.user.findUniqueOrThrow.mockResolvedValue({ id: "u-1", tokenVersion: 1 });
      prisma.refreshSession.create.mockResolvedValue({ id: "s-1" });

      const res = await service.loginMpin({
        phoneNumber: "9876543210",
        mpin: "123456",
        role: "DONOR",
      });

      expect(res.accessToken).toBe("jwt.test.token");
      expect(res.hasMpin).toBe(true);
      expect(auditService.log).toHaveBeenCalledWith(
        expect.objectContaining({ action: "LOGIN_SUCCESS", outcome: "SUCCESS" }),
      );
    });

    it("GIVEN incorrect MPIN WHEN loginMpin is called THEN increments failedMpinCount and throws UnauthorizedException", async () => {
      const mpinHash = await hashingService.hashPassword("123456");
      prisma.authIdentity.findFirst.mockResolvedValue({
        id: "ident-1",
        userId: "u-1",
        mpinHash,
        failedMpinCount: 2,
        mpinLockedUntil: null,
        user: { id: "u-1", status: "ACTIVE" },
      });

      await expect(
        service.loginMpin({
          phoneNumber: "9876543210",
          mpin: "999999",
          role: "DONOR",
        }),
      ).rejects.toThrow(UnauthorizedException);

      expect(prisma.authIdentity.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: "ident-1" },
          data: expect.objectContaining({ failedMpinCount: 3 }),
        }),
      );
    });

    it("GIVEN 4 previous MPIN failures WHEN 5th failure occurs THEN locks MPIN for 15 mins and throws ForbiddenException", async () => {
      const mpinHash = await hashingService.hashPassword("123456");
      prisma.authIdentity.findFirst.mockResolvedValue({
        id: "ident-1",
        userId: "u-1",
        mpinHash,
        failedMpinCount: 4,
        mpinLockedUntil: null,
        user: { id: "u-1", status: "ACTIVE" },
      });

      await expect(
        service.loginMpin({
          phoneNumber: "9876543210",
          mpin: "000000",
          role: "DONOR",
        }),
      ).rejects.toThrow(ForbiddenException);

      expect(prisma.authIdentity.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: "ident-1" },
          data: expect.objectContaining({
            failedMpinCount: 5,
            mpinLockedUntil: expect.any(Date),
          }),
        }),
      );
    });

    it("GIVEN valid MPIN reset OTP challenge WHEN verifyMpinReset is called THEN sets new MPIN and revokes all active sessions", async () => {
      const otpHash = await hashingService.hashPassword("123456");
      prisma.otpChallenge.findFirst.mockResolvedValue({
        id: "otp-mpin-1",
        normalizedMobile: "9876543210",
        purpose: OtpPurpose.MPIN_RESET,
        otpHash,
        attemptCount: 0,
        maxAttempts: 5,
        expiresAt: new Date(Date.now() + 300000),
        consumedAt: null,
      });

      prisma.authIdentity.findFirst.mockResolvedValue({
        id: "ident-1",
        userId: "u-1",
        user: {
          id: "u-1",
          displayName: "MPIN Reset User",
          primaryMobile: "9876543210",
          platformRole: "USER",
          status: "ACTIVE",
          tokenVersion: 1,
        },
      });
      prisma.user.findUniqueOrThrow.mockResolvedValue({ id: "u-1", tokenVersion: 1 });
      prisma.refreshSession.create.mockResolvedValue({ id: "s-1" });

      const res = await service.verifyMpinReset({
        phoneNumber: "9876543210",
        otp: "123456",
        newMpin: "654321",
        role: "MANDAL",
      });

      expect(res.accessToken).toBe("jwt.test.token");
      expect(prisma.refreshSession.updateMany).toHaveBeenCalledWith({
        where: { userId: "u-1", status: "ACTIVE" },
        data: expect.objectContaining({ status: "REVOKED", revocationReason: "MPIN reset via OTP" }),
      });
    });
  });
});
