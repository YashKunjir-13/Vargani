import { Injectable } from "@nestjs/common";
import { PrismaService } from "@pauti-pustak/backend-database";

@Injectable()
export class DashboardService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * 1. Executive Dashboard (Owner, Admin)
   */
  async getExecutiveDashboard(organizationId: string) {
    const activeEventsCount = await this.prisma.event.count({
      where: { organizationId, status: "ACTIVE" },
    });

    const activeVolunteersCount = await this.prisma.volunteer.count({
      where: { organizationId, status: "ACTIVE" },
    });

    const collectionsAgg = await this.prisma.collectionRecord.aggregate({
      where: { organizationId, status: "CONFIRMED" },
      _sum: { amountPaise: true },
      _count: { id: true },
    });

    const expensesAgg = await this.prisma.expense.aggregate({
      where: { organizationId, status: { in: ["APPROVED", "PAID", "PARTIALLY_PAID"] } },
      _sum: { approvedAmountPaise: true, paidAmountPaise: true },
      _count: { id: true },
    });

    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);

    const todayCollectionsAgg = await this.prisma.collectionRecord.aggregate({
      where: { organizationId, status: "CONFIRMED", collectedAt: { gte: startOfToday } },
      _sum: { amountPaise: true },
      _count: { id: true },
    });

    const totalDonorsCount = await this.prisma.contributorAccount.count({
      where: { organizationId, status: "ACTIVE" },
    });

    const totalCollectionsPaise = collectionsAgg._sum.amountPaise ?? BigInt(0);
    const approvedExpensesPaise = expensesAgg._sum.approvedAmountPaise ?? BigInt(0);
    const paidExpensesPaise = expensesAgg._sum.paidAmountPaise ?? BigInt(0);
    const netLiquidityBalancePaise = totalCollectionsPaise - paidExpensesPaise;
    const todayTotalCollectedPaise = todayCollectionsAgg._sum.amountPaise ?? BigInt(0);

    return {
      activeEventsCount,
      activeVolunteersCount,
      totalCollectionsPaise: totalCollectionsPaise.toString(),
      totalCollectionsCount: collectionsAgg._count.id,
      approvedExpensesPaise: approvedExpensesPaise.toString(),
      paidExpensesPaise: paidExpensesPaise.toString(),
      expensesCount: expensesAgg._count.id,
      netLiquidityBalancePaise: netLiquidityBalancePaise.toString(),
      todayTotalCollectedPaise: todayTotalCollectedPaise.toString(),
      todayCollectionsCount: todayCollectionsAgg._count.id,
      totalDonorsCount,
    };
  }

  /**
   * 2. Finance & Treasury Dashboard (Treasurer, Finance Manager)
   */
  async getFinanceDashboard(organizationId: string) {
    const collections = await this.prisma.collectionRecord.findMany({
      where: { organizationId, status: "CONFIRMED" },
      select: { amountPaise: true, mode: true },
    });

    const byModeMap: Record<string, bigint> = {};
    let totalCollectionsPaise = BigInt(0);

    for (const c of collections) {
      totalCollectionsPaise += c.amountPaise;
      byModeMap[c.mode] = (byModeMap[c.mode] ?? BigInt(0)) + c.amountPaise;
    }

    const expensesAgg = await this.prisma.expense.aggregate({
      where: { organizationId, status: { in: ["APPROVED", "PAID", "PARTIALLY_PAID"] } },
      _sum: { approvedAmountPaise: true, paidAmountPaise: true },
    });

    const billsAgg = await this.prisma.contributionBill.aggregate({
      where: { organizationId, status: { in: ["ISSUED", "PARTIALLY_PAID", "OVERDUE"] } },
      _sum: { requestedAmountPaise: true },
      _count: { id: true },
    });

    const paidExpensesPaise = expensesAgg._sum.paidAmountPaise ?? BigInt(0);
    const availableCashBalancePaise = totalCollectionsPaise - paidExpensesPaise;

    return {
      totalCollectionsPaise: totalCollectionsPaise.toString(),
      collectionsByMode: Object.fromEntries(
        Object.entries(byModeMap).map(([mode, val]) => [mode, val.toString()]),
      ),
      approvedExpensesPaise: (expensesAgg._sum.approvedAmountPaise ?? BigInt(0)).toString(),
      paidExpensesPaise: paidExpensesPaise.toString(),
      outstandingBillsCount: billsAgg._count?.id ?? 0,
      outstandingBillsTotalPaise: (billsAgg._sum?.requestedAmountPaise ?? BigInt(0)).toString(),
      availableCashBalancePaise: availableCashBalancePaise.toString(),
    };
  }

  /**
   * 3. Event Operations Dashboard (Event Manager)
   */
  async getEventsDashboard(organizationId: string) {
    const events = await this.prisma.event.findMany({
      where: { organizationId, status: { in: ["DRAFT", "ACTIVE", "COMPLETED"] } },
      orderBy: { createdAt: "desc" },
    });

    const items = await Promise.all(
      events.map(async (event) => {
        const collectionsAgg = await this.prisma.collectionRecord.aggregate({
          where: { eventId: event.id, organizationId, status: "CONFIRMED" },
          _sum: { amountPaise: true },
          _count: { id: true },
        });

        const expensesAgg = await this.prisma.expense.aggregate({
          where: { eventId: event.id, organizationId, status: { in: ["APPROVED", "PAID"] } },
          _sum: { paidAmountPaise: true },
        });

        const confirmedPaise = collectionsAgg._sum.amountPaise ?? BigInt(0);
        const targetPaise = event.targetAmountPaise ?? BigInt(0);
        const progressPercentage =
          targetPaise > BigInt(0)
            ? Math.min(100, Number((confirmedPaise * BigInt(100)) / targetPaise))
            : 0;

        return {
          id: event.id,
          code: event.code,
          name: event.name,
          status: event.status,
          targetAmountPaise: targetPaise.toString(),
          confirmedCollectionsPaise: confirmedPaise.toString(),
          collectionsCount: collectionsAgg._count.id,
          paidExpensesPaise: (expensesAgg._sum.paidAmountPaise ?? BigInt(0)).toString(),
          progressPercentage,
        };
      }),
    );

    return { events: items };
  }

  /**
   * 4. Volunteer & Field Operations Dashboard (Volunteer Manager, Collector Manager)
   */
  async getVolunteersDashboard(organizationId: string) {
    const volunteers = await this.prisma.volunteer.findMany({
      where: { organizationId, status: "ACTIVE" },
      select: { id: true, volunteerCode: true, fullName: true, type: true },
    });

    const volIds = volunteers.map((v) => v.id);
    const collections = await this.prisma.collectionRecord.groupBy({
      by: ["collectorVolunteerId"],
      where: { organizationId, collectorVolunteerId: { in: volIds }, status: "CONFIRMED" },
      _sum: { amountPaise: true },
      _count: { id: true },
    });

    const collectionMap = new Map(
      collections.map((c) => [
        c.collectorVolunteerId,
        { totalPaise: c._sum.amountPaise ?? BigInt(0), count: c._count.id },
      ]),
    );

    const leaderboard = volunteers
      .map((v) => {
        const perf = collectionMap.get(v.id) ?? { totalPaise: BigInt(0), count: 0 };
        return {
          volunteerId: v.id,
          volunteerCode: v.volunteerCode,
          fullName: v.fullName,
          type: v.type,
          totalCollectedPaise: perf.totalPaise.toString(),
          collectionsCount: perf.count,
        };
      })
      .sort((a, b) => (BigInt(b.totalCollectedPaise) > BigInt(a.totalCollectedPaise) ? 1 : -1));

    return {
      activeVolunteersCount: volunteers.length,
      leaderboard,
    };
  }

  /**
   * 5. Desk Operations Dashboard (Receipt Operator, Data Entry Operator)
   */
  async getOperationsDashboard(organizationId: string) {
    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);

    const todayCollectionsAgg = await this.prisma.collectionRecord.aggregate({
      where: {
        organizationId,
        status: "CONFIRMED",
        collectedAt: { gte: startOfToday },
      },
      _sum: { amountPaise: true },
      _count: { id: true },
    });

    const pendingDraftsCount = await this.prisma.collectionRecord.count({
      where: { organizationId, status: { in: ["RECORDED", "PENDING_VERIFICATION"] } },
    });

    const recentCollections = await this.prisma.collectionRecord.findMany({
      where: { organizationId },
      orderBy: { createdAt: "desc" },
      take: 10,
      select: {
        id: true,
        amountPaise: true,
        mode: true,
        status: true,
        createdAt: true,
      },
    });

    return {
      todayTotalCollectedPaise: (todayCollectionsAgg._sum.amountPaise ?? BigInt(0)).toString(),
      todayCollectionsCount: todayCollectionsAgg._count.id,
      pendingDraftsCount,
      recentCollections: recentCollections.map((c) => ({
        id: c.id,
        amountPaise: c.amountPaise.toString(),
        mode: c.mode,
        status: c.status,
        createdAt: c.createdAt,
      })),
    };
  }

  /**
   * 6. Compliance & Audit Dashboard (Auditor)
   */
  async getAuditDashboard(organizationId: string) {
    const auditLogs = await this.prisma.auditLog.findMany({
      where: { organizationId },
      orderBy: { createdAt: "desc" },
      take: 20,
    });

    const highValueThresholdPaise = BigInt(5000000); // 50,000 INR
    const highValueCollections = await this.prisma.collectionRecord.findMany({
      where: { organizationId, amountPaise: { gte: highValueThresholdPaise } },
      orderBy: { amountPaise: "desc" },
      take: 10,
      select: {
        id: true,
        amountPaise: true,
        mode: true,
        status: true,
        createdAt: true,
      },
    });

    const taxExemptDonorsCount = await this.prisma.contributorAccount.count({
      where: { organizationId, status: "ACTIVE" },
    });

    return {
      auditLogStream: auditLogs.map((log) => ({
        id: log.id,
        actionType: log.actionType,
        performedByUserId: log.performedByUserId,
        targetType: log.targetType,
        targetId: log.targetId,
        createdAt: log.createdAt,
      })),
      highValueCollections: highValueCollections.map((c) => ({
        id: c.id,
        amountPaise: c.amountPaise.toString(),
        mode: c.mode,
        status: c.status,
        createdAt: c.createdAt,
      })),
      taxExemptDonorsCount,
    };
  }

  /**
   * 7. Financial Trend Chart (Executive Overview)
   */
  async getFinancialTrendChart(organizationId: string) {
    const twelveMonthsAgo = new Date();
    twelveMonthsAgo.setMonth(twelveMonthsAgo.getMonth() - 11);
    twelveMonthsAgo.setDate(1);
    twelveMonthsAgo.setHours(0, 0, 0, 0);

    const collections = await this.prisma.collectionRecord.findMany({
      where: {
        organizationId,
        status: "CONFIRMED",
        collectedAt: { gte: twelveMonthsAgo },
      },
      select: { amountPaise: true, collectedAt: true },
    });

    const expenses = await this.prisma.expense.findMany({
      where: {
        organizationId,
        status: { in: ["APPROVED", "PAID"] },
        createdAt: { gte: twelveMonthsAgo },
      },
      select: { paidAmountPaise: true, createdAt: true },
    });

    const monthlyDataMap = new Map<string, { month: string; collectionsPaise: bigint; expensesPaise: bigint }>();

    for (let i = 0; i < 12; i++) {
      const d = new Date(twelveMonthsAgo);
      d.setMonth(d.getMonth() + i);
      const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
      const monthLabel = d.toLocaleString("default", { month: "short", year: "numeric" });
      monthlyDataMap.set(key, { month: monthLabel, collectionsPaise: BigInt(0), expensesPaise: BigInt(0) });
    }

    for (const c of collections) {
      const d = new Date(c.collectedAt);
      const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
      if (monthlyDataMap.has(key)) {
        monthlyDataMap.get(key)!.collectionsPaise += c.amountPaise;
      }
    }

    for (const e of expenses) {
      const d = new Date(e.createdAt);
      const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
      if (monthlyDataMap.has(key)) {
        monthlyDataMap.get(key)!.expensesPaise += e.paidAmountPaise ?? BigInt(0);
      }
    }

    const series = Array.from(monthlyDataMap.values()).map((item) => ({
      month: item.month,
      collectionsPaise: item.collectionsPaise.toString(),
      expensesPaise: item.expensesPaise.toString(),
    }));

    return { series };
  }

  /**
   * 8. Payment Mode Breakdown Chart (Finance & Treasury)
   */
  async getModeBreakdownChart(organizationId: string) {
    const collections = await this.prisma.collectionRecord.findMany({
      where: { organizationId, status: "CONFIRMED" },
      select: { amountPaise: true, mode: true },
    });

    let grandTotalPaise = BigInt(0);
    const modeMap: Record<string, bigint> = {};

    for (const c of collections) {
      grandTotalPaise += c.amountPaise;
      modeMap[c.mode] = (modeMap[c.mode] ?? BigInt(0)) + c.amountPaise;
    }

    const breakdown = Object.entries(modeMap).map(([mode, totalPaise]) => {
      const percentage =
        grandTotalPaise > BigInt(0)
          ? Number((totalPaise * BigInt(10000)) / grandTotalPaise) / 100
          : 0;
      return {
        mode,
        totalAmountPaise: totalPaise.toString(),
        percentage,
      };
    });

    return {
      grandTotalPaise: grandTotalPaise.toString(),
      breakdown,
    };
  }

  /**
   * 9. Recent Operations Stream Table (Desk Operations Dashboard)
   */
  async getRecentOperationsStream(
    organizationId: string,
    query?: { page?: number; limit?: number; mode?: string; search?: string },
  ) {
    const limit = query?.limit ?? 20;
    const page = query?.page ?? 1;
    const skip = (page - 1) * limit;

    const where: any = {
      organizationId,
      status: "CONFIRMED",
    };

    if (query?.mode) {
      where.mode = query.mode;
    }

    if (query?.search) {
      where.OR = [
        { receiptId: { contains: query.search, mode: "insensitive" } },
      ];
    }

    const [total, items] = await Promise.all([
      this.prisma.collectionRecord.count({ where }),
      this.prisma.collectionRecord.findMany({
        where,
        orderBy: { collectedAt: "desc" },
        skip,
        take: limit,
      }),
    ]);

    const contributorIds = Array.from(new Set(items.map((i) => i.contributorAccountId).filter(Boolean)));
    const volunteerIds = Array.from(new Set(items.map((i) => i.collectorVolunteerId).filter(Boolean))) as string[];

    const [contributors, volunteers] = await Promise.all([
      contributorIds.length > 0
        ? this.prisma.contributorAccount.findMany({
            where: { id: { in: contributorIds } },
            select: { id: true, displayName: true },
          })
        : [],
      volunteerIds.length > 0
        ? this.prisma.volunteer.findMany({
            where: { id: { in: volunteerIds } },
            select: { id: true, fullName: true },
          })
        : [],
    ]);

    const contributorMap = new Map<string, string>(contributors.map((c) => [c.id, c.displayName] as [string, string]));
    const volunteerMap = new Map<string, string>(volunteers.map((v) => [v.id, v.fullName] as [string, string]));

    return {
      items: items.map((c) => ({
        id: c.id,
        receiptId: c.receiptId,
        contributorDisplayName: contributorMap.get(c.contributorAccountId) ?? "Anonymous",
        collectorFullName: c.collectorVolunteerId ? (volunteerMap.get(c.collectorVolunteerId) ?? "Desk Staff") : "Desk Staff",
        amountPaise: c.amountPaise.toString(),
        mode: c.mode,
        collectedAt: c.collectedAt,
      })),
      total,
      page,
      limit,
    };
  }

  /**
   * 10. Active Events Progress Summary Table (Executive & Event Ops)
   */
  async getEventsProgressTable(organizationId: string) {
    const events = await this.prisma.event.findMany({
      where: { organizationId, status: "ACTIVE" },
      orderBy: { startDate: "desc" },
    });

    const results = await Promise.all(
      events.map(async (event) => {
        const collectionsAgg = await this.prisma.collectionRecord.aggregate({
          where: { organizationId, eventId: event.id, status: "CONFIRMED" },
          _sum: { amountPaise: true },
        });

        const collectedAmountPaise = collectionsAgg._sum.amountPaise ?? BigInt(0);
        const targetAmountPaise = event.targetAmountPaise ?? BigInt(0);

        const progressPercentage =
          targetAmountPaise > BigInt(0)
            ? Number((collectedAmountPaise * BigInt(10000)) / targetAmountPaise) / 100
            : 0;

        return {
          id: event.id,
          code: event.code,
          name: event.name,
          startDate: event.startDate,
          endDate: event.endDate,
          targetAmountPaise: targetAmountPaise.toString(),
          collectedAmountPaise: collectedAmountPaise.toString(),
          progressPercentage,
        };
      }),
    );

    return { items: results };
  }

  /**
   * 11. Compliance Audit Trail Stream Table (Auditor Dashboard)
   */
  async getAuditStream(
    organizationId: string,
    query?: { page?: number; limit?: number; actionType?: string },
  ) {
    const limit = query?.limit ?? 25;
    const page = query?.page ?? 1;
    const skip = (page - 1) * limit;

    const where: any = {
      organizationId,
    };

    if (query?.actionType) {
      where.actionType = query.actionType;
    }

    const [total, items] = await Promise.all([
      this.prisma.paymentReceiptAuditEvent.count({ where }),
      this.prisma.paymentReceiptAuditEvent.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip,
        take: limit,
      }),
    ]);

    return {
      items,
      total,
      page,
      limit,
    };
  }

  /**
   * 12. Volunteer Collector Performance Leaderboard (Volunteer Manager)
   */
  async getVolunteersLeaderboard(organizationId: string, query?: { page?: number; limit?: number }) {
    const limit = query?.limit ?? 10;
    const page = query?.page ?? 1;
    const skip = (page - 1) * limit;

    const volunteers = await this.prisma.volunteer.findMany({
      where: { organizationId, status: "ACTIVE" },
      select: { id: true, volunteerCode: true, fullName: true },
    });

    const collections = await this.prisma.collectionRecord.findMany({
      where: { organizationId, status: "CONFIRMED", collectorVolunteerId: { not: null } },
      select: { collectorVolunteerId: true, amountPaise: true },
    });

    const sumMap = new Map<string, bigint>();
    const countMap = new Map<string, number>();

    for (const c of collections) {
      if (c.collectorVolunteerId) {
        sumMap.set(c.collectorVolunteerId, (sumMap.get(c.collectorVolunteerId) ?? BigInt(0)) + c.amountPaise);
        countMap.set(c.collectorVolunteerId, (countMap.get(c.collectorVolunteerId) ?? 0) + 1);
      }
    }

    const sortedVolunteers = volunteers
      .map((v) => ({
        id: v.id,
        volunteerCode: v.volunteerCode,
        fullName: v.fullName,
        totalCollectedPaise: (sumMap.get(v.id) ?? BigInt(0)).toString(),
        totalCollectionsCount: countMap.get(v.id) ?? 0,
      }))
      .sort((a, b) => (BigInt(b.totalCollectedPaise) > BigInt(a.totalCollectedPaise) ? 1 : -1));

    const paginatedItems = sortedVolunteers.slice(skip, skip + limit);

    return {
      items: paginatedItems,
      total: sortedVolunteers.length,
      page,
      limit,
    };
  }
}
