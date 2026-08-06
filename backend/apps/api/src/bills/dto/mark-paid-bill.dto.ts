import { ApiProperty } from "@nestjs/swagger";
import { PaymentMode } from "@pauti-pustak/backend-database";
import { IsIn } from "class-validator";

// This module's product spec restricts disbursement mode to these four,
// even though the shared PaymentMode enum (reused from the Expense domain)
// also has CARD/OTHER -- DTO-level validation narrows it without needing a
// second enum.
const ALLOWED_BILL_PAYMENT_MODES = [
  PaymentMode.CASH,
  PaymentMode.BANK_TRANSFER,
  PaymentMode.UPI,
  PaymentMode.CHEQUE,
] as const;

export class MarkPaidBillDto {
  @ApiProperty({ enum: ALLOWED_BILL_PAYMENT_MODES })
  @IsIn(ALLOWED_BILL_PAYMENT_MODES)
  paymentMode!: (typeof ALLOWED_BILL_PAYMENT_MODES)[number];
}
