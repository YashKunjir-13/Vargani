import { Injectable, NotFoundException } from "@nestjs/common";
import { PrismaService, PublicVisibility } from "@pauti-pustak/backend-database";

@Injectable()
export class PublicQueryService {
  constructor(private readonly prisma: PrismaService) {}

  async getPublicEventPage(slug: string) {
    const page = await this.prisma.publicEventPage.findUnique({
      where: { publicSlug: slug },
    });

    if (!page || page.status !== "PUBLISHED") {
      throw new NotFoundException("Public event page not found or not published");
    }

    const event = await this.prisma.event.findUnique({
      where: { id: page.eventId },
    });

    if (!event || event.status === "ARCHIVED") {
      throw new NotFoundException("Event not found or archived");
    }

    const org = await this.prisma.organization.findUnique({
      where: { id: page.organizationId },
    });

    // Compute live confirmed totals
    const collectionsAggregate = await this.prisma.collectionRecord.aggregate({
      where: { eventId: event.id, status: "CONFIRMED" },
      _sum: { amountPaise: true },
      _count: { id: true },
    });

    const confirmedCollectionsPaise = collectionsAggregate._sum.amountPaise ?? BigInt(0);
    const totalDonorsCount = collectionsAggregate._count.id;
    const targetAmountPaise = event.targetAmountPaise ?? BigInt(0);

    const progressPercentage =
      targetAmountPaise > BigInt(0)
        ? Math.min(100, Number((confirmedCollectionsPaise * BigInt(100)) / targetAmountPaise))
        : 0;

    return {
      slug: page.publicSlug,
      organizationName: org?.name ?? "Mandal",
      eventName: event.name,
      eventTypeCode: event.eventTypeCode,
      location: event.location,
      startDate: event.startDate,
      endDate: event.endDate,
      showLiveTotals: page.showLiveTotals,
      showDonorList: page.showDonorList,
      showExpenseSummary: page.showExpenseSummary,
      financials: page.showLiveTotals
        ? {
            targetAmountPaise: targetAmountPaise.toString(),
            confirmedCollectionsPaise: confirmedCollectionsPaise.toString(),
            totalDonorsCount,
            progressPercentage,
          }
        : null,
    };
  }

  async getPublicEventDonors(slug: string, limit = 50, offset = 0) {
    const page = await this.prisma.publicEventPage.findUnique({
      where: { publicSlug: slug },
    });

    if (!page || page.status !== "PUBLISHED" || !page.showDonorList) {
      throw new NotFoundException("Public donor list is disabled or not available");
    }

    const accounts = await this.prisma.contributorAccount.findMany({
      where: {
        eventId: page.eventId,
        organizationId: page.organizationId,
        status: "ACTIVE",
      },
      take: Math.min(limit, 100),
      skip: offset,
      orderBy: { createdAt: "desc" },
    });

    const accountIds = accounts.map((a) => a.id);
    const collections = await this.prisma.collectionRecord.groupBy({
      by: ["contributorAccountId"],
      where: { contributorAccountId: { in: accountIds }, status: "CONFIRMED" },
      _sum: { amountPaise: true },
    });

    const collectionMap = new Map(collections.map((c) => [c.contributorAccountId, c._sum.amountPaise ?? BigInt(0)]));

    return accounts.map((acc) => {
      const isPrivate = acc.publicVisibility === PublicVisibility.PRIVATE;
      const totalPaise = collectionMap.get(acc.id) ?? BigInt(0);

      return {
        displayName: isPrivate ? "Well-Wisher" : acc.displayName,
        amountPaise: isPrivate ? null : totalPaise.toString(),
        isPrivate,
      };
    });
  }

  async getPublicEventExpenses(slug: string) {
    const page = await this.prisma.publicEventPage.findUnique({
      where: { publicSlug: slug },
    });

    if (!page || page.status !== "PUBLISHED" || !page.showExpenseSummary) {
      throw new NotFoundException("Public expense summary is disabled or not available");
    }

    const expenses = await this.prisma.expense.groupBy({
      by: ["categoryCode"],
      where: {
        eventId: page.eventId,
        organizationId: page.organizationId,
        status: { in: ["APPROVED", "PAID", "PARTIALLY_PAID"] },
      },
      _sum: { approvedAmountPaise: true, paidAmountPaise: true },
    });

    let totalExpensePaise = BigInt(0);
    const categories = expenses.map((e) => {
      const approved = e._sum.approvedAmountPaise ?? BigInt(0);
      totalExpensePaise += approved;
      return {
        categoryCode: e.categoryCode,
        approvedAmountPaise: approved.toString(),
        paidAmountPaise: (e._sum.paidAmountPaise ?? BigInt(0)).toString(),
      };
    });

    return {
      totalExpensePaise: totalExpensePaise.toString(),
      categories,
    };
  }
}
