import { ConflictException } from "@nestjs/common";
import { PaymentStatus } from "@pauti-pustak/backend-database";
import { assertPaymentTransition } from "./payment-state-machine";

describe("assertPaymentTransition", () => {
  it("rejects a direct Pending Match -> Receipted transition", () => {
    expect(() => assertPaymentTransition(PaymentStatus.PENDING_MATCH, PaymentStatus.RECEIPTED)).toThrow(
      ConflictException,
    );
  });

  it("allows Pending Match -> Confirmed", () => {
    expect(() => assertPaymentTransition(PaymentStatus.PENDING_MATCH, PaymentStatus.CONFIRMED)).not.toThrow();
  });

  it("allows Confirmed -> Receipted", () => {
    expect(() => assertPaymentTransition(PaymentStatus.CONFIRMED, PaymentStatus.RECEIPTED)).not.toThrow();
  });

  it("allows Confirmed -> Voided and Receipted -> Voided (the only way to change a Receipted payment's status)", () => {
    expect(() => assertPaymentTransition(PaymentStatus.CONFIRMED, PaymentStatus.VOIDED)).not.toThrow();
    expect(() => assertPaymentTransition(PaymentStatus.RECEIPTED, PaymentStatus.VOIDED)).not.toThrow();
  });

  it("rejects any transition out of Voided", () => {
    expect(() => assertPaymentTransition(PaymentStatus.VOIDED, PaymentStatus.CONFIRMED)).toThrow(ConflictException);
    expect(() => assertPaymentTransition(PaymentStatus.VOIDED, PaymentStatus.RECEIPTED)).toThrow(ConflictException);
  });

  it("rejects Receipted -> Confirmed (no going backwards)", () => {
    expect(() => assertPaymentTransition(PaymentStatus.RECEIPTED, PaymentStatus.CONFIRMED)).toThrow(
      ConflictException,
    );
  });
});
