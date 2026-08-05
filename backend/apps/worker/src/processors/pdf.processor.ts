import { Processor, WorkerHost } from "@nestjs/bullmq";
import { QueueName } from "@pauti-pustak/backend-shared-kernel";
import { Job } from "bullmq";

@Processor(QueueName.BILL_PDF)
export class BillPdfProcessor extends WorkerHost {
  async process(job: Job<any, any, string>): Promise<any> {
    console.log(`[BillPdfProcessor] Processing job ${job.id} for key ${job.data.idempotencyKey}`);
    return { status: "completed", pdfKey: `bills/pdf_${job.id}.pdf` };
  }
}

@Processor(QueueName.RECEIPT_PDF)
export class ReceiptPdfProcessor extends WorkerHost {
  async process(job: Job<any, any, string>): Promise<any> {
    console.log(
      `[ReceiptPdfProcessor] Processing job ${job.id} for key ${job.data.idempotencyKey}`,
    );
    return { status: "completed", pdfKey: `receipts/pdf_${job.id}.pdf` };
  }
}
