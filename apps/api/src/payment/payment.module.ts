import { Module } from "@nestjs/common";
import { PaymentsController } from "./payment.controller";

@Module({
  controllers: [PaymentsController],
})
export class PaymentModule {}
