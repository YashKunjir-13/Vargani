/**
 * "RCPT-<festivalYear>-<sequence padded to 6 digits>", e.g. RCPT-2026-000045.
 * The sequence itself is assigned atomically per (organizationId,
 * festivalYear) by SequenceCounterService -- this only formats the result,
 * it never allocates a number.
 */
export function formatReceiptNumber(festivalYear: number, sequence: number | bigint): string {
  return `RCPT-${festivalYear}-${sequence.toString().padStart(6, "0")}`;
}
