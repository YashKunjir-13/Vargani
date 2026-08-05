import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from "@nestjs/common";
import { PrismaService } from "@pauti-pustak/backend-database";
import { ALL_PERMISSION_CODES, MANAGE_ROLES_PERMISSION } from "./role-catalog";

@Injectable()
export class RoleManagementService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * The Trust President/owner role is system-protected and can never be
   * deleted -- doing so would lock the mandal out of its own account.
   */
  async deleteRole(organizationId: string, roleId: string): Promise<void> {
    const role = await this.requireOwnedRole(organizationId, roleId);

    if (role.isSystem || role.isOwnerRole) {
      throw new ForbiddenException(
        "The Trust President role is system-protected and cannot be deleted.",
      );
    }

    await this.prisma.organizationRole.delete({ where: { id: roleId } });
  }

  /**
   * Replaces a role's permission set. For the Trust President/owner role,
   * the requested set is always overridden with the full permission
   * catalog -- it can never be narrowed, and "role.manage" specifically can
   * never be removed from it, however the edit was attempted (including a
   * request that omits it entirely).
   */
  async updateRolePermissions(
    organizationId: string,
    roleId: string,
    requestedPermissionCodes: string[],
    grantedByUserId: string,
  ): Promise<string[]> {
    const role = await this.requireOwnedRole(organizationId, roleId);

    const effectiveCodes = role.isOwnerRole
      ? new Set(ALL_PERMISSION_CODES)
      : new Set(requestedPermissionCodes);

    if (!effectiveCodes.size) {
      throw new BadRequestException("At least one permission code is required");
    }

    const permissions = await this.prisma.permission.findMany({
      where: { code: { in: Array.from(effectiveCodes) } },
    });
    if (permissions.length === 0) {
      throw new BadRequestException("None of the requested permission codes exist");
    }

    await this.prisma.$transaction([
      this.prisma.rolePermission.deleteMany({ where: { roleId } }),
      this.prisma.rolePermission.createMany({
        data: permissions.map((permission) => ({
          roleId,
          permissionId: permission.id,
          grantedByUserId,
        })),
      }),
    ]);

    const grantedCodes = permissions.map((p) => p.code);
    if (role.isOwnerRole && !grantedCodes.includes(MANAGE_ROLES_PERMISSION)) {
      // Should be unreachable given effectiveCodes above, but guard against
      // a future catalog edit silently dropping role.manage from the DB.
      throw new ForbiddenException(
        "The Trust President role can never be stripped of the 'manage roles' permission.",
      );
    }

    return grantedCodes;
  }

  private async requireOwnedRole(organizationId: string, roleId: string) {
    const role = await this.prisma.organizationRole.findUnique({ where: { id: roleId } });
    if (!role || role.organizationId !== organizationId) {
      throw new NotFoundException("Role not found");
    }
    return role;
  }
}
