import { ConflictException } from "@nestjs/common";
import { PaymentStatus } from "@pauti-pustak/backend-database";

/**
 * The Payment collection module's entire status surface. Receipted can only
 * be reached from Confirmed (via confirmMatch's internal receipt-generation
 * step) -- there is deliberately no API path that sets Receipted directly,
 * so a "Pending Match -> Receipted" request is always rejected here.
 */
const ALLOWED_TRANSITIONS: Record<PaymentStatus, PaymentStatus[]> = {
  [PaymentStatus.PENDING_MATCH]: [PaymentStatus.CONFIRMED, PaymentStatus.VOIDED],
  [PaymentStatus.CONFIRMED]: [PaymentStatus.RECEIPTED, PaymentStatus.VOIDED],
  [PaymentStatus.RECEIPTED]: [PaymentStatus.VOIDED],
  [PaymentStatus.VOIDED]: [],
};

export function assertPaymentTransition(from: PaymentStatus, to: PaymentStatus): void {
  if (!ALLOWED_TRANSITIONS[from].includes(to)) {
    throw new ConflictException(`Invalid payment status transition: ${from} -> ${to}`);
  }
}
