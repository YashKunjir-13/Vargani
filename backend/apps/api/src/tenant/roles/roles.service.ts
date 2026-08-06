import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { PrismaService } from "@pauti-pustak/backend-database";
import { CreateRoleDto } from "./dto/create-role.dto";
import { UpdateRoleDto } from "./dto/update-role.dto";

@Injectable()
export class RolesService {
  constructor(private readonly prisma: PrismaService) {}

  async getPermissionsCatalog() {
    return this.prisma.permission.findMany({
      where: { isActive: true },
      orderBy: [{ module: "asc" }, { code: "asc" }],
    });
  }

  async listRoles(organizationId: string) {
    return this.prisma.organizationRole.findMany({
      where: { organizationId },
      include: {
        permissions: {
          include: { permission: true },
        },
        _count: {
          select: { memberships: true },
        },
      },
      orderBy: [{ isOwnerRole: "desc" }, { isSystem: "desc" }, { name: "asc" }],
    });
  }

  async getRole(organizationId: string, roleId: string) {
    const role = await this.prisma.organizationRole.findFirst({
      where: { id: roleId, organizationId },
      include: {
        permissions: {
          include: { permission: true },
        },
        _count: {
          select: { memberships: true },
        },
      },
    });

    if (!role) {
      throw new NotFoundException("Role not found");
    }

    return role;
  }

  async createRole(organizationId: string, userId: string, dto: CreateRoleDto) {
    const existing = await this.prisma.organizationRole.findUnique({
      where: {
        organizationId_name: {
          organizationId,
          name: dto.name,
        },
      },
    });

    if (existing) {
      throw new ConflictException(`Role with name "${dto.name}" already exists in this organization`);
    }

    const permissions = await this.prisma.permission.findMany({
      where: { code: { in: dto.permissionCodes }, isActive: true },
    });

    const role = await this.prisma.organizationRole.create({
      data: {
        organizationId,
        name: dto.name,
        description: dto.description,
        isSystem: false,
        isOwnerRole: false,
        createdByUserId: userId,
        permissions: {
          create: permissions.map((p) => ({
            permissionId: p.id,
            grantedByUserId: userId,
          })),
        },
      },
      include: {
        permissions: {
          include: { permission: true },
        },
      },
    });

    return role;
  }

  async updateRole(organizationId: string, roleId: string, userId: string, dto: UpdateRoleDto) {
    const role = await this.prisma.organizationRole.findFirst({
      where: { id: roleId, organizationId },
    });

    if (!role) {
      throw new NotFoundException("Role not found");
    }

    // FR54: Owner role is protected; permissions cannot be stripped & cannot be deactivated
    if (role.isOwnerRole) {
      if (dto.isActive === false) {
        throw new ForbiddenException("Protected Owner role cannot be deactivated");
      }
    }

    if (dto.name && dto.name !== role.name) {
      const nameConflict = await this.prisma.organizationRole.findUnique({
        where: { organizationId_name: { organizationId, name: dto.name } },
      });
      if (nameConflict) {
        throw new ConflictException(`Role with name "${dto.name}" already exists`);
      }
    }

    const updated = await this.prisma.$transaction(async (tx) => {
      if (dto.permissionCodes && !role.isOwnerRole) {
        const permissions = await tx.permission.findMany({
          where: { code: { in: dto.permissionCodes }, isActive: true },
        });

        await tx.rolePermission.deleteMany({ where: { roleId } });
        await tx.rolePermission.createMany({
          data: permissions.map((p) => ({
            roleId,
            permissionId: p.id,
            grantedByUserId: userId,
          })),
        });
      }

      return tx.organizationRole.update({
        where: { id: roleId },
        data: {
          ...(dto.name ? { name: dto.name } : {}),
          ...(dto.description !== undefined ? { description: dto.description } : {}),
          ...(dto.isActive !== undefined && !role.isOwnerRole ? { isActive: dto.isActive } : {}),
        },
        include: {
          permissions: {
            include: { permission: true },
          },
        },
      });
    });

    return updated;
  }

  async deleteRole(organizationId: string, roleId: string) {
    const role = await this.prisma.organizationRole.findFirst({
      where: { id: roleId, organizationId },
      include: {
        _count: { select: { memberships: true } },
      },
    });

    if (!role) {
      throw new NotFoundException("Role not found");
    }

    // FR54: Owner is protected and cannot be deleted
    if (role.isOwnerRole || role.isSystem) {
      throw new ForbiddenException("Protected system or Owner roles cannot be deleted");
    }

    // FR55: A custom role assigned to active members cannot be deleted (409 Conflict)
    const activeCount = await this.prisma.organizationMembership.count({
      where: { roleId, status: "ACTIVE" },
    });

    if (activeCount > 0) {
      throw new ConflictException(
        `Cannot delete role because it is currently assigned to ${activeCount} active member(s). Reassign members first.`,
      );
    }

    await this.prisma.organizationRole.delete({
      where: { id: roleId },
    });

    return { success: true, deletedRoleId: roleId };
  }
}
