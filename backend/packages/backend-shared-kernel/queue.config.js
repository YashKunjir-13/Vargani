"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEAD_LETTER_QUEUE_SUFFIX = exports.DEFAULT_JOB_OPTIONS = exports.QueueName = void 0;
exports.getQueueConfig = getQueueConfig;
var QueueName;
(function (QueueName) {
    QueueName["BILL_PDF"] = "bill-pdf";
    QueueName["RECEIPT_PDF"] = "receipt-pdf";
    QueueName["BULK_BILLING"] = "bulk-billing";
    QueueName["NOTIFICATIONS"] = "notifications";
    QueueName["REPORT_EXPORT"] = "report-export";
    QueueName["PAYMENT_RECONCILIATION"] = "payment-reconciliation";
    QueueName["WEBHOOK_PROCESSING"] = "webhook-processing";
    QueueName["DOCUMENT_PROCESSING"] = "document-processing";
    QueueName["DATA_IMPORT"] = "data-import";
})(QueueName || (exports.QueueName = QueueName = {}));
exports.DEFAULT_JOB_OPTIONS = {
    attempts: 5,
    backoff: {
        type: "exponential",
        delay: 2000,
    },
    removeOnComplete: {
        age: 86400,
        count: 1000,
    },
    removeOnFail: {
        age: 604800,
    },
};
exports.DEAD_LETTER_QUEUE_SUFFIX = "-dlq";
function getQueueConfig(redisUrl) {
    const url = new URL(redisUrl);
    return {
        connection: {
            host: url.hostname,
            port: Number(url.port) || 6379,
            password: url.password || undefined,
        },
        defaultJobOptions: exports.DEFAULT_JOB_OPTIONS,
    };
}
//# sourceMappingURL=queue.config.js.map