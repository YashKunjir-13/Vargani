import { JobsOptions, QueueOptions } from "bullmq";
export declare enum QueueName {
    BILL_PDF = "bill-pdf",
    RECEIPT_PDF = "receipt-pdf",
    BULK_BILLING = "bulk-billing",
    NOTIFICATIONS = "notifications",
    REPORT_EXPORT = "report-export",
    PAYMENT_RECONCILIATION = "payment-reconciliation",
    WEBHOOK_PROCESSING = "webhook-processing",
    DOCUMENT_PROCESSING = "document-processing",
    DATA_IMPORT = "data-import"
}
export interface StandardQueueJobPayload<T = Record<string, any>> {
    jobId: string;
    idempotencyKey: string;
    correlationId: string;
    organizationId: string;
    eventId?: string;
    payload: T;
    meta?: Record<string, any>;
}
export declare const DEFAULT_JOB_OPTIONS: JobsOptions;
export declare const DEAD_LETTER_QUEUE_SUFFIX = "-dlq";
export declare function getQueueConfig(redisUrl: string): QueueOptions;
