import { Test, TestingModule } from "@nestjs/testing";
import { OrganizationStatus, PrismaService } from "@pauti-pustak/backend-database";
import { PanEncryptionService } from "@pauti-pustak/backend-security";
import { BadRequestException, ForbiddenException } from "@nestjs/common";
import { OrganizationsService } from "./organizations.service";

describe("OrganizationsService (Phase 0 Unit Tests)", () => {
  let service: OrganizationsService;
  let prisma: any;
  let panEncryptionService: PanEncryptionService;

  beforeEach(async () => {
    prisma = {
      organization: {
        findUnique: jest.fn(),
        update: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OrganizationsService,
        { provide: PrismaService, useValue: prisma },
        PanEncryptionService,
      ],
    }).compile();

    service = module.get<OrganizationsService>(OrganizationsService);
    panEncryptionService = module.get<PanEncryptionService>(PanEncryptionService);
  });

  it("retrieves organization profile with masked PAN details", async () => {
    const encryptedPan = panEncryptionService.encrypt("ABCDE1234F");
    prisma.organization.findUnique.mockResolvedValue({
      id: "org-1",
      code: "ORG123",
      name: "Test Mandal",
      panEncrypted: encryptedPan,
      status: OrganizationStatus.ACTIVE,
    });

    const res = await service.getCurrent("org-1");
    expect(res.name).toBe("Test Mandal");
    expect(res.panMasked).toBe("ABXXXXX4F");
    expect((res as any).panEncrypted).toBeUndefined();
  });

  it("configures banking and encrypts PAN number", async () => {
    prisma.organization.findUnique.mockResolvedValue({
      id: "org-1",
      status: OrganizationStatus.ACTIVE,
      bankAccountConfigured: false,
    });
    prisma.organization.update.mockImplementation(({ data }: any) =>
      Promise.resolve({ id: "org-1", ...data, status: OrganizationStatus.ACTIVE }),
    );

    const res = await service.configureBanking("org-1", "user-1", {
      panNumber: "XYZAB5678C",
      accountNumber: "1234567890",
      ifscCode: "SBIN0001234",
    });

    expect(res.bankAccountConfigured).toBe(true);
    expect(res.panMasked).toBe("XYXXXXX8C");
  });

  it("closes organization with mandatory reason", async () => {
    prisma.organization.findUnique.mockResolvedValue({
      id: "org-1",
      status: OrganizationStatus.ACTIVE,
    });
    prisma.organization.update.mockResolvedValue({
      id: "org-1",
      status: OrganizationStatus.CLOSED,
      closedAt: new Date(),
      statusReason: "Audit complete",
    });

    const res = await service.close("org-1", "user-1", { reason: "Audit complete" });
    expect(res.status).toBe(OrganizationStatus.CLOSED);
  });
});
