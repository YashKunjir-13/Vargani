import { Injectable } from "@nestjs/common";

export interface ProposedBillFields {
  amount?: number;
  date?: string;
  receiverName?: string;
  contact?: string;
}

/**
 * A pure, read-only proposal step: given a photo of the physical vendor
 * bill, suggests field values for the Treasurer to review and edit before
 * ever calling POST /bills. Deliberately has no bill id, no organizationId
 * write path, and no side effects -- there is no way for this hook to
 * submit or create a bill on its own.
 */
export interface BillOcrPort {
  proposeFields(billPhotoUrl: string): Promise<ProposedBillFields>;
}

export const BILL_OCR_PORT = Symbol("BILL_OCR_PORT");

/**
 * Placeholder OCR engine. Every consumer depends only on BillOcrPort (via
 * BILL_OCR_PORT), so a real OCR integration can be swapped in later by
 * rebinding this token -- no caller code needs to change.
 */
@Injectable()
export class StubBillOcrPort implements BillOcrPort {
  async proposeFields(_billPhotoUrl: string): Promise<ProposedBillFields> {
    return {};
  }
}
