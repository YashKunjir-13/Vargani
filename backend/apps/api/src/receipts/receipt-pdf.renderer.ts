import { Injectable } from "@nestjs/common";

export interface RenderReceiptParams {
  organizationId: string;
  receiptNumber: string;
  donorNameSnapshot: string;
  amountSnapshot: number;
  issuedDate: Date;
  mandalNameSnapshot: string;
  stampAssetUrl: string | null;
  signatureAssetUrl: string | null;
  /** Null when the mandal has never activated a personalized receipt template -- render the system default layout. */
  templateSourceFileUrl: string | null;
}

export interface ReceiptPdfRenderer {
  render(params: RenderReceiptParams): Promise<Buffer>;
}

export const RECEIPT_PDF_RENDERER = Symbol("RECEIPT_PDF_RENDERER");

/**
 * Placeholder for the real Handlebars+Puppeteer rendering pipeline (both
 * already in package.json for this purpose): every caller depends only on
 * ReceiptPdfRenderer (via RECEIPT_PDF_RENDERER), so a real implementation
 * can be bound later with no caller changes. Produces deterministic,
 * inspectable bytes rather than a real PDF so unit tests never need a
 * headless browser.
 */
@Injectable()
export class StubReceiptPdfRenderer implements ReceiptPdfRenderer {
  async render(params: RenderReceiptParams): Promise<Buffer> {
    const lines = [
      "%STUB-RECEIPT-PDF",
      `receiptNumber=${params.receiptNumber}`,
      `mandalName=${params.mandalNameSnapshot}`,
      `donorName=${params.donorNameSnapshot}`,
      `amount=${params.amountSnapshot}`,
      `issuedDate=${params.issuedDate.toISOString()}`,
      `template=${params.templateSourceFileUrl ?? "system-default"}`,
    ];
    return Buffer.from(lines.join("\n"), "utf-8");
  }
}
