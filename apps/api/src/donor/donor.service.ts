import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { DonorProfileStatus, PrismaService } from "@pauti-pustak/backend-database";
import { PanEncryptionService } from "@pauti-pustak/backend-security";
import { CreateDonorDto } from "./dto/create-donor.dto";
import { MergeDonorsDto } from "./dto/merge-donors.dto";
import { UpdateDonorDto } from "./dto/update-donor.dto";
import { SelectOrganizationDto } from "./dto/select-organization.dto";
import { CheckoutPaymentDto } from "./dto/checkout-payment.dto";
import { CreateContributorAccountDto } from "../contributor/dto/create-contributor-account.dto";

@Injectable()
export class DonorService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly panEncryptionService: PanEncryptionService,
  ) {}

  async createDonor(userId: string, orgId: string | undefined, dto: CreateDonorDto) {
    // FR18, FR20: Require full name plus mobile or email; anonymous prohibited
    if (!dto.fullName || (!dto.mobile && !dto.email)) {
      throw new BadRequestException("Full name and at least one contact (mobile or email) are required");
    }

    // FR21: Search normalized mobile and email for exact candidates to prevent duplicate profiles
    if (dto.mobile) {
      const existingMobile = await this.prisma.donorProfile.findFirst({
        where: { mobile: dto.mobile, status: { not: DonorProfileStatus.MERGED } },
      });
      if (existingMobile) {
        return existingMobile; // Return matched candidate
      }
    }

    if (dto.email) {
      const normalizedEmail = dto.email.toLowerCase().trim();
      const existingEmail = await this.prisma.donorProfile.findFirst({
        where: { email: normalizedEmail, status: { not: DonorProfileStatus.MERGED } },
      });
      if (existingEmail) {
        return existingEmail;
      }
    }

    const panEncrypted = dto.panNumber ? this.panEncryptionService.encrypt(dto.panNumber) : null;

    const donorProfile = await this.prisma.donorProfile.create({
      data: {
        userId,
        fullName: dto.fullName,
        mobile: dto.mobile,
        email: dto.email ? dto.email.toLowerCase().trim() : null,
        addressLine1: dto.addressLine1,
        city: dto.city,
        postalCode: dto.postalCode,
        panEncrypted,
        status: orgId ? DonorProfileStatus.UNCLAIMED : DonorProfileStatus.ACTIVE,
        createdByUserId: userId,
        createdByOrgId: orgId,
        ...(orgId ? {} : { claimedAt: new Date() }),
      },
    });

    return donorProfile;
  }

  async searchDonors(
    organizationId: string,
    query?: string,
    pagination?: { page?: number; limit?: number; skip?: number; take?: number },
  ) {
    const where: any = {
      status: { not: DonorProfileStatus.MERGED },
    };

    if (query) {
      where.OR = [
        { fullName: { contains: query, mode: "insensitive" } },
        { mobile: { contains: query } },
        { email: { contains: query, mode: "insensitive" } },
      ];
    }

    const take = pagination?.take ?? pagination?.limit ?? 50;
    const skip = pagination?.skip ?? (pagination?.page ? (pagination.page - 1) * take : 0);

    const [total, items] = await Promise.all([
      this.prisma.donorProfile.count({ where }),
      this.prisma.donorProfile.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip,
        take,
      }),
    ]);

    return {
      items,
      total,
      page: Math.floor(skip / take) + 1,
      limit: take,
    };
  }

  async getTrustDonorHistory(organizationId: string, donorId: string) {
    const donor = await this.prisma.donorProfile.findUnique({
      where: { id: donorId },
      include: { aliases: true },
    });

    if (!donor) {
      throw new NotFoundException("Donor profile not found");
    }

    const accounts = await this.prisma.contributorAccount.findMany({
      where: { donorProfileId: donorId, organizationId },
      orderBy: { createdAt: "desc" },
    });

    const accountIds = accounts.map((a) => a.id);

    const bills =
      accountIds.length > 0
        ? await this.prisma.contributionBill.findMany({
            where: { contributorAccountId: { in: accountIds }, organizationId },
            orderBy: { createdAt: "desc" },
          })
        : [];

    const collections =
      accountIds.length > 0
        ? await this.prisma.collectionRecord.findMany({
            where: { contributorAccountId: { in: accountIds }, organizationId, status: "CONFIRMED" },
            orderBy: { collectedAt: "desc" },
          })
        : [];

    return {
      donorProfile: donor,
      contributorAccounts: accounts.map((a) => ({
        ...a,
        requestedAmountPaise: a.requestedAmountPaise ? a.requestedAmountPaise.toString() : null,
      })),
      bills: bills.map((b) => ({
        ...b,
        sequence: b.sequence ? b.sequence.toString() : null,
        requestedAmountPaise: b.requestedAmountPaise ? b.requestedAmountPaise.toString() : null,
        waiverAmountPaise: b.waiverAmountPaise.toString(),
        payableAmountPaise: b.payableAmountPaise ? b.payableAmountPaise.toString() : null,
        confirmedCollectionPaise: b.confirmedCollectionPaise.toString(),
        outstandingAmountPaise: b.outstandingAmountPaise ? b.outstandingAmountPaise.toString() : null,
      })),
      collections: collections.map((c) => ({
        ...c,
        amountPaise: c.amountPaise.toString(),
      })),
    };
  }

  async getDonor(donorId: string) {
    const donor = await this.prisma.donorProfile.findUnique({
      where: { id: donorId },
      include: { aliases: true },
    });

    if (!donor) {
      throw new NotFoundException("Donor profile not found");
    }

    return donor;
  }

  async updateDonor(donorId: string, actorUserId: string, dto: UpdateDonorDto) {
    const donor = await this.prisma.donorProfile.findUnique({ where: { id: donorId } });
    if (!donor || donor.status === DonorProfileStatus.MERGED) {
      throw new ForbiddenException("Donor profile cannot be updated");
    }

    const updated = await this.prisma.donorProfile.update({
      where: { id: donorId },
      data: {
        ...(dto.fullName ? { fullName: dto.fullName } : {}),
        ...(dto.mobile ? { mobile: dto.mobile } : {}),
        ...(dto.email ? { email: dto.email.toLowerCase().trim() } : {}),
        ...(dto.addressLine1 !== undefined ? { addressLine1: dto.addressLine1 } : {}),
        ...(dto.city !== undefined ? { city: dto.city } : {}),
        ...(dto.postalCode !== undefined ? { postalCode: dto.postalCode } : {}),
      },
    });

    return updated;
  }

  async getSelfProfile(userId: string) {
    let donor = await this.prisma.donorProfile.findUnique({
      where: { userId },
      include: { aliases: true },
    });

    if (donor) {
      return donor;
    }

    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException("User account not found");
    }

    let candidate: any = null;
    if (user.primaryMobile) {
      candidate = await this.prisma.donorProfile.findFirst({
        where: { mobile: user.primaryMobile, status: { not: DonorProfileStatus.MERGED } },
      });
    }
    if (!candidate && user.primaryEmail) {
      candidate = await this.prisma.donorProfile.findFirst({
        where: { email: user.primaryEmail.toLowerCase().trim(), status: { not: DonorProfileStatus.MERGED } },
      });
    }

    if (candidate) {
      donor = await this.prisma.donorProfile.update({
        where: { id: candidate.id },
        data: {
          userId: user.id,
          claimedAt: new Date(),
          status: DonorProfileStatus.ACTIVE,
        },
        include: { aliases: true },
      });
      return donor;
    }

    donor = await this.prisma.donorProfile.create({
      data: {
        userId: user.id,
        fullName: user.displayName || "Donor",
        mobile: user.primaryMobile,
        email: user.primaryEmail ? user.primaryEmail.toLowerCase().trim() : null,
        status: DonorProfileStatus.ACTIVE,
        claimedAt: new Date(),
        createdByUserId: user.id,
      },
      include: { aliases: true },
    });

    return donor;
  }

  async updateSelfProfile(userId: string, dto: UpdateDonorDto) {
    const profile = await this.getSelfProfile(userId);
    const panEncrypted = dto.panNumber ? this.panEncryptionService.encrypt(dto.panNumber) : undefined;

    const updated = await this.prisma.donorProfile.update({
      where: { id: profile.id },
      data: {
        ...(dto.fullName ? { fullName: dto.fullName } : {}),
        ...(dto.mobile ? { mobile: dto.mobile } : {}),
        ...(dto.email ? { email: dto.email.toLowerCase().trim() } : {}),
        ...(dto.addressLine1 !== undefined ? { addressLine1: dto.addressLine1 } : {}),
        ...(dto.city !== undefined ? { city: dto.city } : {}),
        ...(dto.postalCode !== undefined ? { postalCode: dto.postalCode } : {}),
        ...(panEncrypted ? { panEncrypted } : {}),
      },
      include: { aliases: true },
    });

    return updated;
  }

  async getDonorOrganizations(userId: string) {
    const profile = await this.getSelfProfile(userId);

    const accounts = await this.prisma.contributorAccount.findMany({
      where: { donorProfileId: profile.id },
      select: { organizationId: true },
    });

    const orgIds = Array.from(new Set(accounts.map((a) => a.organizationId)));
    if (orgIds.length === 0) {
      return [];
    }

    return this.prisma.organization.findMany({
      where: { id: { in: orgIds }, status: "ACTIVE" },
      select: {
        id: true,
        code: true,
        name: true,
        city: true,
        state: true,
        registrationNumber: true,
        logoDocumentId: true,
      },
      orderBy: { name: "asc" },
    });
  }

  async selectOrganization(userId: string, organizationId: string) {
    const profile = await this.getSelfProfile(userId);

    const account = await this.prisma.contributorAccount.findFirst({
      where: { donorProfileId: profile.id, organizationId },
    });

    if (!account) {
      throw new ForbiddenException("You do not have a donor account associated with this organization");
    }

    const org = await this.prisma.organization.findUnique({
      where: { id: organizationId },
      select: { id: true, code: true, name: true, city: true, state: true },
    });

    if (!org) {
      throw new NotFoundException("Organization not found");
    }

    return {
      selectedOrganization: org,
      contributorAccountId: account.id,
      donorProfileId: profile.id,
    };
  }

  async getDonorEvents(userId: string, organizationId?: string) {
    let targetOrgIds: string[] = [];

    if (organizationId) {
      targetOrgIds = [organizationId];
    } else {
      const orgs = await this.getDonorOrganizations(userId);
      targetOrgIds = orgs.map((o) => o.id);
    }

    if (targetOrgIds.length === 0) {
      return [];
    }

    const events = await this.prisma.event.findMany({
      where: {
        organizationId: { in: targetOrgIds },
        status: "ACTIVE",
      },
      select: {
        id: true,
        organizationId: true,
        code: true,
        name: true,
        status: true,
        startDate: true,
        endDate: true,
        targetAmountPaise: true,
      },
      orderBy: { startDate: "desc" },
    });

    return events.map((e) => ({
      ...e,
      targetAmountPaise: e.targetAmountPaise ? e.targetAmountPaise.toString() : null,
    }));
  }

  async getDonorContributorAccounts(userId: string, organizationId?: string, eventId?: string) {
    const profile = await this.getSelfProfile(userId);

    const where: any = {
      donorProfileId: profile.id,
      status: "ACTIVE",
    };
    if (organizationId) where.organizationId = organizationId;
    if (eventId) where.eventId = eventId;

    const accounts = await this.prisma.contributorAccount.findMany({
      where,
      orderBy: { createdAt: "desc" },
    });

    return accounts.map((a) => ({
      ...a,
      requestedAmountPaise: a.requestedAmountPaise ? a.requestedAmountPaise.toString() : null,
    }));
  }

  async createDonorContributorAccount(
    userId: string,
    organizationId: string,
    eventId: string,
    dto: CreateContributorAccountDto,
  ) {
    const profile = await this.getSelfProfile(userId);
    const accountCode = `DONOR-${Date.now().toString(36).toUpperCase()}`;

    const contactSnapshot = {
      fullName: profile.fullName,
      mobile: profile.mobile,
      email: profile.email,
    };

    const billingAddressSnapshot = dto.billingAddressSnapshot ?? {
      addressLine1: profile.addressLine1 ?? "",
      city: profile.city ?? "",
      postalCode: profile.postalCode ?? "",
    };

    const account = await this.prisma.contributorAccount.create({
      data: {
        organizationId,
        eventId,
        donorProfileId: profile.id,
        accountCode,
        type: dto.type ?? "INDIVIDUAL",
        displayName: dto.displayName,
        contactPerson: dto.contactPerson ?? profile.fullName,
        contactSnapshot,
        billingAddressSnapshot,
        areaCode: dto.areaCode,
        routeCode: dto.routeCode,
        categoryCode: dto.categoryCode,
        billingMode: dto.billingMode ?? "SUGGESTED",
        requestedAmountPaise: dto.requestedAmountPaise ? BigInt(dto.requestedAmountPaise) : null,
        publicVisibility: dto.publicVisibility ?? "NAME_AND_AMOUNT",
        createdByUserId: userId,
      },
    });

    return {
      ...account,
      requestedAmountPaise: account.requestedAmountPaise ? account.requestedAmountPaise.toString() : null,
    };
  }

  async getDonorBills(userId: string, organizationId?: string) {
    const profile = await this.getSelfProfile(userId);
    const accounts = await this.prisma.contributorAccount.findMany({
      where: { donorProfileId: profile.id },
      select: { id: true },
    });

    const accountIds = accounts.map((a) => a.id);
    if (accountIds.length === 0) {
      return [];
    }

    const where: any = {
      contributorAccountId: { in: accountIds },
      status: { in: ["ISSUED", "PARTIALLY_PAID", "OVERDUE"] },
    };
    if (organizationId) {
      where.organizationId = organizationId;
    }

    const bills = await this.prisma.contributionBill.findMany({
      where,
      orderBy: { createdAt: "desc" },
    });

    return bills.map((b) => ({
      ...b,
      sequence: b.sequence ? b.sequence.toString() : null,
      requestedAmountPaise: b.requestedAmountPaise ? b.requestedAmountPaise.toString() : null,
      waiverAmountPaise: b.waiverAmountPaise.toString(),
      payableAmountPaise: b.payableAmountPaise ? b.payableAmountPaise.toString() : null,
      confirmedCollectionPaise: b.confirmedCollectionPaise.toString(),
      outstandingAmountPaise: b.outstandingAmountPaise ? b.outstandingAmountPaise.toString() : null,
    }));
  }

  async getDonorBillDetails(userId: string, billId: string) {
    const profile = await this.getSelfProfile(userId);

    const bill = await this.prisma.contributionBill.findUnique({
      where: { id: billId },
      include: { lines: true },
    });

    if (!bill) {
      throw new NotFoundException("Bill not found");
    }

    const account = await this.prisma.contributorAccount.findUnique({
      where: { id: bill.contributorAccountId },
    });

    if (!account || account.donorProfileId !== profile.id) {
      throw new ForbiddenException("Access denied: You do not own this bill");
    }

    return {
      ...bill,
      sequence: bill.sequence ? bill.sequence.toString() : null,
      requestedAmountPaise: bill.requestedAmountPaise ? bill.requestedAmountPaise.toString() : null,
      waiverAmountPaise: bill.waiverAmountPaise.toString(),
      payableAmountPaise: bill.payableAmountPaise ? bill.payableAmountPaise.toString() : null,
      confirmedCollectionPaise: bill.confirmedCollectionPaise.toString(),
      outstandingAmountPaise: bill.outstandingAmountPaise ? bill.outstandingAmountPaise.toString() : null,
    };
  }

  async checkoutPayment(userId: string, dto: CheckoutPaymentDto) {
    const profile = await this.getSelfProfile(userId);

    let contributorAccountId = dto.contributorAccountId;
    let bill: any = null;

    if (dto.billId) {
      bill = await this.prisma.contributionBill.findUnique({ where: { id: dto.billId } });
      if (!bill) {
        throw new NotFoundException("Bill not found");
      }
      contributorAccountId = bill.contributorAccountId;
    }

    if (!contributorAccountId) {
      const existingAccount = await this.prisma.contributorAccount.findFirst({
        where: { donorProfileId: profile.id, organizationId: dto.organizationId, eventId: dto.eventId },
      });
      if (existingAccount) {
        contributorAccountId = existingAccount.id;
      } else {
        const newAccount = await this.createDonorContributorAccount(userId, dto.organizationId, dto.eventId, {
          displayName: profile.fullName,
          type: "INDIVIDUAL" as any,
          donorProfileId: profile.id,
        });
        contributorAccountId = newAccount.id;
      }
    } else {
      const account = await this.prisma.contributorAccount.findUnique({ where: { id: contributorAccountId } });
      if (!account || account.donorProfileId !== profile.id) {
        throw new ForbiddenException("Access denied: Contributor account does not belong to you");
      }
    }

    const amountPaise = BigInt(dto.amountPaise);
    const idempotencyKey = `CHK-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;

    const result = await this.prisma.$transaction(async (tx) => {
      const collectionRecord = await tx.collectionRecord.create({
        data: {
          organizationId: dto.organizationId,
          eventId: dto.eventId,
          contributorAccountId,
          billId: dto.billId ?? null,
          status: "CONFIRMED",
          mode: dto.mode,
          source: "PUBLIC_PAYMENT",
          amountPaise,
          collectedAt: new Date(),
          paymentReference: dto.paymentReference ?? `ONLINE-${Date.now()}`,
          idempotencyKey,
          createdByUserId: userId,
          contributorSnapshot: {
            fullName: profile.fullName,
            mobile: profile.mobile,
            email: profile.email,
          },
        },
      });

      if (bill) {
        const newConfirmed = bill.confirmedCollectionPaise + amountPaise;
        const payable = bill.payableAmountPaise ?? BigInt(0);
        const isPaid = newConfirmed >= payable;

        await tx.contributionBill.update({
          where: { id: bill.id },
          data: {
            confirmedCollectionPaise: newConfirmed,
            status: isPaid ? "PAID" : "PARTIALLY_PAID",
          },
        });
      }

      return collectionRecord;
    });

    return {
      collectionRecordId: result.id,
      amountPaise: result.amountPaise.toString(),
      status: result.status,
      collectedAt: result.collectedAt,
    };
  }

  async getDonorReceipts(userId: string, organizationId?: string) {
    const profile = await this.getSelfProfile(userId);
    const accounts = await this.prisma.contributorAccount.findMany({
      where: { donorProfileId: profile.id },
      select: { id: true },
    });

    const accountIds = accounts.map((a) => a.id);
    if (accountIds.length === 0) {
      return [];
    }

    const where: any = {
      contributorAccountId: { in: accountIds },
      status: "CONFIRMED",
    };
    if (organizationId) {
      where.organizationId = organizationId;
    }

    const collections = await this.prisma.collectionRecord.findMany({
      where,
      orderBy: { collectedAt: "desc" },
    });

    return collections.map((c) => ({
      id: c.id,
      receiptNumber: c.receiptId ?? `REC-${c.id.substring(0, 8)}`,
      organizationId: c.organizationId,
      eventId: c.eventId,
      contributorAccountId: c.contributorAccountId,
      amountPaise: c.amountPaise.toString(),
      mode: c.mode,
      collectedAt: c.collectedAt,
      paymentReference: c.paymentReference,
    }));
  }

  async getDonorReceiptDetails(userId: string, receiptId: string) {
    const profile = await this.getSelfProfile(userId);

    const collection = await this.prisma.collectionRecord.findFirst({
      where: {
        OR: [{ id: receiptId }, { receiptId }],
      },
    });

    if (!collection) {
      throw new NotFoundException("Receipt not found");
    }

    const account = await this.prisma.contributorAccount.findUnique({
      where: { id: collection.contributorAccountId },
    });

    if (!account || account.donorProfileId !== profile.id) {
      throw new ForbiddenException("Access denied: You do not own this receipt");
    }

    const org = await this.prisma.organization.findUnique({ where: { id: collection.organizationId } });

    return {
      id: collection.id,
      receiptNumber: collection.receiptId ?? `REC-${collection.id.substring(0, 8)}`,
      organizationName: org?.name ?? "Mandal Trust",
      donorName: profile.fullName,
      amountPaise: collection.amountPaise.toString(),
      mode: collection.mode,
      collectedAt: collection.collectedAt,
      paymentReference: collection.paymentReference,
      isTaxExempt80G: true,
    };
  }

  async getDonorContributions(userId: string, organizationId?: string, eventId?: string) {
    const profile = await this.getSelfProfile(userId);
    const accounts = await this.prisma.contributorAccount.findMany({
      where: { donorProfileId: profile.id },
      select: { id: true },
    });

    const accountIds = accounts.map((a) => a.id);
    if (accountIds.length === 0) {
      return [];
    }

    const where: any = {
      contributorAccountId: { in: accountIds },
      status: "CONFIRMED",
    };
    if (organizationId) where.organizationId = organizationId;
    if (eventId) where.eventId = eventId;

    const collections = await this.prisma.collectionRecord.findMany({
      where,
      orderBy: { collectedAt: "desc" },
    });

    return collections.map((c) => ({
      id: c.id,
      organizationId: c.organizationId,
      eventId: c.eventId,
      contributorAccountId: c.contributorAccountId,
      amountPaise: c.amountPaise.toString(),
      mode: c.mode,
      source: c.source,
      collectedAt: c.collectedAt,
    }));
  }

  async getDonorDashboard(userId: string) {
    const profile = await this.getSelfProfile(userId);
    const accounts = await this.prisma.contributorAccount.findMany({
      where: { donorProfileId: profile.id },
      select: { id: true, organizationId: true },
    });

    const accountIds = accounts.map((a) => a.id);
    const activeMandalsCount = new Set(accounts.map((a) => a.organizationId)).size;

    if (accountIds.length === 0) {
      return {
        donorProfile: {
          id: profile.id,
          fullName: profile.fullName,
          email: profile.email,
          mobile: profile.mobile,
        },
        activeMandalsCount: 0,
        ytdTotalContributedPaise: "0",
        pendingBillsCount: 0,
        pendingBillsTotalPaise: "0",
        taxExempt80GEligiblePaise: "0",
        recentReceipts: [],
      };
    }

    const collectionsAgg = await this.prisma.collectionRecord.aggregate({
      where: { contributorAccountId: { in: accountIds }, status: "CONFIRMED" },
      _sum: { amountPaise: true },
      _count: { id: true },
    });

    const pendingBills = await this.prisma.contributionBill.findMany({
      where: { contributorAccountId: { in: accountIds }, status: { in: ["ISSUED", "PARTIALLY_PAID", "OVERDUE"] } },
      select: { payableAmountPaise: true, confirmedCollectionPaise: true },
    });

    let pendingBillsTotalPaise = BigInt(0);
    for (const b of pendingBills) {
      const remaining = (b.payableAmountPaise ?? BigInt(0)) - b.confirmedCollectionPaise;
      if (remaining > BigInt(0)) {
        pendingBillsTotalPaise += remaining;
      }
    }

    const recentCollections = await this.prisma.collectionRecord.findMany({
      where: { contributorAccountId: { in: accountIds }, status: "CONFIRMED" },
      orderBy: { collectedAt: "desc" },
      take: 5,
    });

    const ytdTotalPaise = collectionsAgg._sum.amountPaise ?? BigInt(0);

    return {
      donorProfile: {
        id: profile.id,
        fullName: profile.fullName,
        email: profile.email,
        mobile: profile.mobile,
      },
      activeMandalsCount,
      ytdTotalContributedPaise: ytdTotalPaise.toString(),
      pendingBillsCount: pendingBills.length,
      pendingBillsTotalPaise: pendingBillsTotalPaise.toString(),
      taxExempt80GEligiblePaise: ytdTotalPaise.toString(),
      recentReceipts: recentCollections.map((c) => ({
        id: c.id,
        receiptNumber: c.receiptId ?? `REC-${c.id.substring(0, 8)}`,
        organizationId: c.organizationId,
        amountPaise: c.amountPaise.toString(),
        mode: c.mode,
        collectedAt: c.collectedAt,
      })),
    };
  }

  async getTrustDonorAnalytics(organizationId: string) {
    const accounts = await this.prisma.contributorAccount.findMany({
      where: { organizationId, status: "ACTIVE" },
      select: { id: true, donorProfileId: true, displayName: true },
    });

    const uniqueDonorIds = new Set(accounts.map((a) => a.donorProfileId));
    const totalDonorsCount = uniqueDonorIds.size;

    const collections = await this.prisma.collectionRecord.findMany({
      where: { organizationId, status: "CONFIRMED" },
      select: { amountPaise: true, mode: true, contributorAccountId: true },
    });

    let totalCollectionsPaise = BigInt(0);
    const modeMap: Record<string, bigint> = {};
    const accountSumMap = new Map<string, bigint>();

    for (const c of collections) {
      totalCollectionsPaise += c.amountPaise;
      modeMap[c.mode] = (modeMap[c.mode] ?? BigInt(0)) + c.amountPaise;
      accountSumMap.set(c.contributorAccountId, (accountSumMap.get(c.contributorAccountId) ?? BigInt(0)) + c.amountPaise);
    }

    const averageContributionPaise =
      collections.length > 0 ? (totalCollectionsPaise / BigInt(collections.length)).toString() : "0";

    const leaderboard = accounts
      .map((a) => ({
        contributorAccountId: a.id,
        donorProfileId: a.donorProfileId,
        displayName: a.displayName,
        totalContributedPaise: (accountSumMap.get(a.id) ?? BigInt(0)).toString(),
      }))
      .sort((a, b) => (BigInt(b.totalContributedPaise) > BigInt(a.totalContributedPaise) ? 1 : -1))
      .slice(0, 10);

    return {
      totalDonorsCount,
      totalCollectionsCount: collections.length,
      totalCollectionsPaise: totalCollectionsPaise.toString(),
      averageContributionPaise,
      taxExempt80GTotalPaise: totalCollectionsPaise.toString(),
      collectionsByMode: Object.fromEntries(
        Object.entries(modeMap).map(([mode, val]) => [mode, val.toString()]),
      ),
      topDonorsLeaderboard: leaderboard,
    };
  }

  async getOwnHistory(userId: string) {
    const donor = await this.prisma.donorProfile.findUnique({ where: { userId } });
    if (!donor) {
      return [];
    }

    const accounts = await this.prisma.contributorAccount.findMany({
      where: { donorProfileId: donor.id },
      select: { id: true, organizationId: true, eventId: true, displayName: true, accountCode: true },
    });

    const accountIds = accounts.map((a) => a.id);
    const collections = await this.prisma.collectionRecord.findMany({
      where: { contributorAccountId: { in: accountIds }, status: "CONFIRMED" },
      select: {
        id: true,
        organizationId: true,
        eventId: true,
        amountPaise: true,
        collectedAt: true,
        mode: true,
        receiptId: true,
      },
      orderBy: { collectedAt: "desc" },
    });

    return collections.map((c) => ({
      ...c,
      amountPaise: c.amountPaise.toString(),
    }));
  }

  async mergeDonors(actorUserId: string, dto: MergeDonorsDto) {
    if (dto.survivingDonorId === dto.mergedDonorId) {
      throw new BadRequestException("Surviving donor and merged donor cannot be identical");
    }

    const surviving = await this.prisma.donorProfile.findUnique({ where: { id: dto.survivingDonorId } });
    const merged = await this.prisma.donorProfile.findUnique({ where: { id: dto.mergedDonorId } });

    if (!surviving || !merged) {
      throw new NotFoundException("One or both donor profiles were not found");
    }

    if (surviving.status === DonorProfileStatus.MERGED || merged.status === DonorProfileStatus.MERGED) {
      throw new ConflictException("Cannot merge a donor profile that has already been merged");
    }

    // Perform merge transaction
    const result = await this.prisma.$transaction(async (tx) => {
      // Step 1: Re-point contributor accounts to survivor
      const updatedAccounts = await tx.contributorAccount.updateMany({
        where: { donorProfileId: merged.id },
        data: { donorProfileId: surviving.id },
      });

      // Step 2: Create merge log and alias record
      const mergeLog = await tx.donorMergeLog.create({
        data: {
          survivingDonorId: surviving.id,
          mergedDonorId: merged.id,
          performedByUserId: actorUserId,
          reason: dto.reason,
          referenceCounts: { contributorAccountsReassigned: updatedAccounts.count },
          preMergeSnapshot: merged as any,
        },
      });

      await tx.donorAlias.create({
        data: {
          survivingDonorId: surviving.id,
          mergedDonorId: merged.id,
          previousMobile: merged.mobile,
          previousEmail: merged.email,
          mergeLogId: mergeLog.id,
        },
      });

      // Step 3: Deactivate merged profile
      await tx.donorProfile.update({
        where: { id: merged.id },
        data: {
          status: DonorProfileStatus.MERGED,
          deactivatedAt: new Date(),
        },
      });

      return {
        survivingDonorId: surviving.id,
        mergedDonorId: merged.id,
        reassignedAccountsCount: updatedAccounts.count,
        mergeLogId: mergeLog.id,
      };
    });

    return result;
  }
}
