import { Injectable } from "@nestjs/common";
import { PrismaService } from "@pauti-pustak/backend-database";

/**
 * Fills the documented gap in PermissionGuard: resolving a user's `roleId`
 * into the permission codes actually granted to that role right now. This
 * must be called on every request (not cached in the JWT) so a permission
 * change takes effect immediately, without waiting for token expiry --
 * matching the intent already documented on AuthenticatedUser.permissions
 * in packages/backend-security/src/auth.interfaces.ts.
 */
@Injectable()
export class PermissionResolutionService {
  constructor(private readonly prisma: PrismaService) {}

  async resolvePermissions(roleId: string | undefined): Promise<string[]> {
    if (!roleId) {
      return [];
    }

    const role = await this.prisma.organizationRole.findUnique({
      where: { id: roleId },
      include: { permissions: { include: { permission: true } } },
    });

    if (!role || !role.isActive) {
      return [];
    }

    return role.permissions
      .filter((rolePermission) => rolePermission.permission.isActive)
      .map((rolePermission) => rolePermission.permission.code);
  }
}
