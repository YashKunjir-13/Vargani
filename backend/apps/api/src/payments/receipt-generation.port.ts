import { Injectable, Logger } from "@nestjs/common";

export interface GenerateReceiptParams {
  organizationId: string;
  festivalYear: number;
  paymentId: string;
  donorId: string | null;
  donorNameSnapshot: string;
  amount: number | string;
  contactSnapshot: string | null;
  /** Whoever recorded the payment -- attributed as the receipt PDF asset's owner; there is no separate "system user" concept. */
  createdByUserId: string;
}

export interface VoidReceiptForPaymentParams {
  organizationId: string;
  paymentId: string;
  voidedByUserId: string;
  reason: string;
}

export interface ReceiptGenerationPort {
  generateReceipt(params: GenerateReceiptParams): Promise<void>;
  /**
   * Called when the underlying Payment is voided, so a Receipted document
   * never survives as Active once its source payment no longer is. A no-op
   * if this payment was never receipted (e.g. voided while still Pending
   * Match).
   */
  voidReceiptForPayment(params: VoidReceiptForPaymentParams): Promise<void>;
}

export const RECEIPT_GENERATION_PORT = Symbol("RECEIPT_GENERATION_PORT");

/**
 * Placeholder for the Receipt Generation module, which may not exist yet at
 * this point in the build. PaymentsService is "the single source-of-truth
 * trigger" for this call (see confirmMatch/handleRazorpayWebhook) -- every
 * consumer depends only on this interface, so a real Receipt Generation
 * module can be bound to RECEIPT_GENERATION_PORT later with no caller
 * changes.
 */
@Injectable()
export class NoopReceiptGenerationPort implements ReceiptGenerationPort {
  private readonly logger = new Logger(NoopReceiptGenerationPort.name);

  async generateReceipt(params: GenerateReceiptParams): Promise<void> {
    this.logger.warn(
      `NoopReceiptGenerationPort: receipt generation for payment ${params.paymentId} is a no-op ` +
        "until the real Receipt Generation module is wired in.",
    );
  }

  async voidReceiptForPayment(params: VoidReceiptForPaymentParams): Promise<void> {
    this.logger.warn(
      `NoopReceiptGenerationPort: void propagation for payment ${params.paymentId} is a no-op ` +
        "until the real Receipt Generation module is wired in.",
    );
  }
}
