import { Test, TestingModule } from "@nestjs/testing";
import { PrismaService } from "@pauti-pustak/backend-database";
import { ConflictException, ForbiddenException } from "@nestjs/common";
import { RolesService } from "./roles.service";

describe("RolesService (Phase 0 Unit Tests)", () => {
  let service: RolesService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      permission: {
        findMany: jest.fn(),
      },
      organizationRole: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
      },
      rolePermission: {
        deleteMany: jest.fn(),
        createMany: jest.fn(),
      },
      organizationMembership: {
        count: jest.fn(),
      },
      $transaction: jest.fn((callback) => callback(prisma)),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RolesService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get<RolesService>(RolesService);
  });

  describe("Owner Role Protection (FR54)", () => {
    it("prevents deactivating the Owner role", async () => {
      prisma.organizationRole.findFirst.mockResolvedValue({
        id: "role-owner-1",
        organizationId: "org-1",
        name: "Owner",
        isOwnerRole: true,
      });

      await expect(
        service.updateRole("org-1", "role-owner-1", "user-1", {
          isActive: false,
        }),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe("Custom Role Deletion (FR55)", () => {
    it("returns 409 Conflict if role is assigned to active members", async () => {
      prisma.organizationRole.findFirst.mockResolvedValue({
        id: "role-custom-1",
        organizationId: "org-1",
        name: "Custom Approver",
        isOwnerRole: false,
        isSystem: false,
      });
      prisma.organizationMembership.count.mockResolvedValue(3);

      await expect(service.deleteRole("org-1", "role-custom-1")).rejects.toThrow(ConflictException);
    });
  });
});
