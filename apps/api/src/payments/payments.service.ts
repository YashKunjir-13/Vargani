import {
  ForbiddenException,
  Inject,
  Injectable,
  Logger,
  NotFoundException,
  ServiceUnavailableException,
} from "@nestjs/common";
import { Payment, PaymentChannel, PaymentStatus, PrismaService } from "@pauti-pustak/backend-database";
import { FestivalYearService } from "../common/festival-year/festival-year.service";
import { CreatePaymentDto } from "./dto/create-payment.dto";
import { ListPaymentsQueryDto } from "./dto/list-payments-query.dto";
import { UpdatePaymentDto } from "./dto/update-payment.dto";
import { assertPaymentTransition } from "./payment-state-machine";
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
    private readonly prisma: PrismaService,
    private readonly festivalYear: FestivalYearService,
    @Inject(RECEIPT_GENERATION_PORT) private readonly receiptGeneration: ReceiptGenerationPort,
    @Inject(RAZORPAY_ORDERS_PORT) private readonly razorpayOrders: RazorpayOrdersPort,
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
}
