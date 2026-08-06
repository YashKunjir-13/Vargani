import { Injectable, NotFoundException } from "@nestjs/common";
import { PreferredLanguage, PrismaService, PublicVisibility } from "@pauti-pustak/backend-database";
import { UpdateOrganizationSettingsDto } from "./dto/update-organization-settings.dto";
import { UpdatePlatformSettingsDto } from "./dto/update-platform-settings.dto";

@Injectable()
export class SettingsService {
  constructor(private readonly prisma: PrismaService) {}

  async getOrganizationSettings(organizationId: string) {
    let settings = await this.prisma.organizationSettings.findUnique({
      where: { organizationId },
    });

    if (!settings) {
      // Find org owner to associate default creation
      const org = await this.prisma.organization.findUnique({ where: { id: organizationId } });
      const ownerId = org?.ownerUserId ?? "00000000-0000-0000-0000-000000000000";

      settings = await this.prisma.organizationSettings.create({
        data: {
          organizationId,
          version: 1,
          defaultLanguage: PreferredLanguage.EN,
          enabledLanguages: [PreferredLanguage.EN, PreferredLanguage.MR, PreferredLanguage.HI],
          timezone: "Asia/Kolkata",
          financialYearStartMonth: 4,
          financialYearStartDay: 1,
          invitationAcceptanceRequired: false,
          defaultDonorVisibility: PublicVisibility.NAME_AND_AMOUNT,
          inKindValueRequired: false,
          includeInKindInContributionTotal: true,
          collectorBoundReceiptBooks: false,
          receiptTemplateCode: "STANDARD_TRILINGUAL",
          whatsappEnabled: true,
          emailEnabled: true,
          inAppEnabled: true,
          updatedByUserId: ownerId,
        },
      });
    }

    return settings;
  }

  async updateOrganizationSettings(organizationId: string, userId: string, dto: UpdateOrganizationSettingsDto) {
    const current = await this.getOrganizationSettings(organizationId);

    const newVersion = current.version + 1;
    const { changeReason, ...updateFields } = dto;

    const updated = await this.prisma.$transaction(async (tx) => {
      // Create historical snapshot of current state before applying updates
      await tx.organizationSettingsHistory.create({
        data: {
          organizationId,
          version: current.version,
          snapshot: current as any,
          changedByUserId: userId,
          changeReason: changeReason ?? "Settings updated",
        },
      });

      return tx.organizationSettings.update({
        where: { organizationId },
        data: {
          ...updateFields,
          version: newVersion,
          updatedByUserId: userId,
        },
      });
    });

    return updated;
  }

  async getSettingsHistory(organizationId: string) {
    return this.prisma.organizationSettingsHistory.findMany({
      where: { organizationId },
      orderBy: { version: "desc" },
    });
  }

  async getPlatformSettings() {
    let settings = await this.prisma.platformSettings.findFirst({
      orderBy: { version: "desc" },
    });

    if (!settings) {
      settings = await this.prisma.platformSettings.create({
        data: {
          version: 1,
          supportedEventTypes: ["GANPATI", "NAVRATRI", "DIWALI", "GENERAL"],
          maxFileSizeBytes: 10485760,
          maxLogoSizeBytes: 5242880,
          maxAttachmentsPerEntity: 5,
          featureFlags: { enablePersonalizedBills: true, enableVolunteerApp: true },
          updatedByUserId: "00000000-0000-0000-0000-000000000000",
        },
      });
    }

    return {
      ...settings,
      maxFileSizeBytes: settings.maxFileSizeBytes.toString(),
      maxLogoSizeBytes: settings.maxLogoSizeBytes.toString(),
    };
  }

  async updatePlatformSettings(userId: string, dto: UpdatePlatformSettingsDto) {
    const current = await this.getPlatformSettings();
    const newVersion = current.version + 1;

    const created = await this.prisma.platformSettings.create({
      data: {
        version: newVersion,
        supportedEventTypes: (dto.supportedEventTypes ?? current.supportedEventTypes) as any,
        maxFileSizeBytes: dto.maxFileSizeBytes ? BigInt(dto.maxFileSizeBytes) : BigInt(current.maxFileSizeBytes),
        maxLogoSizeBytes: dto.maxLogoSizeBytes ? BigInt(dto.maxLogoSizeBytes) : BigInt(current.maxLogoSizeBytes),
        maxAttachmentsPerEntity: dto.maxAttachmentsPerEntity ?? current.maxAttachmentsPerEntity,
        featureFlags: (dto.featureFlags ?? current.featureFlags) as any,
        updatedByUserId: userId,
      },
    });

    return {
      ...created,
      maxFileSizeBytes: created.maxFileSizeBytes.toString(),
      maxLogoSizeBytes: created.maxLogoSizeBytes.toString(),
    };
  }
}
