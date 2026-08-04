import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { EventStatus, PrismaService } from "@pauti-pustak/backend-database";
import { randomInt } from "crypto";
import { CreateEventDto } from "./dto/create-event.dto";
import { ReopenEventDto } from "./dto/reopen-event.dto";
import { UpdateEventDto } from "./dto/update-event.dto";

@Injectable()
export class EventService {
  constructor(private readonly prisma: PrismaService) {}

  async listEvents(
    organizationId: string,
    filters?: {
      status?: EventStatus;
      financialYear?: number;
      search?: string;
      page?: number;
      limit?: number;
    },
  ) {
    const page = Math.max(1, filters?.page ?? 1);
    const limit = Math.min(100, Math.max(1, filters?.limit ?? 20));
    const skip = (page - 1) * limit;

    const where = {
      organizationId,
      ...(filters?.status ? { status: filters.status } : {}),
      ...(filters?.financialYear ? { financialYear: filters.financialYear.toString() } : {}),
      ...(filters?.search ? { name: { contains: filters.search, mode: "insensitive" as const } } : {}),
    };

    const [events, total] = await Promise.all([
      this.prisma.event.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip,
        take: limit,
      }),
      this.prisma.event.count({ where }),
    ]);

    const items = await Promise.all(events.map((e) => this.enrichEventWithBalances(e)));

    return {
      items,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getEvent(organizationId: string, eventId: string) {
    const event = await this.prisma.event.findFirst({
      where: { id: eventId, organizationId },
    });

    if (!event) {
      throw new NotFoundException("Event not found");
    }

    return this.enrichEventWithBalances(event);
  }

  async createEvent(organizationId: string, userId: string, dto: CreateEventDto) {
    const org = await this.prisma.organization.findUnique({ where: { id: organizationId } });
    if (!org || org.status === "CLOSED") {
      throw new ForbiddenException("Organization is closed or inactive");
    }

    const code = await this.generateEventCode(organizationId, dto.name, dto.financialYearStart);
    const startDate = dto.startDate ? new Date(dto.startDate) : new Date();
    const endDate = dto.endDate ? new Date(dto.endDate) : new Date(startDate.getTime() + 10 * 86400000);

    const event = await this.prisma.event.create({
      data: {
        organizationId,
        eventTypeCode: dto.eventTypeCode,
        code,
        name: dto.name,
        location: dto.location,
        financialYear: dto.financialYearStart ? dto.financialYearStart.toString() : undefined,
        startDate,
        endDate,
        targetAmountPaise: dto.targetAmountPaise ? BigInt(dto.targetAmountPaise) : null,
        status: EventStatus.DRAFT,
        createdByUserId: userId,
      },
    });

    return this.enrichEventWithBalances(event);
  }

  async updateEvent(organizationId: string, eventId: string, dto: UpdateEventDto) {
    const event = await this.prisma.event.findFirst({
      where: { id: eventId, organizationId },
    });

    if (!event) {
      throw new NotFoundException("Event not found");
    }

    if (event.status === EventStatus.ARCHIVED) {
      throw new ForbiddenException("Archived event is read-only and cannot be updated");
    }

    const updated = await this.prisma.event.update({
      where: { id: eventId },
      data: {
        ...(dto.name ? { name: dto.name } : {}),
        ...(dto.location !== undefined ? { location: dto.location } : {}),
        ...(dto.startDate ? { startDate: new Date(dto.startDate) } : {}),
        ...(dto.endDate ? { endDate: new Date(dto.endDate) } : {}),
        ...(dto.targetAmountPaise !== undefined
          ? { targetAmountPaise: dto.targetAmountPaise ? BigInt(dto.targetAmountPaise) : null }
          : {}),
      },
    });

    return this.enrichEventWithBalances(updated);
  }

  async activateEvent(organizationId: string, eventId: string, userId: string) {
    await this.assertValidTransition(organizationId, eventId, [EventStatus.DRAFT]);

    const updated = await this.prisma.event.update({
      where: { id: eventId },
      data: {
        status: EventStatus.ACTIVE,
        activatedByUserId: userId,
        activatedAt: new Date(),
      },
    });

    return this.enrichEventWithBalances(updated);
  }

  async completeEvent(organizationId: string, eventId: string, userId: string) {
    await this.assertValidTransition(organizationId, eventId, [EventStatus.ACTIVE]);

    const updated = await this.prisma.event.update({
      where: { id: eventId },
      data: {
        status: EventStatus.COMPLETED,
        completedByUserId: userId,
        completedAt: new Date(),
      },
    });

    return this.enrichEventWithBalances(updated);
  }

  async financialCloseEvent(organizationId: string, eventId: string, userId: string) {
    await this.assertValidTransition(organizationId, eventId, [EventStatus.COMPLETED]);

    const updated = await this.prisma.event.update({
      where: { id: eventId },
      data: {
        status: EventStatus.FINANCIALLY_CLOSED,
        closedByUserId: userId,
        closedAt: new Date(),
      },
    });

    return this.enrichEventWithBalances(updated);
  }

  async reopenEvent(organizationId: string, eventId: string, userId: string, dto: ReopenEventDto) {
    await this.assertValidTransition(organizationId, eventId, [EventStatus.FINANCIALLY_CLOSED]);

    const updated = await this.prisma.event.update({
      where: { id: eventId },
      data: {
        status: EventStatus.ACTIVE,
        reopenedReason: dto.reason,
      },
    });

    return this.enrichEventWithBalances(updated);
  }

  async archiveEvent(organizationId: string, eventId: string, userId: string) {
    await this.assertValidTransition(organizationId, eventId, [EventStatus.FINANCIALLY_CLOSED]);

    const updated = await this.prisma.event.update({
      where: { id: eventId },
      data: {
        status: EventStatus.ARCHIVED,
        archivedByUserId: userId,
        archivedAt: new Date(),
      },
    });

    return this.enrichEventWithBalances(updated);
  }

  private async assertValidTransition(organizationId: string, eventId: string, allowedFrom: EventStatus[]) {
    const event = await this.prisma.event.findFirst({
      where: { id: eventId, organizationId },
    });

    if (!event) {
      throw new NotFoundException("Event not found");
    }

    if (!allowedFrom.includes(event.status)) {
      throw new BadRequestException(
        `Invalid lifecycle transition. Event status is ${event.status}, allowed previous statuses: ${allowedFrom.join(", ")}`,
      );
    }

    return event;
  }

  private async generateEventCode(organizationId: string, name: string, year: number): Promise<string> {
    const org = await this.prisma.organization.findUnique({ where: { id: organizationId } });
    const prefix = `${org?.code ?? "ORG"}-${year}-`;

    for (let attempt = 0; attempt < 5; attempt += 1) {
      const suffix = randomInt(100, 999).toString();
      const code = `${prefix}${suffix}`.slice(0, 20);
      const existing = await this.prisma.event.findUnique({
        where: { organizationId_code: { organizationId, code } },
      });
      if (!existing) {
        return code;
      }
    }
    throw new ConflictException("Could not generate a unique event code");
  }

  private async enrichEventWithBalances(event: any) {
    const collections = await this.prisma.collectionRecord.aggregate({
      where: { eventId: event.id, status: "CONFIRMED" },
      _sum: { amountPaise: true },
    });

    const confirmedCollections = collections._sum.amountPaise ?? BigInt(0);
    const availableBalancePaise = confirmedCollections;
    const projectedBalancePaise = availableBalancePaise;

    return {
      ...event,
      targetAmountPaise: event.targetAmountPaise ? event.targetAmountPaise.toString() : null,
      openingBalancePaise: "0",
      confirmedCollectionsPaise: confirmedCollections.toString(),
      availableBalancePaise: availableBalancePaise.toString(),
      projectedBalancePaise: projectedBalancePaise.toString(),
    };
  }
}
