import { formatReceiptNumber } from "./receipt-number.formatter";

describe("formatReceiptNumber", () => {
  it("pads the sequence to 6 digits", () => {
    expect(formatReceiptNumber(2026, 45)).toBe("RCPT-2026-000045");
  });

  it("does not truncate a sequence longer than 6 digits", () => {
    expect(formatReceiptNumber(2026, 1234567)).toBe("RCPT-2026-1234567");
  });

  it("accepts a bigint sequence (SequenceCounterService's return type)", () => {
    expect(formatReceiptNumber(2026, BigInt(1))).toBe("RCPT-2026-000001");
  });
});
