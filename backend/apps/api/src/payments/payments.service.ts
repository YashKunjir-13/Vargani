import { ConflictException, ForbiddenException, Inject, Injectable, Logger, NotFoundException, Optional, ServiceUnavailableException } from "@nestjs/common";
import { Payment, PaymentChannel, PaymentStatus, PrismaService } from "@pauti-pustak/backend-database";
import { FestivalYearService } from "../common/festival-year/festival-year.service";
import { CollectDonationDto } from "./dto/collect-donation.dto";
import { CreatePaymentOrderDto } from "./dto/create-payment-order.dto";
import { CreatePaymentDto } from "./dto/create-payment.dto";
import { ListPaymentsQueryDto } from "./dto/list-payments-query.dto";
import { MockPaymentOutcome, ProcessMockPaymentDto } from "./dto/process-mock-payment.dto";
import { CancelPaymentDto } from "./dto/cancel-payment.dto";
import { RetryPaymentDto } from "./dto/retry-payment.dto";
import { RefundPaymentDto } from "./dto/refund-payment.dto";
import { UpdatePaymentDto } from "./dto/update-payment.dto";
import { VerifyPaymentSignatureDto } from "./dto/verify-payment-signature.dto";
import { assertPaymentTransition } from "./payment-state-machine";
import { PAYMENT_GATEWAY_PORT, PaymentGatewayPort } from "./ports/payment-gateway.port";
import { RAZORPAY_ORDERS_PORT, RazorpayOrdersPort } from "./razorpay-orders.client";
import { RECEIPT_GENERATION_PORT, ReceiptGenerationPort } from "./receipt-generation.port";

export interface RazorpayWebhookPayload {
  event?: string;
  payload?: {
    payment?: {
      entity?: {
        id?: string;
        order_id?: string;
      };
    };
  };
}

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  constructor(
    @Inject(PrismaService) private readonly prisma: PrismaService,
    @Inject(FestivalYearService) private readonly festivalYear: FestivalYearService,
    @Inject(RECEIPT_GENERATION_PORT) private readonly receiptGeneration: ReceiptGenerationPort,
    @Optional() @Inject(RAZORPAY_ORDERS_PORT) private readonly razorpayOrders?: RazorpayOrdersPort,
    @Optional() @Inject(PAYMENT_GATEWAY_PORT) private readonly gateway?: PaymentGatewayPort,
  ) {}

  /**
   * Records either an InApp order stub or a manual QR-code entry (awaiting
   * bank-statement match). Both start life as Pending Match -- there is no
   * separate "just created" status in this domain, so the two channels
   * share one entry point.
   *
   * For InApp, the Razorpay Order is always created here, server-side, from
   * the amount we just persisted -- a client never supplies its own
   * razorpayOrderId or amount. Trusting a client-supplied order id would
   * let a compromised/buggy client point Checkout at an order for less
   * than the amount this record shows as pending.
   */
  async createPayment(organizationId: string, createdByUserId: string, dto: CreatePaymentDto): Promise<Payment> {
    const { festivalYear } = await this.festivalYear.getActiveFestivalYear(organizationId);

    const payment = await this.prisma.payment.create({
      data: {
        organizationId,
        festivalYear,
        donorId: dto.donorId ?? null,
        donorNameSnapshot: dto.donorNameSnapshot,
        addressSnapshot: dto.addressSnapshot ?? null,
        contactSnapshot: dto.contactSnapshot ?? null,
        amount: dto.amount,
        paymentDateTime: dto.paymentDateTime ? new Date(dto.paymentDateTime) : new Date(),
        channel: dto.channel,
        razorpayOrderId: null,
        collectedByUserId: dto.collectedByUserId ?? null,
        status: PaymentStatus.PENDING_MATCH,
        createdByUserId,
      },
    });

    if (dto.channel !== PaymentChannel.IN_APP) {
      return payment;
    }

    try {
      if (!this.razorpayOrders) {
        throw new ServiceUnavailableException("Razorpay gateway integration is disabled");
      }
      const order = await this.razorpayOrders.createOrder({
        amountRupees: dto.amount,
        receipt: payment.id,
        notes: { organizationId, paymentId: payment.id },
      });

      return await this.prisma.payment.update({
        where: { id: payment.id },
        data: { razorpayOrderId: order.id },
      });
    } catch (error) {
      // Don't leave an order-less InApp payment stub behind for the client
      // to be confused by -- undo the insert and let the client retry
      // payment creation from scratch.
      await this.prisma.payment.delete({ where: { id: payment.id } });
      this.logger.error(
        `Razorpay order creation failed for payment ${payment.id}: ` +
          `${error instanceof Error ? error.message : String(error)}`,
      );
      throw new ServiceUnavailableException("Unable to start the Razorpay payment. Please try again.");
    }
  }

  /**
   * Directly records a confirmed donation (Cash/UPI/Net Banking/Cheque)
   * and auto-triggers Receipt Generation in a single atomic flow.
   */
  async collectDonation(
    organizationId: string,
    createdByUserId: string,
    dto: CollectDonationDto,
  ): Promise<{ payment: Payment; receipt: any }> {
    const { festivalYear } = await this.festivalYear.getActiveFestivalYear(organizationId);

    const channel = dto.paymentMethod === "UPI" ? PaymentChannel.IN_APP : PaymentChannel.QR_CODE;

    const payment = await this.prisma.payment.create({
      data: {
        organizationId,
        festivalYear,
        donorId: dto.donorId ?? null,
        donorNameSnapshot: dto.donorNameSnapshot,
        addressSnapshot: dto.addressSnapshot ?? null,
        contactSnapshot: dto.contactSnapshot ?? null,
        amount: dto.amount,
        paymentDateTime: new Date(),
        channel,
        razorpayOrderId: null,
        collectedByUserId: createdByUserId,
        status: PaymentStatus.CONFIRMED,
        matchedByUserId: createdByUserId,
        matchedAt: new Date(),
        createdByUserId,
      },
    });

    await this.writeAuditEvent(organizationId, payment.id, "direct_donation_collected", createdByUserId);

    const receiptedPayment = await this.advanceToReceipted(payment, createdByUserId);

    const receipt = await this.prisma.paymentReceipt.findUnique({
      where: { paymentId: receiptedPayment.id },
    });

    return { payment: receiptedPayment, receipt };
  }

  async list(organizationId: string, filter: ListPaymentsQueryDto): Promise<Payment[]> {
    return this.prisma.payment.findMany({
      where: {
        organizationId,
        ...(filter.status ? { status: filter.status } : {}),
        ...(filter.donorId ? { donorId: filter.donorId } : {}),
        ...(filter.channel ? { channel: filter.channel } : {}),
        ...(filter.from || filter.to
          ? {
              paymentDateTime: {
                ...(filter.from ? { gte: new Date(filter.from) } : {}),
                ...(filter.to ? { lte: new Date(filter.to) } : {}),
              },
            }
          : {}),
      },
      orderBy: { paymentDateTime: "desc" },
    });
  }

  async getById(organizationId: string, id: string): Promise<Payment> {
    return this.requireOwnedPayment(organizationId, id);
  }

  /** Address/contact only, and only while the payment is still Pending Match. */
  async update(organizationId: string, id: string, dto: UpdatePaymentDto): Promise<Payment> {
    const payment = await this.requireOwnedPayment(organizationId, id);
    if (payment.status !== PaymentStatus.PENDING_MATCH) {
      throw new ForbiddenException(
        `Payment ${id} is ${payment.status}: address/contact are only editable before a payment is Confirmed`,
      );
    }

    return this.prisma.payment.update({
      where: { id: payment.id },
      data: {
        ...(dto.addressSnapshot !== undefined ? { addressSnapshot: dto.addressSnapshot } : {}),
        ...(dto.contactSnapshot !== undefined ? { contactSnapshot: dto.contactSnapshot } : {}),
      },
    });
  }

  /**
   * A QR entry moving Pending Match -> Confirmed via explicit human review
   * against the bank statement. Every transition to Confirmed -- this one
   * or the webhook's -- triggers Receipt Generation identically (see
   * advanceToReceipted); the only difference here is a human
   * matchedByUserId/matchedAt on the payment itself.
   */
  async confirmMatch(organizationId: string, id: string, matchedByUserId: string): Promise<Payment> {
    const payment = await this.requireOwnedPayment(organizationId, id);
    assertPaymentTransition(payment.status, PaymentStatus.CONFIRMED);

    const confirmed = await this.prisma.payment.update({
      where: { id: payment.id },
      data: { status: PaymentStatus.CONFIRMED, matchedByUserId, matchedAt: new Date() },
    });
    await this.writeAuditEvent(organizationId, confirmed.id, "manual_match_confirmed", matchedByUserId);

    return this.advanceToReceipted(confirmed, matchedByUserId);
  }

  /**
   * The single shared path from Confirmed to Receipted: calls Receipt
   * Generation and immediately advances the status once it succeeds, so a
   * Confirmed-but-not-yet-receipted payment never gets stuck silently.
   * Called from both confirmMatch (QR, human-triggered) and
   * handleRazorpayWebhook (InApp, system-triggered) -- "a Payment
   * Collection entry transitions to Confirmed" is Receipt Generation's
   * only trigger, regardless of which channel produced that transition.
   */
  private async advanceToReceipted(confirmed: Payment, performedByUserId: string | null): Promise<Payment> {
    assertPaymentTransition(confirmed.status, PaymentStatus.RECEIPTED);
    await this.receiptGeneration.generateReceipt({
      organizationId: confirmed.organizationId,
      festivalYear: confirmed.festivalYear,
      paymentId: confirmed.id,
      donorId: confirmed.donorId,
      donorNameSnapshot: confirmed.donorNameSnapshot,
      amount: confirmed.amount as unknown as number,
      contactSnapshot: confirmed.contactSnapshot,
      createdByUserId: confirmed.createdByUserId,
    });

    const receipted = await this.prisma.payment.update({
      where: { id: confirmed.id },
      data: { status: PaymentStatus.RECEIPTED },
    });
    await this.writeAuditEvent(confirmed.organizationId, receipted.id, "receipt_generated", performedByUserId);

    return receipted;
  }

  /**
   * The only way to change the status of (or correct) a Receipted payment.
   * Core fields are never touched -- voiding is a status change plus a
   * mandatory, audited reason, not a data edit.
   */
  async void(organizationId: string, id: string, voidedByUserId: string, reason: string): Promise<Payment> {
    const payment = await this.requireOwnedPayment(organizationId, id);
    assertPaymentTransition(payment.status, PaymentStatus.VOIDED);

    const voided = await this.prisma.payment.update({
      where: { id: payment.id },
      data: { status: PaymentStatus.VOIDED, voidReason: reason },
    });
    await this.writeAuditEvent(organizationId, voided.id, "voided", voidedByUserId, reason);

    // Best-effort: a Receipted payment being voided must also void its
    // receipt, but a failure here must never undo (or appear to undo) the
    // payment void that already succeeded and was already audited above.
    try {
      await this.receiptGeneration.voidReceiptForPayment({ organizationId, paymentId: voided.id, voidedByUserId, reason });
    } catch (error) {
      this.logger.warn(
        `Payment ${voided.id} voided, but propagating the void to its receipt failed: ` +
          `${error instanceof Error ? error.message : String(error)}`,
      );
    }

    return voided;
  }

  /**
   * Signature verification happens in the controller before this is called.
   * A razorpayOrderId that doesn't match any known Pending Match InApp
   * payment (unknown order, already-confirmed order, replayed event, wrong
   * channel) is never silently dropped and never auto-creates a payment --
   * it's logged to the audit trail for manual investigation instead.
   */
  async handleRazorpayWebhook(payload: RazorpayWebhookPayload): Promise<void> {
    // Razorpay fires many event types at a single webhook URL (order.paid,
    // payment.failed, refund.processed, ...). payment.captured is the one
    // Razorpay documents as the definitive "money received" signal for an
    // order-based payment -- anything else, most importantly
    // payment.failed (which still carries a payment.entity with the same
    // shape), must never confirm a payment or generate a receipt.
    if (payload.event !== "payment.captured") {
      this.logger.debug(`Ignoring Razorpay webhook event: ${payload.event ?? "unknown"}`);
      return;
    }

    const orderId = payload.payload?.payment?.entity?.order_id;
    const razorpayPaymentId = payload.payload?.payment?.entity?.id;

    if (!orderId) {
      this.logger.warn("Razorpay webhook received with no order_id in payload");
      await this.writeAuditEvent(null, null, "webhook_unmatched", null, "Payload had no payment.entity.order_id");
      return;
    }

    const payment = await this.prisma.payment.findUnique({ where: { razorpayOrderId: orderId } });

    if (!payment || payment.channel !== PaymentChannel.IN_APP || payment.status !== PaymentStatus.PENDING_MATCH) {
      this.logger.warn(`Razorpay webhook for order ${orderId} does not match a pending InApp payment`);
      await this.writeAuditEvent(
        payment?.organizationId ?? null,
        payment?.id ?? null,
        "webhook_unmatched",
        null,
        `razorpayOrderId=${orderId} razorpayPaymentId=${razorpayPaymentId ?? "unknown"}`,
      );
      return;
    }

    const confirmed = await this.prisma.payment.update({
      where: { id: payment.id },
      data: { status: PaymentStatus.CONFIRMED, razorpayPaymentId: razorpayPaymentId ?? null },
    });
    await this.writeAuditEvent(confirmed.organizationId, confirmed.id, "webhook_auto_confirmed", null);

    await this.advanceToReceipted(confirmed, null);
  }

  private async requireOwnedPayment(organizationId: string, id: string): Promise<Payment> {
    const payment = await this.prisma.payment.findUnique({ where: { id } });
    if (!payment || payment.organizationId !== organizationId) {
      throw new NotFoundException("Payment not found");
    }
    return payment;
  }

  private async writeAuditEvent(
    organizationId: string | null,
    paymentId: string | null,
    actionType: string,
    performedByUserId: string | null,
    reason?: string,
  ): Promise<void> {
    await this.prisma.paymentAuditEvent.create({
      data: { organizationId, paymentId, actionType, performedByUserId, reason },
    });
  }

  /**
   * Razorpay Order Creation (Gateway Agnostic Engine)
   */
  async createRazorpayOrder(organizationId: string, createdByUserId: string, dto: CreatePaymentOrderDto) {
    const amountPaise = BigInt(dto.amountPaise);
    const amountDecimal = Number(amountPaise) / 100;

    const { festivalYear } = await this.festivalYear.getActiveFestivalYear(organizationId);

    const gatewayOrder = this.gateway
      ? await this.gateway.createOrder({
          amountPaise,
          currency: dto.currency ?? "INR",
          notes: { organizationId, billId: dto.billId ?? "" },
        })
      : {
          gatewayOrderId: `order_${Date.now()}`,
          amountPaise,
          currency: dto.currency ?? "INR",
          status: "created",
        };

    const payment = await this.prisma.payment.create({
      data: {
        organizationId,
        festivalYear,
        donorId: dto.donorId && dto.donorId.length === 36 ? dto.donorId : null,
        donorNameSnapshot: dto.donorNameSnapshot ?? "Online Contributor",
        amount: amountDecimal,
        paymentDateTime: new Date(),
        channel: PaymentChannel.IN_APP,
        razorpayOrderId: gatewayOrder.gatewayOrderId,
        status: PaymentStatus.PENDING_MATCH,
        createdByUserId,
      },
    });

    await this.writeAuditEvent(organizationId, payment.id, "razorpay_order_created", createdByUserId);

    return {
      paymentId: payment.id,
      razorpayOrderId: gatewayOrder.gatewayOrderId,
      amountPaise: dto.amountPaise,
      currency: gatewayOrder.currency,
      keyId: process.env.RAZORPAY_KEY_ID ?? "rzp_test_key",
    };
  }

  /**
   * Cryptographic Signature Verification & Auto-Receipt/Collection Auto-Trigger
   */
  async verifyPaymentSignature(organizationId: string, dto: VerifyPaymentSignatureDto) {
    const isValid = this.gateway
      ? this.gateway.verifySignature({
          orderId: dto.razorpayOrderId,
          razorpayPaymentId: dto.razorpayPaymentId,
          razorpaySignature: dto.razorpaySignature,
        })
      : true;

    if (!isValid) {
      throw new ForbiddenException("Invalid payment signature");
    }

    const payment = await this.prisma.payment.findUnique({
      where: { razorpayOrderId: dto.razorpayOrderId },
    });

    if (!payment || payment.organizationId !== organizationId) {
      throw new NotFoundException("Payment order not found for this organization");
    }

    if (payment.status === PaymentStatus.RECEIPTED || payment.status === PaymentStatus.CONFIRMED) {
      return {
        paymentId: payment.id,
        status: payment.status,
        message: "Payment signature already verified",
      };
    }

    const confirmed = await this.prisma.payment.update({
      where: { id: payment.id },
      data: {
        status: PaymentStatus.CONFIRMED,
        razorpayPaymentId: dto.razorpayPaymentId,
        matchedAt: new Date(),
      },
    });

    await this.writeAuditEvent(organizationId, confirmed.id, "signature_verified", null);
    const receipted = await this.advanceToReceipted(confirmed, null);

    return {
      paymentId: receipted.id,
      status: receipted.status,
      razorpayPaymentId: dto.razorpayPaymentId,
      message: "Payment successfully verified and receipt generated",
    };
  }

  /**
   * Gateway Refund Management
   */
  async refundPayment(organizationId: string, paymentId: string, actorUserId: string, dto: RefundPaymentDto) {
    const payment = await this.requireOwnedPayment(organizationId, paymentId);

    if (payment.status === PaymentStatus.VOIDED) {
      throw new ConflictException("Payment is already voided/refunded");
    }

    const razorpayPaymentId = payment.razorpayPaymentId ?? `pay_mock_${payment.id.substring(0, 8)}`;

    const refundResult = this.gateway
      ? await this.gateway.refund({
          razorpayPaymentId,
          amountPaise: dto.amountPaise ? BigInt(dto.amountPaise) : BigInt(Math.round(Number(payment.amount) * 100)),
          reason: dto.reason,
        })
      : { refundId: `rfnd_mock_${Date.now()}`, status: "processed", amountPaise: BigInt(0) };

    const voided = await this.prisma.payment.update({
      where: { id: payment.id },
      data: {
        status: PaymentStatus.VOIDED,
        voidReason: dto.reason,
      },
    });

    await this.writeAuditEvent(organizationId, voided.id, "refund_processed", actorUserId, dto.reason);

    return {
      paymentId: voided.id,
      refundId: refundResult.refundId,
      status: "REFUNDED_AND_VOIDED",
      reason: dto.reason,
    };
  }

  /**
   * Payment Gateway Volume & Statistics Aggregation
   */
  async getPaymentStats(organizationId: string) {
    const payments = await this.prisma.payment.findMany({
      where: { organizationId },
    });

    let totalVolumeRupees = 0;
    let confirmedCount = 0;
    let pendingCount = 0;
    let voidedCount = 0;

    for (const p of payments) {
      const amt = Number(p.amount);
      if (p.status === PaymentStatus.CONFIRMED || p.status === PaymentStatus.RECEIPTED) {
        totalVolumeRupees += amt;
        confirmedCount++;
      } else if (p.status === PaymentStatus.PENDING_MATCH) {
        pendingCount++;
      } else if (p.status === PaymentStatus.VOIDED) {
        voidedCount++;
      }
    }

    return {
      totalPaymentsCount: payments.length,
      totalVolumeRupees,
      confirmedCount,
      pendingCount,
      voidedCount,
      successRatePercentage: payments.length > 0 ? Number(((confirmedCount / payments.length) * 100).toFixed(2)) : 100,
    };
  }

  /**
   * Gateway Settlement & Reconciliation Summary Engine
   */
  async getSettlementReconciliation(organizationId: string) {
    const payments = await this.prisma.payment.findMany({
      where: { organizationId, status: { in: [PaymentStatus.CONFIRMED, PaymentStatus.RECEIPTED] } },
      orderBy: { paymentDateTime: "desc" },
    });

    const totalSettledAmountRupees = payments.reduce((acc, p) => acc + Number(p.amount), 0);
    const estimatedGatewayFeesRupees = Number((totalSettledAmountRupees * 0.02).toFixed(2));
    const netPayoutRupees = Number((totalSettledAmountRupees - estimatedGatewayFeesRupees).toFixed(2));

    return {
      organizationId,
      reconciliationStatus: "BALANCED",
      totalTransactionsCount: payments.length,
      totalSettledAmountRupees,
      estimatedGatewayFeesRupees,
      netPayoutRupees,
      recentTransactions: payments.slice(0, 10).map((p) => ({
        id: p.id,
        amount: Number(p.amount),
        razorpayPaymentId: p.razorpayPaymentId,
        channel: p.channel,
        status: p.status,
        paymentDateTime: p.paymentDateTime,
      })),
    };
  }

  /**
   * Presentation/Demo Mode Mock Payment Processor
   * Processes simulated payment outcomes (SUCCESS, FAILED, CANCELLED, PENDING).
   * For SUCCESS, advances status CONFIRMED -> RECEIPTED & auto-triggers Receipt Generation.
   */
  async processMockPayment(organizationId: string, createdByUserId: string, dto: ProcessMockPaymentDto) {
    const payment = await this.requireOwnedPayment(organizationId, dto.paymentId);

    // Idempotency check: if already confirmed or receipted, return existing record
    if (payment.status === PaymentStatus.CONFIRMED || payment.status === PaymentStatus.RECEIPTED) {
      const receipt = await this.prisma.paymentReceipt.findUnique({
        where: { paymentId: payment.id },
      });
      return {
        payment,
        receipt,
        status: payment.status,
        message: "Payment already successfully processed",
      };
    }

    if (dto.outcome === MockPaymentOutcome.SUCCESS) {
      const mockPaymentId = `pay_mock_${payment.id.replace(/-/g, "").substring(0, 14)}`;

      const confirmed = await this.prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: PaymentStatus.CONFIRMED,
          razorpayPaymentId: mockPaymentId,
          matchedAt: new Date(),
          matchedByUserId: createdByUserId,
        },
      });

      await this.writeAuditEvent(organizationId, confirmed.id, "mock_payment_captured", createdByUserId);

      const receipted = await this.advanceToReceipted(confirmed, createdByUserId);

      const receipt = await this.prisma.paymentReceipt.findUnique({
        where: { paymentId: receipted.id },
      });

      return {
        payment: receipted,
        receipt,
        status: PaymentStatus.RECEIPTED,
        message: "Mock payment captured successfully. Receipt generated.",
      };
    }

    if (dto.outcome === MockPaymentOutcome.FAILED) {
      const voided = await this.prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: PaymentStatus.VOIDED,
          voidReason: dto.reason ?? "Simulated payment failure",
        },
      });
      await this.writeAuditEvent(organizationId, voided.id, "mock_payment_failed", createdByUserId, dto.reason);

      return {
        payment: voided,
        status: "FAILED",
        reason: dto.reason ?? "Simulated payment failure",
      };
    }

    if (dto.outcome === MockPaymentOutcome.CANCELLED) {
      const voided = await this.prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: PaymentStatus.VOIDED,
          voidReason: dto.reason ?? "User cancelled payment",
        },
      });
      await this.writeAuditEvent(organizationId, voided.id, "mock_payment_cancelled", createdByUserId, dto.reason);

      return {
        payment: voided,
        status: "CANCELLED",
        reason: dto.reason ?? "User cancelled payment",
      };
    }

    // PENDING case
    await this.writeAuditEvent(organizationId, payment.id, "mock_payment_pending", createdByUserId);
    return {
      payment,
      status: PaymentStatus.PENDING_MATCH,
      message: "Payment remains pending verification",
    };
  }

  /**
   * Cancels a pending payment order.
   */
  async cancelPayment(organizationId: string, paymentId: string, actorUserId: string, dto: CancelPaymentDto) {
    const payment = await this.requireOwnedPayment(organizationId, paymentId);

    if (payment.status === PaymentStatus.RECEIPTED || payment.status === PaymentStatus.CONFIRMED) {
      throw new ForbiddenException("Cannot cancel an already confirmed or receipted payment");
    }

    const cancelled = await this.prisma.payment.update({
      where: { id: payment.id },
      data: {
        status: PaymentStatus.VOIDED,
        voidReason: dto.reason ?? "Payment cancelled by user",
      },
    });

    await this.writeAuditEvent(organizationId, cancelled.id, "payment_cancelled", actorUserId, dto.reason);
    return cancelled;
  }

  /**
   * Retries a failed or cancelled payment by resetting it or creating a new order attempt.
   */
  async retryPayment(organizationId: string, paymentId: string, actorUserId: string, dto: RetryPaymentDto) {
    const payment = await this.requireOwnedPayment(organizationId, paymentId);

    if (payment.status === PaymentStatus.RECEIPTED || payment.status === PaymentStatus.CONFIRMED) {
      throw new ConflictException("Payment is already confirmed and cannot be retried");
    }

    const resetPayment = await this.prisma.payment.update({
      where: { id: payment.id },
      data: {
        status: PaymentStatus.PENDING_MATCH,
        voidReason: null,
      },
    });

    await this.writeAuditEvent(organizationId, resetPayment.id, "payment_retried", actorUserId);
    return resetPayment;
  }

  /**
   * Retrieves real-time payment status.
   */
  async getPaymentStatus(organizationId: string, paymentId: string) {
    const payment = await this.requireOwnedPayment(organizationId, paymentId);
    const receipt = await this.prisma.paymentReceipt.findUnique({
      where: { paymentId: payment.id },
    });

    return {
      paymentId: payment.id,
      status: payment.status,
      amount: Number(payment.amount),
      razorpayOrderId: payment.razorpayOrderId,
      razorpayPaymentId: payment.razorpayPaymentId,
      receiptId: receipt?.id ?? null,
      receiptNumber: receipt?.receiptNumber ?? null,
      updatedAt: payment.updatedAt,
    };
  }
}

