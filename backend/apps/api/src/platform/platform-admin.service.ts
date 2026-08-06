import { ForbiddenException, Injectable, NotFoundException } from "@nestjs/common";
import { OrganizationStatus, PrismaService } from "@pauti-pustak/backend-database";

@Injectable()
export class PlatformAdminService {
  constructor(private readonly prisma: PrismaService) {}

  async listAllOrganizations(status?: OrganizationStatus) {
    return this.prisma.organization.findMany({
      where: status ? { status } : {},
      orderBy: { createdAt: "desc" },
    });
  }

  async approveOrganization(organizationId: string, superAdminUserId: string) {
    const org = await this.prisma.organization.findUnique({ where: { id: organizationId } });
    if (!org) {
      throw new NotFoundException("Organization not found");
    }

    if (org.status === OrganizationStatus.ACTIVE) {
      return org;
    }

    const updated = await this.prisma.organization.update({
      where: { id: organizationId },
      data: {
        status: OrganizationStatus.ACTIVE,
        activatedAt: new Date(),
      },
    });

    return updated;
  }

  async rejectOrganization(organizationId: string, superAdminUserId: string, reason: string) {
    const org = await this.prisma.organization.findUnique({ where: { id: organizationId } });
    if (!org) {
      throw new NotFoundException("Organization not found");
    }

    const updated = await this.prisma.organization.update({
      where: { id: organizationId },
      data: {
        status: OrganizationStatus.REJECTED,
        statusReason: reason,
      },
    });

    return updated;
  }
}
