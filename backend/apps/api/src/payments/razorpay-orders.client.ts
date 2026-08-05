import { Injectable } from "@nestjs/common";
import Razorpay from "razorpay";

export interface RazorpayOrder {
  id: string;
  amount: number;
  currency: string;
}

export interface RazorpayOrdersPort {
  /**
   * Creates a Razorpay Order for the given rupee amount and returns its id.
   * The order id is what the mobile client passes into Razorpay Checkout --
   * Razorpay itself (via the payment.captured webhook, not this call and
   * not the client's checkout success callback) is the only source of
   * truth for whether money actually moved. See
   * PaymentsService.handleRazorpayWebhook.
   */
  createOrder(params: { amountRupees: number; receipt: string; notes?: Record<string, string> }): Promise<RazorpayOrder>;
}

export const RAZORPAY_ORDERS_PORT = Symbol("RAZORPAY_ORDERS_PORT");

/**
 * Thin wrapper around the official `razorpay` SDK's Orders API
 * (https://razorpay.com/docs/api/orders/#create-an-order). Amounts here are
 * in rupees (matching our domain's Payment.amount); Razorpay's API wants
 * the smallest currency subunit (paise for INR), so the rupee->paise
 * conversion is this adapter's job, not the caller's.
 */
@Injectable()
export class RazorpayOrdersClient implements RazorpayOrdersPort {
  private readonly client: Razorpay;

  constructor() {
    // RAZORPAY_KEY_ID/RAZORPAY_KEY_SECRET are required fields on
    // EnvironmentSchema (@pauti-pustak/backend-config), validated at
    // bootstrap via ConfigModule.forRoot({ validate: validateEnvironment }),
    // so both are guaranteed present by the time this constructor runs.
    this.client = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });
  }

  async createOrder(params: { amountRupees: number; receipt: string; notes?: Record<string, string> }): Promise<RazorpayOrder> {
    const order = await this.client.orders.create({
      amount: Math.round(params.amountRupees * 100),
      currency: "INR",
      receipt: params.receipt,
      notes: params.notes,
    });

    return { id: order.id, amount: Number(order.amount), currency: order.currency };
  }
}
