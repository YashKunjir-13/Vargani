import { Injectable, Logger } from "@nestjs/common";
import * as crypto from "crypto";
import {
  CreateGatewayOrderParams,
  GatewayOrderResult,
  PaymentGatewayPort,
  RefundGatewayParams,
  RefundGatewayResult,
  VerifyGatewaySignatureParams,
} from "../ports/payment-gateway.port";

@Injectable()
export class MockPaymentAdapter implements PaymentGatewayPort {
  private readonly logger = new Logger(MockPaymentAdapter.name);

  async createOrder(params: CreateGatewayOrderParams): Promise<GatewayOrderResult> {
    const generatedOrderId = `order_mock_${crypto.randomBytes(8).toString("hex")}`;

    this.logger.log(
      `[MockPaymentAdapter] Created mock order ${generatedOrderId} for amount ${params.amountPaise} paise`,
    );

    return {
      gatewayOrderId: generatedOrderId,
      amountPaise: params.amountPaise,
      currency: params.currency ?? "INR",
      status: "created",
    };
  }

  verifySignature(params: VerifyGatewaySignatureParams): boolean {
    if (!params.orderId || !params.razorpayPaymentId) {
      return false;
    }
    // In mock mode, any non-empty signature or standard mock token is valid
    this.logger.log(`[MockPaymentAdapter] Verified mock signature for order ${params.orderId}`);
    return true;
  }

  verifyWebhookSignature(payload: string, signature: string, secret?: string): boolean {
    this.logger.log(`[MockPaymentAdapter] Verified mock webhook signature`);
    return true;
  }

  async refund(params: RefundGatewayParams): Promise<RefundGatewayResult> {
    const refundId = `rfnd_mock_${crypto.randomBytes(8).toString("hex")}`;
    this.logger.log(`[MockPaymentAdapter] Processed mock refund ${refundId} for payment ${params.razorpayPaymentId}`);

    return {
      refundId,
      status: "processed",
      amountPaise: params.amountPaise ?? BigInt(0),
    };
  }
}
