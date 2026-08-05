import { Injectable, NotFoundException } from "@nestjs/common";
import { PrismaService, PublicVisibility } from "@pauti-pustak/backend-database";

@Injectable()
export class ReportingService {
  constructor(private readonly prisma: PrismaService) {}

  async getEventFinancialSummary(organizationId: string, eventId: string) {
    const event = await this.prisma.event.findFirst({
      where: { id: eventId, organizationId },
    });

    if (!event) {
      throw new NotFoundException("Event not found");
    }

    const collectionsAgg = await this.prisma.collectionRecord.aggregate({
      where: { eventId, organizationId, status: "CONFIRMED" },
      _sum: { amountPaise: true },
      _count: { id: true },
    });

    const expensesAgg = await this.prisma.expense.aggregate({
      where: { eventId, organizationId, status: { in: ["APPROVED", "PAID", "PARTIALLY_PAID"] } },
      _sum: { approvedAmountPaise: true, paidAmountPaise: true },
      _count: { id: true },
    });

    const confirmedCollectionsPaise = collectionsAgg._sum.amountPaise ?? BigInt(0);
    const approvedExpensesPaise = expensesAgg._sum.approvedAmountPaise ?? BigInt(0);
    const paidExpensesPaise = expensesAgg._sum.paidAmountPaise ?? BigInt(0);
    const netAvailableBalancePaise = confirmedCollectionsPaise - paidExpensesPaise;
    const netProjectedBalancePaise = confirmedCollectionsPaise - approvedExpensesPaise;
    const targetAmountPaise = event.targetAmountPaise ?? BigInt(0);

    const progressPercentage =
      targetAmountPaise > BigInt(0)
        ? Math.min(100, Number((confirmedCollectionsPaise * BigInt(100)) / targetAmountPaise))
        : 0;

    return {
      eventId: event.id,
      eventName: event.name,
      status: event.status,
      targetAmountPaise: targetAmountPaise.toString(),
      confirmedCollectionsPaise: confirmedCollectionsPaise.toString(),
      collectionsCount: collectionsAgg._count.id,
      approvedExpensesPaise: approvedExpensesPaise.toString(),
      paidExpensesPaise: paidExpensesPaise.toString(),
      expensesCount: expensesAgg._count.id,
      netAvailableBalancePaise: netAvailableBalancePaise.toString(),
      netProjectedBalancePaise: netProjectedBalancePaise.toString(),
      progressPercentage,
    };
  }

  async getDailyCollectionReport(organizationId: string, eventId: string) {
    const collections = await this.prisma.collectionRecord.findMany({
      where: { eventId, organizationId, status: "CONFIRMED" },
      select: {
        amountPaise: true,
        mode: true,
        collectedAt: true,
      },
      orderBy: { collectedAt: "asc" },
    });

    const dailyMap: Record<string, { totalPaise: bigint; count: number; byMode: Record<string, bigint> }> = {};

    for (const c of collections) {
      const dateStr = c.collectedAt.toISOString().split("T")[0];
      if (!dailyMap[dateStr]) {
        dailyMap[dateStr] = { totalPaise: BigInt(0), count: 0, byMode: {} };
      }

      dailyMap[dateStr].totalPaise += c.amountPaise;
      dailyMap[dateStr].count += 1;
      dailyMap[dateStr].byMode[c.mode] = (dailyMap[dateStr].byMode[c.mode] ?? BigInt(0)) + c.amountPaise;
    }

    return Object.entries(dailyMap).map(([date, data]) => ({
      date,
      totalAmountPaise: data.totalPaise.toString(),
      collectionsCount: data.count,
      byMode: Object.fromEntries(Object.entries(data.byMode).map(([mode, val]) => [mode, val.toString()])),
    }));
  }

  async getVolunteerPerformanceReport(organizationId: string, eventId: string) {
    const volunteers = await this.prisma.volunteer.findMany({
      where: { organizationId, status: "ACTIVE" },
      select: { id: true, fullName: true, type: true, volunteerCode: true },
    });

    const volIds = volunteers.map((v) => v.id);
    const collections = await this.prisma.collectionRecord.groupBy({
      by: ["collectorVolunteerId"],
      where: { eventId, organizationId, collectorVolunteerId: { in: volIds }, status: "CONFIRMED" },
      _sum: { amountPaise: true },
      _count: { id: true },
    });

    const collectionMap = new Map(
      collections.map((c) => [
        c.collectorVolunteerId,
        { totalPaise: c._sum.amountPaise ?? BigInt(0), count: c._count.id },
      ]),
    );

    return volunteers.map((v) => {
      const perf = collectionMap.get(v.id) ?? { totalPaise: BigInt(0), count: 0 };
      return {
        volunteerId: v.id,
        volunteerCode: v.volunteerCode,
        fullName: v.fullName,
        type: v.type,
        totalCollectedPaise: perf.totalPaise.toString(),
        collectionsCount: perf.count,
      };
    });
  }

  async getTaxExemptionReport(organizationId: string, eventId: string) {
    const accounts = await this.prisma.contributorAccount.findMany({
      where: { eventId, organizationId, status: "ACTIVE" },
      select: { id: true, displayName: true, donorProfileId: true, contactPerson: true },
    });

    const accountIds = accounts.map((a) => a.id);
    const collections = await this.prisma.collectionRecord.groupBy({
      by: ["contributorAccountId"],
      where: { contributorAccountId: { in: accountIds }, status: "CONFIRMED" },
      _sum: { amountPaise: true },
      _count: { id: true },
    });

    const collectionMap = new Map(collections.map((c) => [c.contributorAccountId, c._sum.amountPaise ?? BigInt(0)]));

    return accounts
      .filter((acc) => (collectionMap.get(acc.id) ?? BigInt(0)) > BigInt(0))
      .map((acc) => ({
        contributorAccountId: acc.id,
        displayName: acc.displayName,
        contactPerson: acc.contactPerson,
        totalDonatedPaise: (collectionMap.get(acc.id) ?? BigInt(0)).toString(),
        is80GEligible: true,
      }));
  }
}
