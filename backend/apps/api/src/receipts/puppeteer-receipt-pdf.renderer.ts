import { Injectable, InternalServerErrorException } from "@nestjs/common";
import * as puppeteer from "puppeteer";
import { ReceiptPdfRenderer, RenderReceiptParams } from "./receipt-pdf.renderer";

@Injectable()
export class PuppeteerReceiptPdfRenderer implements ReceiptPdfRenderer {
  async render(params: RenderReceiptParams): Promise<Buffer> {
    const donorName = params.donorNameSnapshot;
    const receiptNumber = params.receiptNumber;
    const mandalName = params.mandalNameSnapshot;
    const amount = (params.amountSnapshot).toFixed(2);
    const date = params.issuedDate.toLocaleDateString();

    const htmlContent = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Receipt ${receiptNumber}</title>
        <style>
          body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding: 40px; color: #333; }
          .header { text-align: center; border-bottom: 2px solid #333; padding-bottom: 20px; margin-bottom: 30px; }
          .mandal-name { font-size: 28px; font-weight: bold; margin: 0; }
          .receipt-title { font-size: 20px; margin: 10px 0 0 0; color: #666; }
          .content { margin-top: 20px; }
          .row { display: flex; justify-content: space-between; margin-bottom: 15px; border-bottom: 1px solid #eee; padding-bottom: 5px; }
          .label { font-weight: bold; width: 40%; }
          .value { width: 60%; text-align: right; }
          .amount-box { margin-top: 30px; padding: 15px; background: #f9f9f9; text-align: center; font-size: 24px; font-weight: bold; border: 1px solid #ddd; }
          .footer { margin-top: 50px; display: flex; justify-content: space-between; }
          .signature-box { text-align: center; width: 200px; }
          .signature-box img { max-width: 150px; max-height: 80px; }
          .stamp-box img { max-width: 100px; max-height: 100px; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1 class="mandal-name">${mandalName}</h1>
          <h2 class="receipt-title">DONATION RECEIPT</h2>
        </div>
        
        <div class="content">
          <div class="row"><div class="label">Receipt Number</div><div class="value">${receiptNumber}</div></div>
          <div class="row"><div class="label">Date</div><div class="value">${date}</div></div>
          <div class="row"><div class="label">Donor Name</div><div class="value">${donorName}</div></div>
        </div>

        <div class="amount-box">
          Amount Received: ₹${amount}
        </div>

        <div class="footer">
          <div class="stamp-box">
            ${params.stampAssetUrl ? `<img src="${params.stampAssetUrl}" alt="Stamp" />` : ''}
          </div>
          <div class="signature-box">
            ${params.signatureAssetUrl ? `<img src="${params.signatureAssetUrl}" alt="Signature" />` : ''}
            <div style="border-top: 1px solid #333; margin-top: 10px; padding-top: 5px;">Authorized Signatory</div>
          </div>
        </div>
      </body>
      </html>
    `;

    const browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
    });

    try {
      const page = await browser.newPage();
      await page.setContent(htmlContent, { waitUntil: 'domcontentloaded' });
      
      const rawPdf = await page.pdf({
        format: 'A4',
        printBackground: true,
        margin: { top: '20px', right: '20px', bottom: '20px', left: '20px' }
      });

      const pdfBuffer = Buffer.from(rawPdf);

      // Temporary backend validation requested by user
      console.log('PDF size:', pdfBuffer.length);
      console.log('PDF header:', pdfBuffer.subarray(0, 8).toString('ascii'));

      if (!pdfBuffer.subarray(0, 5).toString('ascii').startsWith('%PDF-')) {
          throw new InternalServerErrorException(
            'PDF generator returned invalid PDF bytes'
          );
      }

      return pdfBuffer;
    } finally {
      await browser.close();
    }
  }
}
