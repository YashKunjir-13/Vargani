/**
 * "BILL-<festivalYear>-<sequence padded to 6 digits>", e.g. BILL-2026-000045.
 * Mirrors receipts/receipt-number.formatter.ts. The sequence itself is
 * assigned atomically per (organizationId, festivalYear) by
 * SequenceCounterService -- this only formats the result.
 */
export function formatBillNumber(festivalYear: number, sequence: number | bigint): string {
  return `BILL-${festivalYear}-${sequence.toString().padStart(6, "0")}`;
}
