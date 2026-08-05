import { formatBillNumber } from "./bill-number.formatter";

describe("formatBillNumber", () => {
  it("pads the sequence to 6 digits", () => {
    expect(formatBillNumber(2026, 45)).toBe("BILL-2026-000045");
  });

  it("does not truncate a sequence longer than 6 digits", () => {
    expect(formatBillNumber(2026, 1234567)).toBe("BILL-2026-1234567");
  });

  it("accepts a bigint sequence (SequenceCounterService's return type)", () => {
    expect(formatBillNumber(2026, BigInt(1))).toBe("BILL-2026-000001");
  });
});
