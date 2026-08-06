import { SequenceCounterService } from "./sequence-counter.service";

/**
 * Simulates the Postgres row-locking guarantee of the real
 * `INSERT ... ON CONFLICT ... DO UPDATE ... RETURNING` statement: each call
 * for a given key performs a synchronous read-increment-write, so no two
 * concurrent callers can ever observe or return the same value. This lets
 * the test assert the service's *contract* (unique, gapless numbers under
 * concurrent callers) without a live database -- true multi-process
 * atomicity is enforced by Postgres itself for the real single-statement
 * query, not re-tested here.
 */
function buildAtomicPrismaMock() {
  const counters = new Map<string, bigint>();

  return {
    // The real call site passes a single Prisma.Sql object (built via
    // Prisma.sql`...`), which exposes its interpolated parameters via
    // `.values` in template order: id, organizationId, festivalYear,
    // sequenceName, ...
    $queryRaw: jest.fn(async (query: { values: any[] }) => {
      const [, organizationId, festivalYear, sequenceName] = query.values;
      const key = `${organizationId}::${festivalYear}::${sequenceName}`;
      const next = (counters.get(key) ?? 0n) + 1n;
      counters.set(key, next);
      return [{ lastSequence: next }];
    }),
  };
}

describe("SequenceCounterService", () => {
  it("produces unique, gapless numbers under concurrent calls for the same key", async () => {
    const prisma = buildAtomicPrismaMock();
    const service = new SequenceCounterService(prisma as any);

    const results = await Promise.all(
      Array.from({ length: 50 }, () => service.getNextSequence("org-1", 2025, "receipt")),
    );

    const sorted = [...results].sort((a, b) => (a < b ? -1 : a > b ? 1 : 0));
    const uniqueCount = new Set(sorted.map(String)).size;

    expect(uniqueCount).toBe(50); // no two callers got the same number
    expect(sorted).toEqual(Array.from({ length: 50 }, (_, i) => BigInt(i + 1))); // 1..50, no gaps
  });

  it("keeps separate, independently-numbered sequences per organizationId+festivalYear+sequenceName", async () => {
    const prisma = buildAtomicPrismaMock();
    const service = new SequenceCounterService(prisma as any);

    const [receiptOrgA, billOrgA, receiptOrgAYear2026, receiptOrgB] = await Promise.all([
      service.getNextSequence("org-a", 2025, "receipt"),
      service.getNextSequence("org-a", 2025, "bill"),
      service.getNextSequence("org-a", 2026, "receipt"),
      service.getNextSequence("org-b", 2025, "receipt"),
    ]);

    // Every distinct key starts its own sequence at 1 -- numbering never
    // leaks across organizations, festival years, or sequence names.
    expect(receiptOrgA).toBe(1n);
    expect(billOrgA).toBe(1n);
    expect(receiptOrgAYear2026).toBe(1n);
    expect(receiptOrgB).toBe(1n);

    const second = await service.getNextSequence("org-a", 2025, "receipt");
    expect(second).toBe(2n);
  });
});
