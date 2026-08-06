import { ConflictException } from "@nestjs/common";
import { BillStatus } from "@pauti-pustak/backend-database";

/**
 * Draft -> Pending Approval -> Approved -> Paid is the only happy path;
 * Reject (Pending Approval -> Draft) and Cancel (anything not already
 * Cancelled -> Cancelled) are the only two ways off it. Rejected is
 * intentionally absent from every transition list -- see the BillStatus
 * enum comment in schema.prisma for why it's reserved but unused.
 */
const ALLOWED_TRANSITIONS: Record<BillStatus, BillStatus[]> = {
  [BillStatus.DRAFT]: [BillStatus.PENDING_APPROVAL, BillStatus.CANCELLED],
  [BillStatus.PENDING_APPROVAL]: [BillStatus.APPROVED, BillStatus.DRAFT, BillStatus.CANCELLED],
  [BillStatus.APPROVED]: [BillStatus.PAID, BillStatus.CANCELLED],
  [BillStatus.REJECTED]: [],
  [BillStatus.PAID]: [BillStatus.CANCELLED],
  [BillStatus.CANCELLED]: [],
};

export function assertBillTransition(from: BillStatus, to: BillStatus): void {
  if (!ALLOWED_TRANSITIONS[from].includes(to)) {
    throw new ConflictException(`Invalid bill status transition: ${from} -> ${to}`);
  }
}
