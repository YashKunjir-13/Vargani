import {
  ConflictException,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { AuthProvider, PrismaService } from "@pauti-pustak/backend-database";
import {
  HashingService,
  JwtAccessTokenPayload,
  PanEncryptionService,
  PlatformRole,
} from "@pauti-pustak/backend-security";
import { createHash, randomBytes, randomInt } from "crypto";
import { LoginDto } from "./dto/login.dto";
import { RefreshTokenDto } from "./dto/refresh-token.dto";
import { RegisterDonorDto } from "./dto/register-donor.dto";
import { RegisterTrustDto } from "./dto/register-trust.dto";

const MAX_FAILED_ATTEMPTS = 5;
const LOCKOUT_MINUTES = 15;
const INVALID_CREDENTIALS_MESSAGE = "Invalid phone number or password";

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
  ) {}

  async registerTrust(dto: RegisterTrustDto) {
    try {
    const existingIdentity = await this.assertRoleNotRegistered(dto.phoneNumber, 'MANDAL');
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
            provider: AuthProvider.MOBILE_PASSWORD,
            normalizedValue: dto.phoneNumber,
            isVerified: true,
            passwordHash,
          },
        });
      } else {
        // User exists, update password for consistency across their roles
        await tx.authIdentity.updateMany({
          where: { userId: user.id, provider: AuthProvider.MOBILE_PASSWORD },
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
    } catch (e) {
      console.error("registerTrust Error:", e);
      throw e;
    }
  }

  async registerDonor(dto: RegisterDonorDto) {
    const existingIdentity = await this.assertRoleNotRegistered(dto.phoneNumber, 'DONOR');
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
            provider: AuthProvider.MOBILE_PASSWORD,
            normalizedValue: dto.phoneNumber,
            isVerified: true,
            passwordHash,
          },
        });
      } else {
        // User exists, update password for consistency across their roles
        await tx.authIdentity.updateMany({
          where: { userId: user.id, provider: AuthProvider.MOBILE_PASSWORD },
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

  async login(dto: LoginDto) {
    const identity = await this.prisma.authIdentity.findUnique({
      where: {
        provider_normalizedValue: {
          provider: AuthProvider.MOBILE_PASSWORD,
          normalizedValue: dto.phoneNumber,
        },
      },
      include: { user: true },
    });

    if (!identity || !identity.passwordHash) {
      throw new UnauthorizedException(INVALID_CREDENTIALS_MESSAGE);
    }

    if (identity.lockedUntil && identity.lockedUntil > new Date()) {
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

    if (dto.role === 'MANDAL' && !organization) {
      throw new ForbiddenException("No Mandal account is registered with this mobile number.");
    }
    if (dto.role === 'DONOR' && !donorProfile) {
      throw new ForbiddenException("No Donor account is registered with this mobile number.");
    }

    const session = await this.issueSession({
      userId: identity.user.id,
      organizationId: membership?.organizationId,
      roleId: membership?.roleId,
      membershipId: membership?.id,
    });

    return {
      user: this.serializeUser(identity.user, {
        organization: organization ?? undefined,
        donorProfile: donorProfile ?? undefined,
      }),
      ...session,
    };
  }

  async refresh(dto: RefreshTokenDto) {
    const tokenHash = this.hashToken(dto.refreshToken);
    const session = await this.prisma.refreshSession.findFirst({
      where: { tokenHash, status: "ACTIVE" },
      include: { user: true },
    });

    if (!session || session.expiresAt < new Date()) {
      throw new UnauthorizedException("Session expired, please login again");
    }
    if (session.user.status !== "ACTIVE") {
      throw new ForbiddenException("This account is inactive. Please contact support.");
    }

    await this.prisma.refreshSession.update({
      where: { id: session.id },
      data: { status: "REVOKED", rotatedAt: new Date(), revocationReason: "rotated" },
    });

    const membership = await this.prisma.organizationMembership.findFirst({
      where: { userId: session.userId, status: "ACTIVE" },
    });

    return this.issueSession({
      userId: session.userId,
      organizationId: membership?.organizationId,
      roleId: membership?.roleId,
      membershipId: membership?.id,
      tokenFamilyId: session.tokenFamilyId,
    });
  }

  async logout(userId: string, refreshToken: string) {
    const tokenHash = this.hashToken(refreshToken);
    await this.prisma.refreshSession.updateMany({
      where: { userId, tokenHash, status: "ACTIVE" },
      data: { status: "REVOKED", revokedAt: new Date(), revocationReason: "user_logout" },
    });
    return { success: true };
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

  private async assertRoleNotRegistered(phoneNumber: string, role: 'MANDAL' | 'DONOR') {
    const existing = await this.prisma.authIdentity.findUnique({
      where: {
        provider_normalizedValue: {
          provider: AuthProvider.MOBILE_PASSWORD,
          normalizedValue: phoneNumber,
        },
      },
      include: { user: true },
    });

    if (!existing) {
      return null;
    }

    if (role === 'MANDAL') {
      const membership = await this.prisma.organizationMembership.findFirst({
        where: { userId: existing.user.id, status: "ACTIVE" },
      });
      if (membership) {
        throw new ConflictException("This mobile number is already registered as a Mandal");
      }
    } else if (role === 'DONOR') {
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
      return 7 * 24 * 60 * 60 * 1000;
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
    const refreshExpiration = process.env.JWT_REFRESH_EXPIRATION ?? "7d";
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
