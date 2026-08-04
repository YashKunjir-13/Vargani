import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { AuthProvider, OtpPurpose, PrismaService } from "@pauti-pustak/backend-database";
import {
  HashingService,
  JwtAccessTokenPayload,
  PanEncryptionService,
  PlatformRole,
} from "@pauti-pustak/backend-security";
import { createHash, randomBytes, randomInt } from "crypto";
import { LoginDto } from "./dto/login.dto";
import { OtpRequestDto } from "./dto/otp-request.dto";
import { OtpVerifyDto } from "./dto/otp-verify.dto";
import { PasswordForgotDto } from "./dto/password-forgot.dto";
import { PasswordResetDto } from "./dto/password-reset.dto";
import { RefreshTokenDto } from "./dto/refresh-token.dto";
import { RegisterDonorDto } from "./dto/register-donor.dto";
import { RegisterTrustDto } from "./dto/register-trust.dto";
import { CreateMpinDto } from "./dto/create-mpin.dto";
import { LoginMpinDto } from "./dto/login-mpin.dto";
import { ChangeMpinDto } from "./dto/change-mpin.dto";
import { ForgotMpinDto } from "./dto/forgot-mpin.dto";
import { VerifyMpinResetDto } from "./dto/verify-mpin-reset.dto";
import { AuditService } from "../audit/audit.service";

const MAX_FAILED_ATTEMPTS = 5;
const LOCKOUT_MINUTES = 15;
const OTP_EXPIRATION_MINUTES = 5;
const MAX_OTP_ATTEMPTS = 5;
const INVALID_CREDENTIALS_MESSAGE = "Invalid credentials";

export interface IssuedSession {
  accessToken: string;
  refreshToken: string;
  accessTokenExpiresAt: string;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly hashingService: HashingService,
    private readonly panEncryptionService: PanEncryptionService,
    private readonly auditService: AuditService,
  ) {}

  async requestOtp(dto: OtpRequestDto, requestIp?: string, userAgent?: string) {
    const normalizedMobile = dto.phoneNumber;
    const expiresAt = new Date(Date.now() + OTP_EXPIRATION_MINUTES * 60_000);

    // Rate-limiting check: max 5 active challenges per mobile in 15 mins
    const recentCount = await this.prisma.otpChallenge.count({
      where: {
        normalizedMobile,
        createdAt: { gte: new Date(Date.now() - 15 * 60_000) },
      },
    });

    if (recentCount >= 5) {
      throw new ForbiddenException("Too many OTP requests. Please wait before trying again.");
    }

    // Generate 6-digit OTP
    const rawOtp = process.env.NODE_ENV === "test" ? "123456" : randomInt(100000, 999999).toString();
    const otpHash = await this.hashingService.hashPassword(rawOtp);
    const requestIpHash = requestIp ? this.hashToken(requestIp) : null;

    const user = await this.prisma.user.findFirst({
      where: { primaryMobile: normalizedMobile },
    });

    const challenge = await this.prisma.otpChallenge.create({
      data: {
        userId: user?.id,
        normalizedMobile,
        purpose: dto.purpose,
        otpHash,
        maxAttempts: MAX_OTP_ATTEMPTS,
        expiresAt,
        requestIpHash,
      },
    });

    await this.auditService.log({
      action: "OTP_REQUESTED",
      actorId: user?.id,
      targetTable: "otp_challenges",
      targetId: challenge.id,
      ipAddress: requestIp,
      userAgent,
      metadata: { phoneNumber: normalizedMobile, purpose: dto.purpose },
      outcome: "SUCCESS",
    });

    return {
      challengeId: challenge.id,
      expiresAt: expiresAt.toISOString(),
      ...(["test", "development"].includes(process.env.NODE_ENV ?? "") ? { debugOtp: rawOtp } : {}),
    };
  }

  async verifyOtp(dto: OtpVerifyDto, requestIp?: string, userAgent?: string) {
    const challenge = await this.prisma.otpChallenge.findFirst({
      where: {
        normalizedMobile: dto.phoneNumber,
        purpose: dto.purpose,
        consumedAt: null,
      },
      orderBy: { createdAt: "desc" },
    });

    if (!challenge || challenge.expiresAt < new Date()) {
      throw new BadRequestException("OTP challenge expired or invalid");
    }

    if (challenge.attemptCount >= challenge.maxAttempts) {
      throw new ForbiddenException("Maximum OTP attempts exceeded. Please request a new OTP.");
    }

    const isValid = await this.hashingService.verifyPassword(dto.otp, challenge.otpHash);
    if (!isValid) {
      await this.prisma.otpChallenge.update({
        where: { id: challenge.id },
        data: { attemptCount: challenge.attemptCount + 1 },
      });
      await this.auditService.log({
        action: "OTP_VERIFICATION_FAILED",
        actorId: challenge.userId ?? undefined,
        targetTable: "otp_challenges",
        targetId: challenge.id,
        ipAddress: requestIp,
        userAgent,
        outcome: "FAILURE",
        metadata: { phoneNumber: dto.phoneNumber, purpose: dto.purpose },
      });
      throw new UnauthorizedException("Invalid OTP code");
    }

    // Mark challenge consumed
    await this.prisma.otpChallenge.update({
      where: { id: challenge.id },
      data: { consumedAt: new Date() },
    });

    // Find or create user for MOBILE_OTP
    let user = challenge.userId
      ? await this.prisma.user.findUnique({ where: { id: challenge.userId } })
      : await this.prisma.user.findFirst({ where: { primaryMobile: dto.phoneNumber } });

    if (!user) {
      user = await this.prisma.user.create({
        data: {
          displayName: `User_${dto.phoneNumber.slice(-4)}`,
          primaryMobile: dto.phoneNumber,
          mobileVerifiedAt: new Date(),
        },
      });

      await this.prisma.authIdentity.create({
        data: {
          userId: user.id,
          provider: AuthProvider.MOBILE_OTP,
          normalizedValue: dto.phoneNumber,
          isVerified: true,
        },
      });
    }

    const { membership, organization } = await this.findActiveMembership(user.id);
    const session = await this.issueSession({
      userId: user.id,
      organizationId: membership?.organizationId,
      roleId: membership?.roleId,
      membershipId: membership?.id,
    });

    await this.auditService.log({
      action: "OTP_VERIFIED",
      actorId: user.id,
      organizationId: membership?.organizationId,
      targetTable: "otp_challenges",
      targetId: challenge.id,
      ipAddress: requestIp,
      userAgent,
      outcome: "SUCCESS",
      metadata: { purpose: dto.purpose },
    });

    const identity = await this.prisma.authIdentity.findFirst({
      where: { userId: user.id },
    });

    return {
      user: this.serializeUser(user, { organization: organization ?? undefined }),
      hasMpin: !!identity?.mpinHash,
      ...session,
    };
  }

  async registerTrust(dto: RegisterTrustDto) {
    const existingIdentity = await this.assertRoleNotRegistered(dto.phoneNumber, "MANDAL");
    const passwordHash = await this.hashingService.hashPassword(dto.password);
    const organizationCode = await this.generateOrganizationCode(dto.mandalTrustName);

    const { user, organization, membership } = await this.prisma.$transaction(async (tx) => {
      let user = existingIdentity?.user;

      if (!user) {
        user = await tx.user.create({
          data: {
            displayName: dto.mandalTrustName,
            preferredLanguage: dto.preferredLanguage,
            primaryMobile: dto.phoneNumber,
            mobileVerifiedAt: new Date(),
          },
        });

        await tx.authIdentity.create({
          data: {
            userId: user.id,
            provider: AuthProvider.EMAIL_PASSWORD,
            normalizedValue: dto.phoneNumber,
            isVerified: true,
            passwordHash,
          },
        });
      } else {
        await tx.authIdentity.updateMany({
          where: { userId: user.id, provider: AuthProvider.EMAIL_PASSWORD },
          data: { passwordHash },
        });
      }

      const organization = await tx.organization.create({
        data: {
          code: organizationCode,
          name: dto.mandalTrustName,
          addressLine1: dto.addressLine1 ?? "",
          city: dto.city,
          state: dto.state,
          postalCode: dto.postalCode,
          registrationNumber: dto.registrationNumber,
          presidentName: dto.presidentHeadName,
          festivalYear: dto.festivalYear,
          primaryMobile: dto.phoneNumber,
          ownerUserId: user.id,
        },
      });

      const ownerRole = await tx.organizationRole.create({
        data: {
          organizationId: organization.id,
          name: "Owner",
          description: "Full control over this organization",
          isSystem: true,
          isOwnerRole: true,
          createdByUserId: user.id,
        },
      });

      const membership = await tx.organizationMembership.create({
        data: {
          organizationId: organization.id,
          userId: user.id,
          roleId: ownerRole.id,
          isOwner: true,
          acceptedAt: new Date(),
        },
      });

      await tx.organizationSettings.create({
        data: {
          organizationId: organization.id,
          updatedByUserId: user.id,
        },
      });

      return { user, organization, membership };
    });

    const session = await this.issueSession({
      userId: user.id,
      organizationId: organization.id,
      roleId: membership.roleId,
      membershipId: membership.id,
    });

    return {
      user: this.serializeUser(user, { organization }),
      ...session,
    };
  }

  async registerDonor(dto: RegisterDonorDto) {
    const existingIdentity = await this.assertRoleNotRegistered(dto.phoneNumber, "DONOR");
    const passwordHash = await this.hashingService.hashPassword(dto.password);
    const panEncrypted = dto.panNumber ? this.panEncryptionService.encrypt(dto.panNumber) : null;

    const { user, donorProfile } = await this.prisma.$transaction(async (tx) => {
      let user = existingIdentity?.user;

      if (!user) {
        user = await tx.user.create({
          data: {
            displayName: dto.fullName,
            preferredLanguage: dto.preferredLanguage,
            primaryMobile: dto.phoneNumber,
            primaryEmail: dto.email,
            mobileVerifiedAt: new Date(),
          },
        });

        await tx.authIdentity.create({
          data: {
            userId: user.id,
            provider: AuthProvider.EMAIL_PASSWORD,
            normalizedValue: dto.phoneNumber,
            isVerified: true,
            passwordHash,
          },
        });
      } else {
        await tx.authIdentity.updateMany({
          where: { userId: user.id, provider: AuthProvider.EMAIL_PASSWORD },
          data: { passwordHash },
        });
      }

      const donorProfile = await tx.donorProfile.create({
        data: {
          userId: user.id,
          fullName: dto.fullName,
          mobile: dto.phoneNumber,
          email: dto.email,
          addressLine1: dto.addressLine1,
          city: dto.city,
          postalCode: dto.postalCode,
          panEncrypted,
          status: "ACTIVE",
          claimedAt: new Date(),
        },
      });

      return { user, donorProfile };
    });

    const session = await this.issueSession({ userId: user.id });

    return {
      user: this.serializeUser(user, { donorProfile }),
      ...session,
    };
  }

  async login(dto: LoginDto, requestIp?: string, userAgent?: string) {
    const identity = await this.prisma.authIdentity.findFirst({
      where: {
        normalizedValue: dto.phoneNumber,
        provider: AuthProvider.EMAIL_PASSWORD,
      },
      include: { user: true },
    });

    if (!identity || !identity.passwordHash) {
      throw new UnauthorizedException(INVALID_CREDENTIALS_MESSAGE);
    }

    if (identity.lockedUntil && identity.lockedUntil > new Date()) {
      await this.auditService.log({
        action: "ACCOUNT_LOCKED",
        actorId: identity.userId,
        targetTable: "auth_identities",
        targetId: identity.id,
        ipAddress: requestIp,
        userAgent,
        outcome: "FAILURE",
        reason: "Account locked",
      });
      throw new ForbiddenException(
        "Account temporarily locked due to too many failed login attempts. Please try again later.",
      );
    }

    const passwordMatches = await this.hashingService.verifyPassword(
      dto.password,
      identity.passwordHash,
    );

    if (!passwordMatches) {
      const failedLoginCount = identity.failedLoginCount + 1;
      const lockedUntil =
        failedLoginCount >= MAX_FAILED_ATTEMPTS
          ? new Date(Date.now() + LOCKOUT_MINUTES * 60_000)
          : null;
      await this.prisma.authIdentity.update({
        where: { id: identity.id },
        data: { failedLoginCount, lockedUntil },
      });

      await this.auditService.log({
        action: "LOGIN_FAILURE",
        actorId: identity.userId,
        targetTable: "auth_identities",
        targetId: identity.id,
        ipAddress: requestIp,
        userAgent,
        outcome: "FAILURE",
        metadata: { failedLoginCount },
      });

      if (lockedUntil) {
        await this.auditService.log({
          action: "ACCOUNT_LOCKED",
          actorId: identity.userId,
          targetTable: "auth_identities",
          targetId: identity.id,
          ipAddress: requestIp,
          userAgent,
          outcome: "FAILURE",
          reason: "Max failed login attempts threshold reached",
        });
      }

      throw new UnauthorizedException(INVALID_CREDENTIALS_MESSAGE);
    }

    if (identity.user.status !== "ACTIVE") {
      throw new ForbiddenException("This account is inactive. Please contact support.");
    }

    await this.prisma.authIdentity.update({
      where: { id: identity.id },
      data: { failedLoginCount: 0, lockedUntil: null, lastAuthenticatedAt: new Date() },
    });

    const { membership, organization } = await this.findActiveMembership(identity.user.id);
    const donorProfile = await this.prisma.donorProfile.findUnique({
      where: { userId: identity.user.id },
    });

    if (dto.role === "MANDAL" && !organization) {
      throw new ForbiddenException("No Mandal account is registered with this mobile number.");
    }
    if (dto.role === "DONOR" && !donorProfile) {
      throw new ForbiddenException("No Donor account is registered with this mobile number.");
    }

    const session = await this.issueSession({
      userId: identity.user.id,
      organizationId: membership?.organizationId,
      roleId: membership?.roleId,
      membershipId: membership?.id,
    });

    await this.auditService.log({
      action: "LOGIN_SUCCESS",
      actorId: identity.user.id,
      organizationId: membership?.organizationId,
      targetTable: "users",
      targetId: identity.user.id,
      ipAddress: requestIp,
      userAgent,
      outcome: "SUCCESS",
    });

    return {
      user: this.serializeUser(identity.user, {
        organization: organization ?? undefined,
        donorProfile: donorProfile ?? undefined,
      }),
      ...session,
    };
  }

  async refresh(dto: RefreshTokenDto, requestIp?: string, userAgent?: string) {
    const tokenHash = this.hashToken(dto.refreshToken);

    // Look for session regardless of status to detect reuse
    const session = await this.prisma.refreshSession.findFirst({
      where: { tokenHash },
      include: { user: true },
    });

    if (!session) {
      throw new UnauthorizedException("Invalid refresh token");
    }

    // Reuse Detection (FR5): If token was already REVOKED or COMPROMISED, revoke entire token family
    if (session.status !== "ACTIVE") {
      await this.prisma.refreshSession.updateMany({
        where: { tokenFamilyId: session.tokenFamilyId },
        data: { status: "COMPROMISED", revocationReason: "reuse_detected" },
      });

      await this.auditService.log({
        action: "REFRESH_TOKEN_REUSE_DETECTION",
        actorId: session.userId,
        targetTable: "refresh_sessions",
        targetId: session.id,
        ipAddress: requestIp,
        userAgent,
        outcome: "FAILURE",
        reason: "Token family compromised due to reuse",
        metadata: { tokenFamilyId: session.tokenFamilyId },
      });

      throw new ForbiddenException("Token family compromised; all sessions revoked.");
    }

    if (session.expiresAt < new Date()) {
      throw new UnauthorizedException("Session expired, please login again");
    }

    if (session.user.status !== "ACTIVE") {
      throw new ForbiddenException("This account is inactive. Please contact support.");
    }

    // Rotate current session
    await this.prisma.refreshSession.update({
      where: { id: session.id },
      data: { status: "REVOKED", rotatedAt: new Date(), revocationReason: "rotated" },
    });

    const membership = await this.prisma.organizationMembership.findFirst({
      where: { userId: session.userId, status: "ACTIVE" },
    });

    const newSession = await this.issueSession({
      userId: session.userId,
      organizationId: membership?.organizationId,
      roleId: membership?.roleId,
      membershipId: membership?.id,
      tokenFamilyId: session.tokenFamilyId,
    });

    await this.auditService.log({
      action: "REFRESH_TOKEN_ROTATION",
      actorId: session.userId,
      organizationId: membership?.organizationId,
      targetTable: "refresh_sessions",
      targetId: session.id,
      ipAddress: requestIp,
      userAgent,
      outcome: "SUCCESS",
    });

    return newSession;
  }

  async logout(userId: string, refreshToken: string, requestIp?: string, userAgent?: string) {
    const tokenHash = this.hashToken(refreshToken);
    await this.prisma.refreshSession.updateMany({
      where: { userId, tokenHash, status: "ACTIVE" },
      data: { status: "REVOKED", revokedAt: new Date(), revocationReason: "user_logout" },
    });

    await this.auditService.log({
      action: "LOGOUT",
      actorId: userId,
      targetTable: "refresh_sessions",
      ipAddress: requestIp,
      userAgent,
      outcome: "SUCCESS",
      reason: "User logout",
    });

    await this.auditService.log({
      action: "SESSION_REVOKED",
      actorId: userId,
      targetTable: "refresh_sessions",
      ipAddress: requestIp,
      userAgent,
      outcome: "SUCCESS",
      reason: "User logout",
    });

    return { success: true };
  }

  async logoutAll(userId: string, requestIp?: string, userAgent?: string) {
    await this.prisma.refreshSession.updateMany({
      where: { userId, status: "ACTIVE" },
      data: { status: "REVOKED", revokedAt: new Date(), revocationReason: "logout_all" },
    });

    await this.auditService.log({
      action: "LOGOUT_ALL",
      actorId: userId,
      targetTable: "refresh_sessions",
      ipAddress: requestIp,
      userAgent,
      outcome: "SUCCESS",
      reason: "Logout all user sessions",
    });

    await this.auditService.log({
      action: "SESSION_REVOKED",
      actorId: userId,
      targetTable: "refresh_sessions",
      ipAddress: requestIp,
      userAgent,
      outcome: "SUCCESS",
      reason: "Logout all sessions",
    });

    return { success: true };
  }

  async forgotPassword(dto: PasswordForgotDto, requestIp?: string, userAgent?: string) {
    const user = await this.prisma.user.findFirst({
      where: { primaryEmail: dto.email.toLowerCase().trim() },
    });

    if (!user) {
      await this.auditService.log({
        action: "PASSWORD_RESET_REQUESTED",
        targetTable: "users",
        ipAddress: requestIp,
        userAgent,
        outcome: "SUCCESS",
        metadata: { email: dto.email },
      });
      // Return success to avoid email enumeration
      return { message: "If an account exists with this email, reset instructions have been sent." };
    }

    const resetToken = randomBytes(32).toString("hex");
    const expiresAt = new Date(Date.now() + 15 * 60_000);

    await this.prisma.otpChallenge.create({
      data: {
        userId: user.id,
        normalizedMobile: user.primaryMobile ?? "EMAIL_RESET",
        purpose: OtpPurpose.PASSWORD_RESET,
        otpHash: await this.hashingService.hashPassword(resetToken),
        maxAttempts: 1,
        expiresAt,
      },
    });

    await this.auditService.log({
      action: "PASSWORD_RESET_REQUESTED",
      actorId: user.id,
      targetTable: "users",
      targetId: user.id,
      ipAddress: requestIp,
      userAgent,
      outcome: "SUCCESS",
      metadata: { email: dto.email },
    });

    return {
      message: "Password reset token generated",
      ...(process.env.NODE_ENV === "test" ? { resetToken } : {}),
    };
  }

  async resetPassword(dto: PasswordResetDto, requestIp?: string, userAgent?: string) {
    const challenge = await this.prisma.otpChallenge.findFirst({
      where: {
        purpose: OtpPurpose.PASSWORD_RESET,
        consumedAt: null,
      },
      orderBy: { createdAt: "desc" },
    });

    if (!challenge || challenge.expiresAt < new Date()) {
      throw new BadRequestException("Invalid or expired password reset challenge");
    }

    const matches = await this.hashingService.verifyPassword(dto.resetToken, challenge.otpHash);
    if (!matches) {
      throw new UnauthorizedException("Invalid reset token");
    }

    if (!challenge.userId) {
      throw new BadRequestException("No user associated with reset challenge");
    }

    const passwordHash = await this.hashingService.hashPassword(dto.newPassword);

    await this.prisma.$transaction([
      this.prisma.otpChallenge.update({
        where: { id: challenge.id },
        data: { consumedAt: new Date() },
      }),
      this.prisma.authIdentity.updateMany({
        where: { userId: challenge.userId },
        data: { passwordHash, failedLoginCount: 0, lockedUntil: null },
      }),
      this.prisma.refreshSession.updateMany({
        where: { userId: challenge.userId, status: "ACTIVE" },
        data: { status: "REVOKED", revokedAt: new Date(), revocationReason: "password_reset" },
      }),
    ]);

    await this.auditService.log({
      action: "PASSWORD_RESET_COMPLETED",
      actorId: challenge.userId,
      targetTable: "users",
      targetId: challenge.userId,
      ipAddress: requestIp,
      userAgent,
      outcome: "SUCCESS",
    });

    await this.auditService.log({
      action: "SESSION_REVOKED",
      actorId: challenge.userId,
      targetTable: "refresh_sessions",
      ipAddress: requestIp,
      userAgent,
      outcome: "SUCCESS",
      reason: "Password reset",
    });

    return { message: "Password reset successful" };
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new UnauthorizedException("Account no longer exists");
    }

    const { organization } = await this.findActiveMembership(userId);
    const donorProfile = await this.prisma.donorProfile.findUnique({ where: { userId } });

    return this.serializeUser(user, {
      organization: organization ?? undefined,
      donorProfile: donorProfile ?? undefined,
    });
  }

  private async findActiveMembership(userId: string) {
    const membership = await this.prisma.organizationMembership.findFirst({
      where: { userId, status: "ACTIVE" },
    });
    if (!membership) {
      return { membership: null, organization: null };
    }
    const organization = await this.prisma.organization.findUnique({
      where: { id: membership.organizationId },
    });
    return { membership, organization };
  }

  private async assertRoleNotRegistered(phoneNumber: string, role: "MANDAL" | "DONOR") {
    const existing = await this.prisma.authIdentity.findFirst({
      where: {
        normalizedValue: phoneNumber,
      },
      include: { user: true },
    });

    if (!existing) {
      return null;
    }

    if (role === "MANDAL") {
      const membership = await this.prisma.organizationMembership.findFirst({
        where: { userId: existing.user.id, status: "ACTIVE" },
      });
      if (membership) {
        throw new ConflictException("This mobile number is already registered as a Mandal");
      }
    } else if (role === "DONOR") {
      const donorProfile = await this.prisma.donorProfile.findUnique({
        where: { userId: existing.user.id },
      });
      if (donorProfile) {
        throw new ConflictException("This mobile number is already registered as a Donor");
      }
    }

    return existing;
  }

  private async generateOrganizationCode(name: string): Promise<string> {
    const prefix =
      name
        .toUpperCase()
        .replace(/[^A-Z0-9]/g, "")
        .slice(0, 6) || "ORG";

    for (let attempt = 0; attempt < 5; attempt += 1) {
      const suffix = randomInt(100000, 999999);
      const code = `${prefix}${suffix}`.slice(0, 20);
      const existing = await this.prisma.organization.findUnique({ where: { code } });
      if (!existing) {
        return code;
      }
    }
    throw new ConflictException("Could not generate a unique organization code, please retry");
  }

  private hashToken(token: string): string {
    return createHash("sha256").update(token).digest("hex");
  }

  private parseDurationMs(duration: string): number {
    const match = /^(\d+)([smhd])$/.exec(duration.trim());
    if (!match) {
      return 30 * 24 * 60 * 60 * 1000;
    }
    const value = Number(match[1]);
    const unitMs = { s: 1000, m: 60_000, h: 3_600_000, d: 86_400_000 }[match[2]]!;
    return value * unitMs;
  }

  private async issueSession(params: {
    userId: string;
    organizationId?: string;
    roleId?: string;
    membershipId?: string;
    tokenFamilyId?: string;
  }): Promise<IssuedSession> {
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: params.userId } });
    const sessionId = randomBytes(16).toString("hex");

    const payload: JwtAccessTokenPayload = {
      sub: user.id,
      platformRole: user.platformRole as PlatformRole,
      membershipId: params.membershipId,
      organizationId: params.organizationId,
      roleId: params.roleId,
      tokenVersion: user.tokenVersion,
      sessionId,
    };

    const accessExpiration = process.env.JWT_ACCESS_EXPIRATION ?? "15m";
    const accessToken = await this.jwtService.signAsync(payload, {
      expiresIn: accessExpiration as `${number}${"s" | "m" | "h" | "d"}`,
    });
    const accessTokenExpiresAt = new Date(
      Date.now() + this.parseDurationMs(accessExpiration),
    ).toISOString();

    const refreshToken = randomBytes(48).toString("hex");
    const refreshExpiration = process.env.JWT_REFRESH_EXPIRATION ?? "30d";
    await this.prisma.refreshSession.create({
      data: {
        userId: user.id,
        tokenFamilyId: params.tokenFamilyId,
        tokenHash: this.hashToken(refreshToken),
        tokenVersion: user.tokenVersion,
        expiresAt: new Date(Date.now() + this.parseDurationMs(refreshExpiration)),
      },
    });

    return { accessToken, refreshToken, accessTokenExpiresAt };
  }

  async createMpin(userId: string, dto: CreateMpinDto) {
    const identity = await this.prisma.authIdentity.findFirst({
      where: { userId },
    });

    if (!identity) {
      throw new NotFoundException("User identity record not found");
    }

    const mpinHash = await this.hashingService.hashPassword(dto.mpin);

    await this.prisma.authIdentity.update({
      where: { id: identity.id },
      data: {
        mpinHash,
        failedMpinCount: 0,
        mpinLockedUntil: null,
      },
    });

    return {
      message: "MPIN created successfully",
      hasMpin: true,
    };
  }

  async loginMpin(dto: LoginMpinDto, requestIp?: string, userAgent?: string) {
    const normalizedMobile = dto.phoneNumber.trim();
    const identity = await this.prisma.authIdentity.findFirst({
      where: { normalizedValue: normalizedMobile },
      include: { user: true },
    });

    if (!identity || !identity.mpinHash) {
      throw new BadRequestException("MPIN is not configured for this mobile number. Please authenticate via OTP first.");
    }

    if (identity.mpinLockedUntil && identity.mpinLockedUntil > new Date()) {
      await this.auditService.log({
        action: "ACCOUNT_LOCKED",
        actorId: identity.userId,
        targetTable: "auth_identities",
        targetId: identity.id,
        ipAddress: requestIp,
        userAgent,
        outcome: "FAILURE",
        metadata: { reason: "MPIN locked", phoneNumber: dto.phoneNumber },
      });
      throw new ForbiddenException("MPIN authentication is locked due to repeated failures. Please try again after 15 minutes or reset your MPIN.");
    }

    const isValidMpin = await this.hashingService.verifyPassword(dto.mpin, identity.mpinHash);

    if (!isValidMpin) {
      const nextFailedCount = identity.failedMpinCount + 1;
      const isLockoutAttempt = nextFailedCount >= 5;
      const mpinLockedUntil = isLockoutAttempt ? new Date(Date.now() + 15 * 60_000) : null;

      await this.prisma.authIdentity.update({
        where: { id: identity.id },
        data: {
          failedMpinCount: nextFailedCount,
          ...(mpinLockedUntil ? { mpinLockedUntil } : {}),
        },
      });

      await this.auditService.log({
        action: isLockoutAttempt ? "ACCOUNT_LOCKED" : "LOGIN_FAILURE",
        actorId: identity.userId,
        targetTable: "auth_identities",
        targetId: identity.id,
        ipAddress: requestIp,
        userAgent,
        outcome: "FAILURE",
        metadata: { failedMpinCount: nextFailedCount, phoneNumber: dto.phoneNumber },
      });

      if (isLockoutAttempt) {
        throw new ForbiddenException("MPIN authentication is locked due to 5 consecutive failed attempts. Try again in 15 minutes.");
      }

      throw new UnauthorizedException("Invalid MPIN");
    }

    // Success - reset failure counter
    await this.prisma.authIdentity.update({
      where: { id: identity.id },
      data: {
        failedMpinCount: 0,
        mpinLockedUntil: null,
        lastAuthenticatedAt: new Date(),
      },
    });

    const { membership, organization } = await this.findActiveMembership(identity.userId);
    const session = await this.issueSession({
      userId: identity.userId,
      organizationId: membership?.organizationId,
      roleId: membership?.roleId,
      membershipId: membership?.id,
    });

    await this.auditService.log({
      action: "LOGIN_SUCCESS",
      actorId: identity.userId,
      organizationId: membership?.organizationId,
      targetTable: "auth_identities",
      targetId: identity.id,
      ipAddress: requestIp,
      userAgent,
      outcome: "SUCCESS",
      metadata: { method: "MPIN", role: dto.role },
    });

    return {
      user: this.serializeUser(identity.user, { organization: organization ?? undefined }),
      hasMpin: true,
      ...session,
    };
  }

  async changeMpin(userId: string, dto: ChangeMpinDto, requestIp?: string, userAgent?: string) {
    const identity = await this.prisma.authIdentity.findFirst({
      where: { userId },
    });

    if (!identity || !identity.mpinHash) {
      throw new BadRequestException("MPIN is not set for this account");
    }

    const isValid = await this.hashingService.verifyPassword(dto.oldMpin, identity.mpinHash);
    if (!isValid) {
      throw new UnauthorizedException("Current MPIN is incorrect");
    }

    const newMpinHash = await this.hashingService.hashPassword(dto.newMpin);
    await this.prisma.authIdentity.update({
      where: { id: identity.id },
      data: {
        mpinHash: newMpinHash,
        failedMpinCount: 0,
        mpinLockedUntil: null,
      },
    });

    await this.auditService.log({
      action: "PASSWORD_RESET_COMPLETED",
      actorId: userId,
      targetTable: "auth_identities",
      targetId: identity.id,
      ipAddress: requestIp,
      userAgent,
      outcome: "SUCCESS",
      metadata: { action: "CHANGE_MPIN" },
    });

    return { message: "MPIN changed successfully" };
  }

  async forgotMpin(dto: ForgotMpinDto, requestIp?: string, userAgent?: string) {
    const identity = await this.prisma.authIdentity.findFirst({
      where: { normalizedValue: dto.phoneNumber.trim() },
    });

    if (!identity) {
      return { message: "If account exists, an OTP challenge for MPIN reset has been created." };
    }

    return this.requestOtp(
      { phoneNumber: dto.phoneNumber, purpose: OtpPurpose.MPIN_RESET },
      requestIp,
      userAgent,
    );
  }

  async verifyMpinReset(dto: VerifyMpinResetDto, requestIp?: string, userAgent?: string) {
    const challenge = await this.prisma.otpChallenge.findFirst({
      where: {
        normalizedMobile: dto.phoneNumber.trim(),
        purpose: OtpPurpose.MPIN_RESET,
        consumedAt: null,
      },
      orderBy: { createdAt: "desc" },
    });

    if (!challenge || challenge.expiresAt < new Date()) {
      throw new BadRequestException("Invalid or expired OTP challenge");
    }

    if (challenge.attemptCount >= 5) {
      throw new ForbiddenException("Maximum verification attempts exceeded for this OTP");
    }

    const isValidOtp = await this.hashingService.verifyPassword(dto.otp, challenge.otpHash);
    if (!isValidOtp) {
      await this.prisma.otpChallenge.update({
        where: { id: challenge.id },
        data: { attemptCount: challenge.attemptCount + 1 },
      });
      throw new UnauthorizedException("Invalid OTP code");
    }

    // Mark challenge consumed
    await this.prisma.otpChallenge.update({
      where: { id: challenge.id },
      data: { consumedAt: new Date() },
    });

    const identity = await this.prisma.authIdentity.findFirst({
      where: { normalizedValue: dto.phoneNumber.trim() },
      include: { user: true },
    });

    if (!identity) {
      throw new NotFoundException("Account identity not found");
    }

    const mpinHash = await this.hashingService.hashPassword(dto.newMpin);

    await this.prisma.authIdentity.update({
      where: { id: identity.id },
      data: {
        mpinHash,
        failedMpinCount: 0,
        mpinLockedUntil: null,
      },
    });

    // Revoke active sessions per security policy
    await this.prisma.refreshSession.updateMany({
      where: { userId: identity.userId, status: "ACTIVE" },
      data: {
        status: "REVOKED",
        revokedAt: new Date(),
        revocationReason: "MPIN reset via OTP",
      },
    });

    await this.auditService.log({
      action: "SESSION_REVOKED",
      actorId: identity.userId,
      targetTable: "refresh_sessions",
      targetId: identity.userId,
      ipAddress: requestIp,
      userAgent,
      outcome: "SUCCESS",
      metadata: { reason: "MPIN Reset" },
    });

    const { membership, organization } = await this.findActiveMembership(identity.userId);
    const session = await this.issueSession({
      userId: identity.userId,
      organizationId: membership?.organizationId,
      roleId: membership?.roleId,
      membershipId: membership?.id,
    });

    return {
      message: "MPIN reset successfully and active sessions revoked",
      user: this.serializeUser(identity.user, { organization: organization ?? undefined }),
      hasMpin: true,
      ...session,
    };
  }

  private serializeUser(
    user: { id: string; displayName: string; primaryMobile: string | null; primaryEmail: string | null; preferredLanguage: string; platformRole: string; status: string },
    related: {
      organization?: { id: string; name: string; code: string; status: string } | null;
      donorProfile?: { id: string; fullName: string; status: string } | null;
    },
  ) {
    return {
      id: user.id,
      displayName: user.displayName,
      primaryMobile: user.primaryMobile,
      primaryEmail: user.primaryEmail,
      preferredLanguage: user.preferredLanguage,
      platformRole: user.platformRole,
      status: user.status,
      organization: related.organization
        ? {
            id: related.organization.id,
            name: related.organization.name,
            code: related.organization.code,
            status: related.organization.status,
          }
        : null,
      donorProfile: related.donorProfile
        ? {
            id: related.donorProfile.id,
            fullName: related.donorProfile.fullName,
            status: related.donorProfile.status,
          }
        : null,
    };
  }
}
