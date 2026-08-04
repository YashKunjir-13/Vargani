export interface CreateGatewayOrderParams {
  amountPaise: bigint;
  currency: string;
  receiptId?: string;
  notes?: Record<string, string>;
}

export interface GatewayOrderResult {
  gatewayOrderId: string;
  amountPaise: bigint;
  currency: string;
  status: string;
}

export interface VerifyGatewaySignatureParams {
  orderId: string;
  razorpayPaymentId: string;
  razorpaySignature: string;
}

export interface RefundGatewayParams {
  razorpayPaymentId: string;
  amountPaise?: bigint;
  reason?: string;
}

export interface RefundGatewayResult {
  refundId: string;
  status: string;
  amountPaise: bigint;
}

export interface PaymentGatewayPort {
  createOrder(params: CreateGatewayOrderParams): Promise<GatewayOrderResult>;
  verifySignature(params: VerifyGatewaySignatureParams): boolean;
  verifyWebhookSignature(payload: string, signature: string, secret: string): boolean;
  refund(params: RefundGatewayParams): Promise<RefundGatewayResult>;
}

export const PAYMENT_GATEWAY_PORT = Symbol("PAYMENT_GATEWAY_PORT");
