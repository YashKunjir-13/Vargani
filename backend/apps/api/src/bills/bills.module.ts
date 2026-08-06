import { Module } from "@nestjs/common";
import { FestivalYearModule } from "../common/festival-year/festival-year.module";
import { SequenceModule } from "../common/sequence/sequence.module";
import { TenancyModule } from "../common/tenancy/tenancy.module";
import { BILL_OCR_PORT, StubBillOcrPort } from "./bill-ocr.port";
import { BillsController } from "./bills.controller";
import { BillsService } from "./bills.service";
import { LEDGER_PORT, NoopLedgerPort } from "./ledger.port";

@Module({
  imports: [TenancyModule, FestivalYearModule, SequenceModule],
  controllers: [BillsController],
  providers: [
    BillsService,
    { provide: LEDGER_PORT, useClass: NoopLedgerPort },
    { provide: BILL_OCR_PORT, useClass: StubBillOcrPort },
  ],
  exports: [BillsService],
})
export class BillsModule {}
