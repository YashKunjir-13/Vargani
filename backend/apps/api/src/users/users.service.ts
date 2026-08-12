import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { AuthProvider, OtpPurpose, PrismaService, UserStatus } from "@pauti-pustak/backend-database";
import { HashingService, PlatformRole } from "@pauti-pustak/backend-security";
import { randomBytes } from "crypto";
import { ChangeContactDto } from "./dto/change-contact.dto";
import { UpdateUserProfileDto } from "./dto/update-user-profile.dto";
import { UpdateUserStatusDto } from "./dto/update-user-status.dto";

@Injectable()
export class UsersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly hashingService: HashingService,
  ) {}

  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        identities: {
          select: {
            id: true,
            provider: true,
            normalizedValue: true,
            isVerified: true,
            lastAuthenticatedAt: true,
            createdAt: true,
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException("User account not found");
    }

    const membership = await this.prisma.organizationMembership.findFirst({
      where: { userId, status: "ACTIVE" },
      include: { organization: true, role: true },
    });

    return {
      id: user.id,
      displayName: user.displayName,
      primaryMobile: user.primaryMobile,
      primaryEmail: user.primaryEmail,
      preferredLanguage: user.preferredLanguage,
      platformRole: user.platformRole,
      status: user.status,
      avatarDocumentId: user.avatarDocumentId,
      mobileVerifiedAt: user.mobileVerifiedAt,
      emailVerifiedAt: user.emailVerifiedAt,
      createdAt: user.createdAt,
      activeContext: membership
        ? {
            membershipId: membership.id,
            organizationId: membership.organizationId,
            organizationName: membership.organization.name,
            organizationCode: membership.organization.code,
            roleId: membership.roleId,
            roleName: membership.role.name,
            isOwner: membership.isOwner,
          }
        : null,
      identities: user.identities,
    };
  }

  async updateMe(userId: string, dto: UpdateUserProfileDto) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user || user.status !== UserStatus.ACTIVE) {
      throw new ForbiddenException("Account is not active");
    }

    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: {
        ...(dto.displayName ? { displayName: dto.displayName } : {}),
        ...(dto.primaryMobile ? { primaryMobile: dto.primaryMobile } : {}),
        ...(dto.primaryEmail !== undefined ? { primaryEmail: dto.primaryEmail ? dto.primaryEmail.toLowerCase().trim() : null } : {}),
        ...(dto.preferredLanguage ? { preferredLanguage: dto.preferredLanguage } : {}),
        ...(dto.avatarDocumentId !== undefined ? { avatarDocumentId: dto.avatarDocumentId } : {}),
      },
    });

    const donorProfile = await this.prisma.donorProfile.findUnique({ where: { userId } });
    if (donorProfile) {
      await this.prisma.donorProfile.update({
        where: { id: donorProfile.id },
        data: {
          ...(dto.displayName ? { fullName: dto.displayName } : {}),
          ...(dto.primaryMobile ? { mobile: dto.primaryMobile } : {}),
          ...(dto.primaryEmail !== undefined ? { email: dto.primaryEmail ? dto.primaryEmail.toLowerCase().trim() : null } : {}),
        },
      });
    }

    return this.getMe(updated.id);
  }

  async beginEmailChange(userId: string, dto: ChangeContactDto) {
    if (!dto.newEmail) {
      throw new BadRequestException("newEmail is required");
    }

    const normalizedEmail = dto.newEmail.toLowerCase().trim();
    const existing = await this.prisma.user.findFirst({
      where: { primaryEmail: normalizedEmail, id: { not: userId } },
    });

    if (existing) {
      throw new ConflictException("Email address is already in use by another account");
    }

    const rawOtp = process.env.NODE_ENV === "test" ? "123456" : Math.floor(100000 + Math.random() * 900000).toString();
    const otpHash = await this.hashingService.hashPassword(rawOtp);
    const expiresAt = new Date(Date.now() + 15 * 60_000);

    const challenge = await this.prisma.otpChallenge.create({
      data: {
        userId,
        normalizedMobile: normalizedEmail,
        purpose: OtpPurpose.VERIFY_MOBILE,
        otpHash,
        expiresAt,
      },
    });

    return {
      message: "Verification challenge initiated for new email",
      challengeId: challenge.id,
      ...(process.env.NODE_ENV === "test" ? { debugOtp: rawOtp } : {}),
    };
  }

  async beginMobileChange(userId: string, dto: ChangeContactDto) {
    if (!dto.newMobile) {
      throw new BadRequestException("newMobile is required");
    }

    const normalizedMobile = dto.newMobile.trim();
    const existing = await this.prisma.user.findFirst({
      where: { primaryMobile: normalizedMobile, id: { not: userId } },
    });

    if (existing) {
      throw new ConflictException("Mobile number is already in use by another account");
    }

    const rawOtp = process.env.NODE_ENV === "test" ? "123456" : Math.floor(100000 + Math.random() * 900000).toString();
    const otpHash = await this.hashingService.hashPassword(rawOtp);
    const expiresAt = new Date(Date.now() + 15 * 60_000);

    const challenge = await this.prisma.otpChallenge.create({
      data: {
        userId,
        normalizedMobile,
        purpose: OtpPurpose.VERIFY_MOBILE,
        otpHash,
        expiresAt,
      },
    });

    return {
      message: "Verification challenge initiated for new mobile number",
      challengeId: challenge.id,
      ...(process.env.NODE_ENV === "test" ? { debugOtp: rawOtp } : {}),
    };
  }

  async getPlatformUser(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        displayName: true,
        primaryMobile: true,
        primaryEmail: true,
        preferredLanguage: true,
        platformRole: true,
        status: true,
        deactivatedAt: true,
        deactivationReason: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new NotFoundException("User not found");
    }

    return user;
  }

  async updatePlatformUserStatus(userId: string, dto: UpdateUserStatusDto) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException("User not found");
    }

    if (user.platformRole === PlatformRole.SUPER_ADMIN && dto.status === UserStatus.DEACTIVATED) {
      throw new ForbiddenException("Platform Super Admin accounts cannot be deactivated");
    }

    const isDeactivating = dto.status === UserStatus.DEACTIVATED;
    const updated = await this.prisma.$transaction(async (tx) => {
      const u = await tx.user.update({
        where: { id: userId },
        data: {
          status: dto.status,
          deactivatedAt: isDeactivating ? new Date() : null,
          deactivationReason: dto.reason,
        },
      });

      if (isDeactivating) {
        // Invalidate all sessions immediately
        await tx.refreshSession.updateMany({
          where: { userId, status: "ACTIVE" },
          data: { status: "REVOKED", revokedAt: new Date(), revocationReason: `Deactivated: ${dto.reason}` },
        });
      }

      return u;
    });

    return {
      id: updated.id,
      status: updated.status,
      deactivatedAt: updated.deactivatedAt,
      reason: updated.deactivationReason,
    };
  }
}
