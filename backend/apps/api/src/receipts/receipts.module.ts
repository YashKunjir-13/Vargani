import { Module } from "@nestjs/common";
import { SequenceModule } from "../common/sequence/sequence.module";
import { StorageModule } from "../common/storage/storage.module";
import { TenancyModule } from "../common/tenancy/tenancy.module";
import { WhatsAppModule } from "../common/whatsapp/whatsapp.module";
import { TemplatesModule } from "../templates/templates.module";
import { RECEIPT_PDF_RENDERER } from "./receipt-pdf.renderer";
import { PuppeteerReceiptPdfRenderer } from "./puppeteer-receipt-pdf.renderer";
import { ReceiptsController } from "./receipts.controller";
import { ReceiptsService } from "./receipts.service";
import { PrismaModule } from "@pauti-pustak/backend-database";

@Module({
  imports: [TenancyModule, SequenceModule, StorageModule, WhatsAppModule, TemplatesModule, PrismaModule],
  controllers: [ReceiptsController],
  providers: [ReceiptsService, { provide: RECEIPT_PDF_RENDERER, useClass: PuppeteerReceiptPdfRenderer }],
  // Exported so PaymentsModule can bind RECEIPT_GENERATION_PORT to this concrete
  // implementation instead of the NoopReceiptGenerationPort placeholder.
  exports: [ReceiptsService],
})
export class ReceiptsModule {}
