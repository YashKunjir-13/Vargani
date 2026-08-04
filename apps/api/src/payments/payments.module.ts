import { Module } from "@nestjs/common";
import { FestivalYearModule } from "../common/festival-year/festival-year.module";
import { TenancyModule } from "../common/tenancy/tenancy.module";
import { ReceiptsModule } from "../receipts/receipts.module";
import { ReceiptsService } from "../receipts/receipts.service";
import { PaymentsController } from "./payments.controller";
import { PaymentsService } from "./payments.service";
import { RAZORPAY_ORDERS_PORT, RazorpayOrdersClient } from "./razorpay-orders.client";
import { RAZORPAY_SIGNATURE_VERIFIER, HmacRazorpaySignatureVerifier } from "./razorpay-signature.verifier";
import { RECEIPT_GENERATION_PORT } from "./receipt-generation.port";

@Module({
  imports: [TenancyModule, FestivalYearModule, ReceiptsModule],
  controllers: [PaymentsController],
  providers: [
    PaymentsService,
    // ReceiptsService implements ReceiptGenerationPort -- Receipt Generation is
    // wired in for real here; NoopReceiptGenerationPort remains available for
    // any test/bootstrap context that wants to stand PaymentsModule up alone.
    { provide: RECEIPT_GENERATION_PORT, useExisting: ReceiptsService },
    { provide: RAZORPAY_SIGNATURE_VERIFIER, useClass: HmacRazorpaySignatureVerifier },
    { provide: RAZORPAY_ORDERS_PORT, useClass: RazorpayOrdersClient },
  ],
  exports: [PaymentsService],
})
export class PaymentsModule {}
