import { Module } from "@nestjs/common";
import { FestivalYearModule } from "../common/festival-year/festival-year.module";
import { TenancyModule } from "../common/tenancy/tenancy.module";
import { ReceiptsModule } from "../receipts/receipts.module";
import { ReceiptsService } from "../receipts/receipts.service";
import { PaymentsController } from "./payments.controller";
import { PaymentsService } from "./payments.service";
import { RazorpayGatewayAdapter } from "./adapters/razorpay-gateway.adapter";
import { PAYMENT_GATEWAY_PORT } from "./ports/payment-gateway.port";
import { RAZORPAY_ORDERS_PORT, RazorpayOrdersClient } from "./razorpay-orders.client";
import { RAZORPAY_SIGNATURE_VERIFIER, HmacRazorpaySignatureVerifier } from "./razorpay-signature.verifier";
import { RECEIPT_GENERATION_PORT } from "./receipt-generation.port";

@Module({
  imports: [TenancyModule, FestivalYearModule, ReceiptsModule],
  controllers: [PaymentsController],
  providers: [
    PaymentsService,
    RazorpayGatewayAdapter,
    { provide: PAYMENT_GATEWAY_PORT, useClass: RazorpayGatewayAdapter },
    { provide: RECEIPT_GENERATION_PORT, useExisting: ReceiptsService },
    { provide: RAZORPAY_SIGNATURE_VERIFIER, useClass: HmacRazorpaySignatureVerifier },
    { provide: RAZORPAY_ORDERS_PORT, useClass: RazorpayOrdersClient },
  ],
  exports: [PaymentsService, PAYMENT_GATEWAY_PORT],
})
export class PaymentsModule {}
