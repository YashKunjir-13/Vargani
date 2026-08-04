import { Test, TestingModule } from "@nestjs/testing";
import { OrganizationStatus, PrismaService } from "@pauti-pustak/backend-database";
import { NotFoundException } from "@nestjs/common";
import { PlatformAdminService } from "./platform-admin.service";

describe("PlatformAdminService (Phase 5 Unit Tests)", () => {
  let service: PlatformAdminService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      organization: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PlatformAdminService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get<PlatformAdminService>(PlatformAdminService);
  });

  describe("Platform Organization Approval", () => {
    it("approves pending organization registration", async () => {
      prisma.organization.findUnique.mockResolvedValue({ id: "org-1", status: OrganizationStatus.CORRECTION_REQUIRED });
      prisma.organization.update.mockResolvedValue({ id: "org-1", status: OrganizationStatus.ACTIVE });

      const res = await service.approveOrganization("org-1", "super-admin-1");

      expect(res.status).toBe(OrganizationStatus.ACTIVE);
      expect(prisma.organization.update).toHaveBeenCalledWith({
        where: { id: "org-1" },
        data: expect.objectContaining({ status: OrganizationStatus.ACTIVE }),
      });
    });

    it("throws NotFoundException if organization does not exist", async () => {
      prisma.organization.findUnique.mockResolvedValue(null);

      await expect(service.approveOrganization("org-invalid", "super-admin-1")).rejects.toThrow(NotFoundException);
    });
  });
});
