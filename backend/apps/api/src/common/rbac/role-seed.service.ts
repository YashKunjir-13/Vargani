import { Injectable } from "@nestjs/common";
import { PrismaService } from "@pauti-pustak/backend-database";
import { DEFAULT_ROLE_DEFINITIONS, PERMISSION_CATALOG } from "./role-catalog";

@Injectable()
export class RoleSeedService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Idempotently ensures every Permission row in PERMISSION_CATALOG exists.
   * Call once at application bootstrap (or via a migration/seed script),
   * not per-organization -- Permission is a global, not tenant-scoped,
   * table.
   */
  async ensurePermissionCatalog(): Promise<void> {
    for (const definition of PERMISSION_CATALOG) {
      await this.prisma.permission.upsert({
        where: { code: definition.code },
        update: {
          module: definition.module,
          action: definition.action,
          description: definition.description,
        },
        create: definition,
      });
    }
  }

  /**
   * Creates the default role set (Trust President, Vice President,
   * Secretary, Treasurer, Volunteer, Donor) for a newly-created
   * organization. Call this once, inside the same transaction that creates
   * the Organization row.
   */
  async seedDefaultRoles(organizationId: string, createdByUserId: string): Promise<void> {
    const permissions = await this.prisma.permission.findMany({
      where: { code: { in: PERMISSION_CATALOG.map((p) => p.code) } },
    });
    const permissionIdByCode = new Map(permissions.map((p) => [p.code, p.id]));

    for (const roleDefinition of DEFAULT_ROLE_DEFINITIONS) {
      const role = await this.prisma.organizationRole.create({
        data: {
          organizationId,
          name: roleDefinition.name,
          description: roleDefinition.description,
          isSystem: roleDefinition.isSystem,
          isOwnerRole: roleDefinition.isOwnerRole,
          createdByUserId,
        },
      });

      // The Trust President/owner role always gets full scope regardless of
      // the illustrative subset configured in DEFAULT_ROLE_DEFINITIONS.
      const grantedCodes = roleDefinition.isOwnerRole
        ? PERMISSION_CATALOG.map((p) => p.code)
        : roleDefinition.permissions;

      const rolePermissionRows = grantedCodes
        .map((code) => permissionIdByCode.get(code))
        .filter((permissionId): permissionId is string => Boolean(permissionId))
        .map((permissionId) => ({
          roleId: role.id,
          permissionId,
          grantedByUserId: createdByUserId,
        }));

      if (rolePermissionRows.length > 0) {
        await this.prisma.rolePermission.createMany({ data: rolePermissionRows });
      }
    }
  }
}
