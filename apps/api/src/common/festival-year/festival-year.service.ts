import { Injectable, NotFoundException } from "@nestjs/common";
import { EventStatus, PrismaService } from "@pauti-pustak/backend-database";

export interface ActiveFestivalYear {
  eventId: string;
  organizationId: string;
  /** The numeric festival year every financial document should carry (e.g. the Ganpati year). */
  festivalYear: number;
  /** The raw financialYear string as stored on the Event, if any. */
  financialYearLabel: string | null;
}

/**
 * Resolves "the active festival year for organization X" so feature
 * modules (contribution, receipt, bill) pull this from one place instead
 * of each re-implementing an Event lookup. In this domain, "festival year"
 * maps to the organization's currently ACTIVE Event -- there is no
 * separate festival-year entity in the schema, only Event.status/
 * Event.financialYear (see packages/backend-database/prisma/schema.prisma).
 */
@Injectable()
export class FestivalYearService {
  constructor(private readonly prisma: PrismaService) {}

  async getActiveFestivalYear(organizationId: string): Promise<ActiveFestivalYear> {
    const event = await this.prisma.event.findFirst({
      where: { organizationId, status: EventStatus.ACTIVE },
      orderBy: { activatedAt: "desc" },
    });

    if (!event) {
      throw new NotFoundException(
        `No active festival year found for organization ${organizationId}`,
      );
    }

    return {
      eventId: event.id,
      organizationId,
      festivalYear: this.deriveNumericYear(event.financialYear, event.activatedAt ?? event.createdAt),
      financialYearLabel: event.financialYear,
    };
  }

  /**
   * `Event.financialYear` is a free-form label (e.g. "2025-26" or "2025"),
   * not a structured year type, so numbering/counters need a plain integer
   * derived from it. Falls back to the event's activation year if the label
   * isn't parseable.
   */
  private deriveNumericYear(financialYearLabel: string | null, fallbackDate: Date): number {
    const match = financialYearLabel?.match(/\d{4}/);
    if (match) {
      return Number(match[0]);
    }
    return fallbackDate.getFullYear();
  }
}
