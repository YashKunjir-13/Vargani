import { ConflictException } from "@nestjs/common";
import { BillStatus } from "@pauti-pustak/backend-database";
import { assertBillTransition } from "./bill-state-machine";

describe("assertBillTransition", () => {
  it("rejects a direct Draft -> Paid transition (skips submit and approve)", () => {
    expect(() => assertBillTransition(BillStatus.DRAFT, BillStatus.PAID)).toThrow(ConflictException);
  });

  it("rejects a direct Draft -> Approved transition (skips submit)", () => {
    expect(() => assertBillTransition(BillStatus.DRAFT, BillStatus.APPROVED)).toThrow(ConflictException);
  });

  it("rejects a direct Pending Approval -> Paid transition (skips approve)", () => {
    expect(() => assertBillTransition(BillStatus.PENDING_APPROVAL, BillStatus.PAID)).toThrow(ConflictException);
  });

  it("allows the full happy path: Draft -> Pending Approval -> Approved -> Paid", () => {
    expect(() => assertBillTransition(BillStatus.DRAFT, BillStatus.PENDING_APPROVAL)).not.toThrow();
    expect(() => assertBillTransition(BillStatus.PENDING_APPROVAL, BillStatus.APPROVED)).not.toThrow();
    expect(() => assertBillTransition(BillStatus.APPROVED, BillStatus.PAID)).not.toThrow();
  });

  it("allows reject: Pending Approval -> Draft", () => {
    expect(() => assertBillTransition(BillStatus.PENDING_APPROVAL, BillStatus.DRAFT)).not.toThrow();
  });

  it("allows cancel from Draft, Pending Approval, Approved, and Paid", () => {
    expect(() => assertBillTransition(BillStatus.DRAFT, BillStatus.CANCELLED)).not.toThrow();
    expect(() => assertBillTransition(BillStatus.PENDING_APPROVAL, BillStatus.CANCELLED)).not.toThrow();
    expect(() => assertBillTransition(BillStatus.APPROVED, BillStatus.CANCELLED)).not.toThrow();
    expect(() => assertBillTransition(BillStatus.PAID, BillStatus.CANCELLED)).not.toThrow();
  });

  it("rejects any transition out of Cancelled (terminal)", () => {
    expect(() => assertBillTransition(BillStatus.CANCELLED, BillStatus.DRAFT)).toThrow(ConflictException);
    expect(() => assertBillTransition(BillStatus.CANCELLED, BillStatus.PENDING_APPROVAL)).toThrow(ConflictException);
  });

  it("rejects any transition out of Paid other than Cancelled", () => {
    expect(() => assertBillTransition(BillStatus.PAID, BillStatus.APPROVED)).toThrow(ConflictException);
    expect(() => assertBillTransition(BillStatus.PAID, BillStatus.DRAFT)).toThrow(ConflictException);
  });
});
