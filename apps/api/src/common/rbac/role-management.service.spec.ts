import { ForbiddenException, NotFoundException } from "@nestjs/common";
import { RoleManagementService } from "./role-management.service";
import { ALL_PERMISSION_CODES, MANAGE_ROLES_PERMISSION, PERMISSION_CATALOG } from "./role-catalog";

const ORG_ID = "org-1";
const TRUST_PRESIDENT_ROLE_ID = "role-trust-president";
const VOLUNTEER_ROLE_ID = "role-volunteer";

function buildPrismaMock() {
  const roles: Record<string, any> = {
    [TRUST_PRESIDENT_ROLE_ID]: {
      id: TRUST_PRESIDENT_ROLE_ID,
      organizationId: ORG_ID,
      name: "Trust President",
      isSystem: true,
      isOwnerRole: true,
    },
    [VOLUNTEER_ROLE_ID]: {
      id: VOLUNTEER_ROLE_ID,
      organizationId: ORG_ID,
      name: "Volunteer",
      isSystem: false,
      isOwnerRole: false,
    },
  };

  const permissions = PERMISSION_CATALOG.map((definition, index) => ({
    id: `perm-${index}`,
    code: definition.code,
  }));

  return {
    organizationRole: {
      findUnique: jest.fn(({ where }: any) => Promise.resolve(roles[where.id] ?? null)),
      delete: jest.fn(({ where }: any) => {
        delete roles[where.id];
        return Promise.resolve(undefined);
      }),
    },
    permission: {
      findMany: jest.fn(({ where }: any) =>
        Promise.resolve(permissions.filter((p) => where.code.in.includes(p.code))),
      ),
    },
    rolePermission: {
      deleteMany: jest.fn(() => Promise.resolve({ count: 0 })),
      createMany: jest.fn(() => Promise.resolve({ count: 0 })),
    },
    $transaction: jest.fn((ops: Promise<any>[]) => Promise.all(ops)),
  };
}

describe("RoleManagementService - Trust President protection", () => {
  let prisma: ReturnType<typeof buildPrismaMock>;
  let service: RoleManagementService;

  beforeEach(() => {
    prisma = buildPrismaMock();
    service = new RoleManagementService(prisma as any);
  });

  it("refuses to delete the Trust President role", async () => {
    await expect(service.deleteRole(ORG_ID, TRUST_PRESIDENT_ROLE_ID)).rejects.toBeInstanceOf(
      ForbiddenException,
    );
    expect(prisma.organizationRole.delete).not.toHaveBeenCalled();
  });

  it("allows deleting a non-protected role", async () => {
    await service.deleteRole(ORG_ID, VOLUNTEER_ROLE_ID);
    expect(prisma.organizationRole.delete).toHaveBeenCalledWith({
      where: { id: VOLUNTEER_ROLE_ID },
    });
  });

  it("throws NotFoundException for a role belonging to a different organization", async () => {
    await expect(service.deleteRole("some-other-org", TRUST_PRESIDENT_ROLE_ID)).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it("always grants full permission scope to the Trust President role, even when a narrower set is requested", async () => {
    const granted = await service.updateRolePermissions(
      ORG_ID,
      TRUST_PRESIDENT_ROLE_ID,
      ["payment.view"], // attempt to strip everything else, including role.manage
      "admin-user",
    );

    expect(new Set(granted)).toEqual(new Set(ALL_PERMISSION_CODES));
    expect(granted).toContain(MANAGE_ROLES_PERMISSION);
  });

  it("never lets the Trust President role end up without 'manage roles', even with an empty request", async () => {
    const granted = await service.updateRolePermissions(ORG_ID, TRUST_PRESIDENT_ROLE_ID, [], "admin-user");

    expect(granted).toContain(MANAGE_ROLES_PERMISSION);
  });

  it("honors the requested subset for a non-protected role", async () => {
    const granted = await service.updateRolePermissions(
      ORG_ID,
      VOLUNTEER_ROLE_ID,
      ["payment.create", "receipt.viewOwn"],
      "admin-user",
    );

    expect(new Set(granted)).toEqual(new Set(["payment.create", "receipt.viewOwn"]));
  });
});
