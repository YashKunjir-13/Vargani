import { Injectable, Logger } from "@nestjs/common";

export interface RecordBillPaymentParams {
  organizationId: string;
  festivalYear: number;
  billId: string;
  billNumber: string;
  vendorId: string | null;
  amount: number | string;
  paymentMode: string;
  paidAt: Date;
}

/**
 * The finance/ledger module doesn't exist yet (see apps/api/src/finance --
 * still a skeleton). BillsService is the trigger for a downstream ledger
 * entry once a bill is marked Paid; every caller depends only on this
 * interface (via LEDGER_PORT), so a real ledger module can be bound later
 * with no caller changes -- mirrors ReceiptGenerationPort's role for
 * Payments before Receipt Generation existed.
 */
export interface LedgerPort {
  recordBillPayment(params: RecordBillPaymentParams): Promise<void>;
}

export const LEDGER_PORT = Symbol("LEDGER_PORT");

@Injectable()
export class NoopLedgerPort implements LedgerPort {
  private readonly logger = new Logger(NoopLedgerPort.name);

  async recordBillPayment(params: RecordBillPaymentParams): Promise<void> {
    this.logger.warn(
      `NoopLedgerPort: ledger entry for bill ${params.billId} (${params.billNumber}) is a no-op ` +
        "until the real Finance/Ledger module is wired in.",
    );
  }
}
