import { randomUUID } from "node:crypto";
import { Injectable } from "@nestjs/common";
import { Prisma, PrismaService } from "@pauti-pustak/backend-database";

/**
 * Race-condition-safe, per-(organizationId, festivalYear, sequenceName)
 * counter shared by every module that needs sequential numbering (receipt
 * numbers, bill numbers, contribution receipt numbers, ...). Numbering
 * always resets per organization+festivalYear, never globally.
 *
 * This is the Postgres equivalent of a MongoDB `findOneAndUpdate` with
 * `$inc`: a single `INSERT ... ON CONFLICT ... DO UPDATE ... RETURNING`
 * statement performs the read-increment-write as one atomic, row-locking
 * operation, so two concurrent callers for the same key can never observe
 * or allocate the same number, and allocated numbers are always gapless.
 */
@Injectable()
export class SequenceCounterService {
  constructor(private readonly prisma: PrismaService) {}

  async getNextSequence(
    organizationId: string,
    festivalYear: number,
    sequenceName: string,
  ): Promise<bigint> {
    const rows = await this.prisma.$queryRaw<Array<{ lastSequence: bigint }>>(
      Prisma.sql`
        INSERT INTO "sequence_counters" (id, "organizationId", "festivalYear", "sequenceName", "lastSequence", "updatedAt")
        VALUES (${randomUUID()}, ${organizationId}, ${festivalYear}, ${sequenceName}, 1, now())
        ON CONFLICT ("organizationId", "festivalYear", "sequenceName")
        DO UPDATE SET "lastSequence" = sequence_counters."lastSequence" + 1, "updatedAt" = now()
        RETURNING "lastSequence"
      `,
    );

    return rows[0].lastSequence;
  }
}
