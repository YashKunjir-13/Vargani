import { Test, TestingModule } from "@nestjs/testing";
import { PreferredLanguage, PrismaService, PublicVisibility } from "@pauti-pustak/backend-database";
import { SettingsService } from "./settings.service";

describe("SettingsService (Phase 0 Unit Tests)", () => {
  let service: SettingsService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      organizationSettings: {
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      organizationSettingsHistory: {
        create: jest.fn(),
        findMany: jest.fn(),
      },
      platformSettings: {
        findFirst: jest.fn(),
        create: jest.fn(),
      },
      organization: {
        findUnique: jest.fn(),
      },
      $transaction: jest.fn((callback) => callback(prisma)),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SettingsService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get<SettingsService>(SettingsService);
  });

  it("creates default organization settings if none exist", async () => {
    prisma.organizationSettings.findUnique.mockResolvedValue(null);
    prisma.organization.findUnique.mockResolvedValue({ ownerUserId: "owner-1" });
    prisma.organizationSettings.create.mockResolvedValue({
      id: "set-1",
      organizationId: "org-1",
      version: 1,
      defaultLanguage: PreferredLanguage.EN,
    });

    const res = await service.getOrganizationSettings("org-1");
    expect(res.organizationId).toBe("org-1");
    expect(prisma.organizationSettings.create).toHaveBeenCalled();
  });

  it("increments version and writes history snapshot on settings update", async () => {
    const currentSettings = {
      id: "set-1",
      organizationId: "org-1",
      version: 1,
      defaultLanguage: PreferredLanguage.EN,
      enabledLanguages: [PreferredLanguage.EN],
      timezone: "Asia/Kolkata",
    };
    prisma.organizationSettings.findUnique.mockResolvedValue(currentSettings);
    prisma.organizationSettings.update.mockResolvedValue({
      ...currentSettings,
      version: 2,
      defaultLanguage: PreferredLanguage.MR,
    });

    const updated = await service.updateOrganizationSettings("org-1", "user-1", {
      defaultLanguage: PreferredLanguage.MR,
      changeReason: "Switched to Marathi default",
    });

    expect(updated.version).toBe(2);
    expect(prisma.organizationSettingsHistory.create).toHaveBeenCalledWith({
      data: {
        organizationId: "org-1",
        version: 1,
        snapshot: currentSettings,
        changedByUserId: "user-1",
        changeReason: "Switched to Marathi default",
      },
    });
  });
});
