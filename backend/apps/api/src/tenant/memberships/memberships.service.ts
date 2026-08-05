import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { AuthProvider, MembershipStatus, PrismaService } from "@pauti-pustak/backend-database";
import { HashingService } from "@pauti-pustak/backend-security";
import { createHash, randomBytes } from "crypto";
import { AssignRoleDto } from "./dto/assign-role.dto";
import { CreateDirectMemberDto } from "./dto/create-direct-member.dto";
import { CreateInvitationDto } from "./dto/create-invitation.dto";
import { TransferOwnershipDto } from "./dto/transfer-ownership.dto";
import { UpdateMembershipStatusDto } from "./dto/update-membership-status.dto";

@Injectable()
export class MembershipsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly hashingService: HashingService,
  ) {}

  async listMembers(organizationId: string) {
    const members = await this.prisma.organizationMembership.findMany({
      where: { organizationId },
      include: {
        role: true,
      },
      orderBy: { createdAt: "desc" },
    });

    const userIds = members.map((m) => m.userId);
    const users = await this.prisma.user.findMany({
      where: { id: { in: userIds } },
      select: { id: true, displayName: true, primaryMobile: true, primaryEmail: true, status: true },
    });

    const userMap = new Map(users.map((u) => [u.id, u]));

    return members.map((m) => ({
      ...m,
      user: userMap.get(m.userId) ?? null,
    }));
  }

  async createInvitation(organizationId: string, inviterUserId: string, dto: CreateInvitationDto) {
    const role = await this.prisma.organizationRole.findFirst({
      where: { id: dto.roleId, organizationId },
    });

    if (!role) {
      throw new NotFoundException("Role not found in organization");
    }

    const token = randomBytes(32).toString("hex");
    const tokenHash = createHash("sha256").update(token).digest("hex");
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

    const invitation = await this.prisma.organizationInvitation.create({
      data: {
        organizationId,
        invitedByUserId: inviterUserId,
        targetMobile: dto.targetMobile,
        targetEmail: dto.targetEmail?.toLowerCase(),
        roleId: dto.roleId,
        deliveryMethod: dto.deliveryMethod,
        tokenHash,
        status: MembershipStatus.INVITED,
        expiresAt,
      },
    });

    return {
      invitationId: invitation.id,
      token: process.env.NODE_ENV === "test" ? token : undefined,
      expiresAt: expiresAt.toISOString(),
    };
  }

  async createDirectMember(organizationId: string, inviterUserId: string, dto: CreateDirectMemberDto) {
    const role = await this.prisma.organizationRole.findFirst({
      where: { id: dto.roleId, organizationId },
    });

    if (!role) {
      throw new NotFoundException("Role not found in organization");
    }

    const existingIdentity = await this.prisma.authIdentity.findFirst({
      where: { normalizedValue: dto.mobile },
    });

    let user: any;
    if (existingIdentity) {
      user = await this.prisma.user.findUnique({ where: { id: existingIdentity.userId } });
      // FR45: Enforce single active organization membership per user across the platform
      const activeMembership = await this.prisma.organizationMembership.findFirst({
        where: { userId: user.id, status: MembershipStatus.ACTIVE },
      });
      if (activeMembership) {
        throw new ConflictException(
          "User already has an active organization membership elsewhere. Single active membership rule applies.",
        );
      }
    } else {
      const passwordHash = dto.password
        ? await this.hashingService.hashPassword(dto.password)
        : await this.hashingService.hashPassword(randomBytes(16).toString("hex"));

      user = await this.prisma.user.create({
        data: {
          displayName: dto.displayName,
          primaryMobile: dto.mobile,
          mobileVerifiedAt: new Date(),
        },
      });

      await this.prisma.authIdentity.create({
        data: {
          userId: user.id,
          provider: AuthProvider.MOBILE_PASSWORD,
          normalizedValue: dto.mobile,
          isVerified: true,
          passwordHash,
        },
      });
    }

    const membership = await this.prisma.organizationMembership.create({
      data: {
        organizationId,
        userId: user.id,
        roleId: dto.roleId,
        isOwner: false,
        status: MembershipStatus.ACTIVE,
        invitedByUserId: inviterUserId,
        acceptedAt: new Date(),
      },
    });

    return {
      membershipId: membership.id,
      userId: user.id,
      displayName: user.displayName,
      roleName: role.name,
    };
  }

  async acceptInvitation(token: string, acceptingUserId: string) {
    const tokenHash = createHash("sha256").update(token).digest("hex");
    const invitation = await this.prisma.organizationInvitation.findFirst({
      where: { tokenHash, status: MembershipStatus.INVITED },
    });

    if (!invitation || (invitation.expiresAt && invitation.expiresAt < new Date())) {
      throw new BadRequestException("Invitation is invalid or expired");
    }

    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: acceptingUserId } });

    // Verify invitation matches user identity
    if (invitation.targetMobile && invitation.targetMobile !== user.primaryMobile) {
      throw new ForbiddenException("Invitation mobile does not match verified identity");
    }
    if (invitation.targetEmail && invitation.targetEmail !== user.primaryEmail) {
      throw new ForbiddenException("Invitation email does not match verified identity");
    }

    // FR45: Enforce single active membership per user
    const existingActive = await this.prisma.organizationMembership.findFirst({
      where: { userId: acceptingUserId, status: MembershipStatus.ACTIVE },
    });

    if (existingActive) {
      throw new ConflictException("User already has an active organization membership");
    }

    const membership = await this.prisma.$transaction(async (tx) => {
      await tx.organizationInvitation.update({
        where: { id: invitation.id },
        data: {
          status: MembershipStatus.ACTIVE,
          acceptedByUserId: acceptingUserId,
          acceptedAt: new Date(),
        },
      });

      return tx.organizationMembership.create({
        data: {
          organizationId: invitation.organizationId,
          userId: acceptingUserId,
          roleId: invitation.roleId,
          status: MembershipStatus.ACTIVE,
          isOwner: false,
          invitedByUserId: invitation.invitedByUserId,
          acceptedAt: new Date(),
        },
      });
    });

    return {
      membershipId: membership.id,
      organizationId: membership.organizationId,
      acceptedAt: membership.acceptedAt,
    };
  }

  async updateStatus(organizationId: string, membershipId: string, actorUserId: string, dto: UpdateMembershipStatusDto) {
    const membership = await this.prisma.organizationMembership.findFirst({
      where: { id: membershipId, organizationId },
    });

    if (!membership) {
      throw new NotFoundException("Membership record not found");
    }

    if (membership.isOwner && dto.status !== MembershipStatus.ACTIVE) {
      throw new ForbiddenException("Cannot deactivate or remove the Owner membership. Ownership must be transferred first.");
    }

    const updated = await this.prisma.organizationMembership.update({
      where: { id: membershipId },
      data: {
        status: dto.status,
        ...(dto.status === MembershipStatus.REMOVED ? { removedAt: new Date() } : {}),
      },
    });

    if (dto.status !== MembershipStatus.ACTIVE) {
      // Invalidate active refresh sessions immediately
      await this.prisma.refreshSession.updateMany({
        where: { userId: membership.userId, status: "ACTIVE" },
        data: { status: "REVOKED", revokedAt: new Date(), revocationReason: `Membership status: ${dto.status}` },
      });
    }

    return updated;
  }

  async assignRole(organizationId: string, membershipId: string, actorUserId: string, roleId: string) {
    const membership = await this.prisma.organizationMembership.findFirst({
      where: { id: membershipId, organizationId },
    });

    if (!membership) {
      throw new NotFoundException("Membership record not found");
    }

    const role = await this.prisma.organizationRole.findFirst({
      where: { id: roleId, organizationId },
    });

    if (!role) {
      throw new NotFoundException("Target role not found in organization");
    }

    if (membership.isOwner && !role.isOwnerRole) {
      throw new ForbiddenException("Cannot change the Owner's role without transferring ownership first.");
    }

    const updated = await this.prisma.organizationMembership.update({
      where: { id: membershipId },
      data: { roleId },
    });

    return {
      membershipId: updated.id,
      roleId: updated.roleId,
      roleName: role.name,
    };
  }

  async transferOwnership(organizationId: string, currentOwnerUserId: string, dto: TransferOwnershipDto) {
    const currentOwnerMembership = await this.prisma.organizationMembership.findFirst({
      where: { organizationId, userId: currentOwnerUserId, isOwner: true, status: MembershipStatus.ACTIVE },
    });

    if (!currentOwnerMembership) {
      throw new ForbiddenException("Current user is not the active Owner of this organization");
    }

    const newOwnerMembership = await this.prisma.organizationMembership.findFirst({
      where: { organizationId, userId: dto.newOwnerUserId, status: MembershipStatus.ACTIVE },
    });

    if (!newOwnerMembership) {
      throw new NotFoundException("New owner must be an active member of this organization");
    }

    const ownerRole = await this.prisma.organizationRole.findFirst({
      where: { organizationId, isOwnerRole: true },
    });

    if (!ownerRole) {
      throw new NotFoundException("Owner role definition not found");
    }

    // Default non-owner role for outgoing owner (President / Administrator)
    let outgoingRole = dto.outgoingOwnerRoleId
      ? await this.prisma.organizationRole.findFirst({ where: { id: dto.outgoingOwnerRoleId, organizationId } })
      : await this.prisma.organizationRole.findFirst({ where: { organizationId, name: "President" } });

    if (!outgoingRole) {
      // Fallback to any non-owner active role
      outgoingRole = await this.prisma.organizationRole.findFirst({
        where: { organizationId, isOwnerRole: false, isActive: true },
      });
    }

    if (!outgoingRole) {
      throw new BadRequestException("No suitable non-owner role found for outgoing owner");
    }

    await this.prisma.$transaction(async (tx) => {
      // Step 1: Assign Owner role to new owner
      await tx.organizationMembership.update({
        where: { id: newOwnerMembership.id },
        data: { isOwner: true, roleId: ownerRole.id },
      });

      // Step 2: Assign non-owner role to outgoing owner
      await tx.organizationMembership.update({
        where: { id: currentOwnerMembership.id },
        data: { isOwner: false, roleId: outgoingRole.id },
      });

      // Step 3: Update organization ownerUserId
      await tx.organization.update({
        where: { id: organizationId },
        data: { ownerUserId: dto.newOwnerUserId },
      });
    });

    return {
      message: "Ownership transferred successfully",
      newOwnerUserId: dto.newOwnerUserId,
      outgoingOwnerUserId: currentOwnerUserId,
      outgoingOwnerRoleName: outgoingRole.name,
    };
  }
}
