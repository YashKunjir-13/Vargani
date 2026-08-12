import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { OrganizationStatus, PrismaService } from "@pauti-pustak/backend-database";
import { PanEncryptionService } from "@pauti-pustak/backend-security";
import { CloseOrganizationDto } from "./dto/close-organization.dto";
import { ConfigureBankingDto } from "./dto/configure-banking.dto";
import { UpdateOrganizationDto } from "./dto/update-organization.dto";

@Injectable()
export class OrganizationsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly panEncryptionService: PanEncryptionService,
  ) {}

  async searchPublicOrganizations(params: { q?: string; city?: string; limit?: number }) {
    const { q, city, limit = 50 } = params;
    const where: any = {
      status: OrganizationStatus.ACTIVE,
    };

    if (q) {
      const searchTerm = q.trim();
      where.OR = [
        { name: { contains: searchTerm, mode: "insensitive" } },
        { city: { contains: searchTerm, mode: "insensitive" } },
        { code: { contains: searchTerm, mode: "insensitive" } },
      ];
    } else if (city) {
      where.city = { contains: city.trim(), mode: "insensitive" };
    }

    return this.prisma.organization.findMany({
      where,
      select: {
        id: true,
        code: true,
        name: true,
        city: true,
        state: true,
        logoDocumentId: true,
        primaryMobile: true,
        primaryEmail: true,
      },
      orderBy: { name: "asc" },
      take: limit,
    });
  }

  async getPublicOrganizationDetails(organizationId: string) {
    const org = await this.prisma.organization.findUnique({
      where: { id: organizationId, status: OrganizationStatus.ACTIVE },
      select: {
        id: true,
        code: true,
        name: true,
        addressLine1: true,
        addressLine2: true,
        city: true,
        state: true,
        postalCode: true,
        registrationNumber: true,
        presidentName: true,
        primaryMobile: true,
        primaryEmail: true,
        bankAccountName: true,
        bankName: true,
        accountNumber: true,
        ifscCode: true,
        branchName: true,
        vpa: true,
        bankAccountConfigured: true,
        upiConfigured: true,
      },
    });
    if (!org) {
      throw new NotFoundException("Organization not found or inactive");
    }
    return org;
  }

  async getCurrent(organizationId: string) {
    const org = await this.prisma.organization.findUnique({
      where: { id: organizationId },
      include: {
        settings: true,
      },
    });

    if (!org) {
      throw new NotFoundException("Organization not found");
    }

    return this.maskSensitiveOrganization(org);
  }

  async updateCurrent(organizationId: string, userId: string, dto: UpdateOrganizationDto) {
    const org = await this.prisma.organization.findUnique({ where: { id: organizationId } });
    if (!org || org.status === OrganizationStatus.CLOSED) {
      throw new ForbiddenException("Organization is closed or inactive");
    }

    const updated = await this.prisma.organization.update({
      where: { id: organizationId },
      data: {
        ...(dto.name ? { name: dto.name } : {}),
        ...(dto.addressLine1 ? { addressLine1: dto.addressLine1 } : {}),
        ...(dto.addressLine2 !== undefined ? { addressLine2: dto.addressLine2 } : {}),
        ...(dto.city ? { city: dto.city } : {}),
        ...(dto.state ? { state: dto.state } : {}),
        ...(dto.postalCode ? { postalCode: dto.postalCode } : {}),
        ...(dto.registrationNumber !== undefined ? { registrationNumber: dto.registrationNumber } : {}),
        ...(dto.presidentName !== undefined ? { presidentName: dto.presidentName } : {}),
      },
    });

    return this.maskSensitiveOrganization(updated);
  }

  async configureBanking(organizationId: string, userId: string, dto: ConfigureBankingDto) {
    const org = await this.prisma.organization.findUnique({ where: { id: organizationId } });
    if (!org || org.status === OrganizationStatus.CLOSED) {
      throw new ForbiddenException("Organization is closed or inactive");
    }

    const panEncrypted = dto.panNumber
      ? this.panEncryptionService.encrypt(dto.panNumber)
      : org.panEncrypted;

    const vpaValue = (dto.vpa || dto.upiId)?.trim();

    const updated = await this.prisma.organization.update({
      where: { id: organizationId },
      data: {
        panEncrypted,
        ...(dto.bankAccountName !== undefined ? { bankAccountName: dto.bankAccountName.trim() } : {}),
        ...(dto.bankName !== undefined ? { bankName: dto.bankName.trim() } : {}),
        ...(dto.accountNumber !== undefined ? { accountNumber: dto.accountNumber.trim() } : {}),
        ...(dto.ifscCode !== undefined ? { ifscCode: dto.ifscCode.trim().toUpperCase() } : {}),
        ...(dto.branchName !== undefined ? { branchName: dto.branchName.trim() } : {}),
        ...(vpaValue !== undefined ? { vpa: vpaValue } : {}),
        bankAccountConfigured: Boolean(dto.accountNumber || dto.ifscCode) || org.bankAccountConfigured,
        upiConfigured: Boolean(vpaValue) || org.upiConfigured,
      },
    });

    return this.maskSensitiveOrganization(updated);
  }

  async resubmit(organizationId: string, userId: string) {
    const org = await this.prisma.organization.findUnique({ where: { id: organizationId } });
    if (!org) {
      throw new NotFoundException("Organization not found");
    }

    if (org.status !== OrganizationStatus.CORRECTION_REQUIRED && org.status !== OrganizationStatus.REJECTED) {
      throw new BadRequestException("Organization status does not allow resubmission");
    }

    const updated = await this.prisma.organization.update({
      where: { id: organizationId },
      data: {
        status: OrganizationStatus.ACTIVE,
        correctionNotes: null,
        statusReason: "Resubmitted by Owner",
      },
    });

    return this.maskSensitiveOrganization(updated);
  }

  async close(organizationId: string, userId: string, dto: CloseOrganizationDto) {
    const org = await this.prisma.organization.findUnique({ where: { id: organizationId } });
    if (!org) {
      throw new NotFoundException("Organization not found");
    }

    if (org.status === OrganizationStatus.CLOSED) {
      throw new BadRequestException("Organization is already closed");
    }

    const updated = await this.prisma.organization.update({
      where: { id: organizationId },
      data: {
        status: OrganizationStatus.CLOSED,
        closedAt: new Date(),
        statusReason: dto.reason,
      },
    });

    return this.maskSensitiveOrganization(updated);
  }

  private maskSensitiveOrganization(org: any) {
    let panMasked: string | null = null;
    if (org.panEncrypted) {
      try {
        const decrypted = this.panEncryptionService.decrypt(org.panEncrypted);
        panMasked = `${decrypted.slice(0, 2)}XXXXX${decrypted.slice(-2)}`;
      } catch {
        panMasked = "XXXXXXXXXX";
      }
    }

    let accountNumberMasked: string | null = null;
    if (org.accountNumber && org.accountNumber.length > 4) {
      accountNumberMasked = `XXXX XXXX ${org.accountNumber.slice(-4)}`;
    } else if (org.accountNumber) {
      accountNumberMasked = org.accountNumber;
    }

    const { panEncrypted, ...safeOrg } = org;
    return {
      ...safeOrg,
      panMasked,
      accountNumberMasked,
    };
  }
}
