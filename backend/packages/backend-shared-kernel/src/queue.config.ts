import { JobsOptions, QueueOptions } from "bullmq";

export enum QueueName {
  BILL_PDF = "bill-pdf",
  RECEIPT_PDF = "receipt-pdf",
  BULK_BILLING = "bulk-billing",
  NOTIFICATIONS = "notifications",
  REPORT_EXPORT = "report-export",
  PAYMENT_RECONCILIATION = "payment-reconciliation",
  WEBHOOK_PROCESSING = "webhook-processing",
  DOCUMENT_PROCESSING = "document-processing",
  DATA_IMPORT = "data-import",
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

export const DEFAULT_JOB_OPTIONS: JobsOptions = {
  attempts: 5,
  backoff: {
    type: "exponential",
    delay: 2000,
  },
  removeOnComplete: {
    age: 86400, // keep completed jobs for 24 hours
    count: 1000,
  },
  removeOnFail: {
    age: 604800, // keep failed dead-letter jobs for 7 days
  },
};

export const DEAD_LETTER_QUEUE_SUFFIX = "-dlq";

export function getQueueConfig(redisUrl: string): QueueOptions {
  const url = new URL(redisUrl);
  return {
    connection: {
      host: url.hostname,
      port: Number(url.port) || 6379,
      password: url.password || undefined,
    },
    defaultJobOptions: DEFAULT_JOB_OPTIONS,
  };
}
