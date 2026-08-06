import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { BillingMode, ContributorAccountStatus, PrismaService, PublicVisibility } from "@pauti-pustak/backend-database";
import { randomInt } from "crypto";
import { CreateContributorAccountDto } from "./dto/create-contributor-account.dto";
import { MergeContributorAccountsDto } from "./dto/merge-contributor-accounts.dto";
import { UpdateContributorAccountDto } from "./dto/update-contributor-account.dto";

@Injectable()
export class ContributorService {
  constructor(private readonly prisma: PrismaService) {}

  async listAccounts(
    organizationId: string,
    eventId: string,
    filters?: { areaCode?: string; routeCode?: string; assignedVolunteerId?: string; status?: ContributorAccountStatus },
  ) {
    const accounts = await this.prisma.contributorAccount.findMany({
      where: {
        organizationId,
        eventId,
        ...(filters?.areaCode ? { areaCode: filters.areaCode } : {}),
        ...(filters?.routeCode ? { routeCode: filters.routeCode } : {}),
        ...(filters?.assignedVolunteerId ? { assignedVolunteerId: filters.assignedVolunteerId } : {}),
        ...(filters?.status ? { status: filters.status } : { status: ContributorAccountStatus.ACTIVE }),
      },
      orderBy: { createdAt: "desc" },
    });

    return accounts.map((a) => ({
      ...a,
      requestedAmountPaise: a.requestedAmountPaise ? a.requestedAmountPaise.toString() : null,
    }));
  }

  async getAccount(organizationId: string, accountId: string) {
    const account = await this.prisma.contributorAccount.findFirst({
      where: { id: accountId, organizationId },
    });

    if (!account) {
      throw new NotFoundException("Contributor account not found");
    }

    return {
      ...account,
      requestedAmountPaise: account.requestedAmountPaise ? account.requestedAmountPaise.toString() : null,
    };
  }

  async createAccount(organizationId: string, eventId: string, userId: string, dto: CreateContributorAccountDto) {
    const donor = await this.prisma.donorProfile.findUnique({ where: { id: dto.donorProfileId } });
    if (!donor) {
      throw new NotFoundException("Canonical donor profile not found");
    }

    const event = await this.prisma.event.findFirst({ where: { id: eventId, organizationId } });
    if (!event || event.status === "ARCHIVED") {
      throw new ForbiddenException("Event is inactive or archived");
    }

    const accountCode = await this.generateAccountCode(organizationId, eventId);

    const account = await this.prisma.contributorAccount.create({
      data: {
        organizationId,
        eventId,
        donorProfileId: dto.donorProfileId,
        accountCode,
        type: dto.type,
        status: ContributorAccountStatus.ACTIVE,
        displayName: dto.displayName,
        contactPerson: dto.contactPerson ?? donor.fullName,
        contactSnapshot: { mobile: donor.mobile, email: donor.email },
        billingAddressSnapshot: dto.billingAddressSnapshot ?? { addressLine1: donor.addressLine1, city: donor.city },
        areaCode: dto.areaCode,
        routeCode: dto.routeCode,
        categoryCode: dto.categoryCode,
        billingMode: dto.billingMode ?? BillingMode.SUGGESTED,
        requestedAmountPaise: dto.requestedAmountPaise ? BigInt(dto.requestedAmountPaise) : null,
        assignedVolunteerId: dto.assignedVolunteerId,
        preferredLanguage: dto.preferredLanguage ?? "mr",
        publicVisibility: dto.publicVisibility ?? PublicVisibility.NAME_AND_AMOUNT,
        createdByUserId: userId,
      },
    });

    return {
      ...account,
      requestedAmountPaise: account.requestedAmountPaise ? account.requestedAmountPaise.toString() : null,
    };
  }

  async updateAccount(organizationId: string, accountId: string, dto: UpdateContributorAccountDto) {
    const account = await this.prisma.contributorAccount.findFirst({
      where: { id: accountId, organizationId },
    });

    if (!account || account.status === ContributorAccountStatus.MERGED) {
      throw new ForbiddenException("Account cannot be updated");
    }

    const updated = await this.prisma.contributorAccount.update({
      where: { id: accountId },
      data: {
        ...(dto.displayName ? { displayName: dto.displayName } : {}),
        ...(dto.contactPerson !== undefined ? { contactPerson: dto.contactPerson } : {}),
        ...(dto.areaCode !== undefined ? { areaCode: dto.areaCode } : {}),
        ...(dto.routeCode !== undefined ? { routeCode: dto.routeCode } : {}),
        ...(dto.categoryCode !== undefined ? { categoryCode: dto.categoryCode } : {}),
        ...(dto.billingMode ? { billingMode: dto.billingMode } : {}),
        ...(dto.requestedAmountPaise !== undefined
          ? { requestedAmountPaise: dto.requestedAmountPaise ? BigInt(dto.requestedAmountPaise) : null }
          : {}),
        ...(dto.publicVisibility ? { publicVisibility: dto.publicVisibility } : {}),
        ...(dto.billingAddressSnapshot ? { billingAddressSnapshot: dto.billingAddressSnapshot } : {}),
      },
    });

    return {
      ...updated,
      requestedAmountPaise: updated.requestedAmountPaise ? updated.requestedAmountPaise.toString() : null,
    };
  }

  async reassignCollector(organizationId: string, accountId: string, volunteerId: string | undefined) {
    const account = await this.prisma.contributorAccount.findFirst({
      where: { id: accountId, organizationId },
    });

    if (!account) {
      throw new NotFoundException("Contributor account not found");
    }

    if (volunteerId) {
      const volunteer = await this.prisma.volunteer.findFirst({
        where: { id: volunteerId, organizationId, status: "ACTIVE" },
      });
      if (!volunteer) {
        throw new NotFoundException("Active volunteer not found for assignment");
      }
    }

    const updated = await this.prisma.contributorAccount.update({
      where: { id: accountId },
      data: { assignedVolunteerId: volunteerId ?? null },
    });

    return {
      accountId: updated.id,
      assignedVolunteerId: updated.assignedVolunteerId,
    };
  }

  async mergePreview(organizationId: string, survivingAccountId: string, mergedAccountId: string) {
    const surviving = await this.prisma.contributorAccount.findFirst({ where: { id: survivingAccountId, organizationId } });
    const merged = await this.prisma.contributorAccount.findFirst({ where: { id: mergedAccountId, organizationId } });

    if (!surviving || !merged) {
      throw new NotFoundException("One or both contributor accounts were not found");
    }

    const billsCount = await this.prisma.contributionBill.count({ where: { contributorAccountId: merged.id } });
    const collectionsCount = await this.prisma.collectionRecord.count({ where: { contributorAccountId: merged.id } });

    return {
      survivingAccount: { id: surviving.id, accountCode: surviving.accountCode, displayName: surviving.displayName },
      mergedAccount: { id: merged.id, accountCode: merged.accountCode, displayName: merged.displayName },
      impactReport: {
        billsToReassign: billsCount,
        collectionsToReassign: collectionsCount,
        requiresApproval: billsCount > 0,
      },
    };
  }

  async mergeAccounts(organizationId: string, userId: string, dto: MergeContributorAccountsDto) {
    if (dto.survivingAccountId === dto.mergedAccountId) {
      throw new BadRequestException("Surviving account and merged account cannot be identical");
    }

    const surviving = await this.prisma.contributorAccount.findFirst({ where: { id: dto.survivingAccountId, organizationId } });
    const merged = await this.prisma.contributorAccount.findFirst({ where: { id: dto.mergedAccountId, organizationId } });

    if (!surviving || !merged) {
      throw new NotFoundException("One or both contributor accounts were not found");
    }

    if (surviving.status === ContributorAccountStatus.MERGED || merged.status === ContributorAccountStatus.MERGED) {
      throw new ConflictException("Account has already been merged");
    }

    return this.prisma.$transaction(async (tx) => {
      await tx.contributionBill.updateMany({
        where: { contributorAccountId: merged.id },
        data: { contributorAccountId: surviving.id },
      });

      await tx.collectionRecord.updateMany({
        where: { contributorAccountId: merged.id },
        data: { contributorAccountId: surviving.id },
      });

      const updatedMerged = await tx.contributorAccount.update({
        where: { id: merged.id },
        data: { status: ContributorAccountStatus.MERGED },
      });

      return {
        survivingAccountId: surviving.id,
        mergedAccountId: merged.id,
        status: updatedMerged.status,
      };
    });
  }

  private async generateAccountCode(organizationId: string, eventId: string): Promise<string> {
    for (let attempt = 0; attempt < 5; attempt += 1) {
      const suffix = randomInt(1000, 9999).toString();
      const accountCode = `ACC-${suffix}`;
      const existing = await this.prisma.contributorAccount.findUnique({
        where: { organizationId_eventId_accountCode: { organizationId, eventId, accountCode } },
      });
      if (!existing) {
        return accountCode;
      }
    }
    throw new ConflictException("Could not generate unique contributor account code");
  }
}
