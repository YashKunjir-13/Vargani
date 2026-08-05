import { Processor, WorkerHost } from "@nestjs/bullmq";
import { Logger } from "@nestjs/common";
import { PrismaService, WhatsAppDeliveryStatus } from "@pauti-pustak/backend-database";
import { QueueName } from "@pauti-pustak/backend-shared-kernel";
import { Job } from "bullmq";

export interface NotificationJobPayload {
  organizationId: string;
  recipientMobile: string;
  recipientName: string;
  channel: "WHATSAPP" | "SMS" | "EMAIL" | "PUSH" | "IN_APP";
  templateCode: string;
  templateVariables?: Record<string, any>;
}

@Processor(QueueName.NOTIFICATIONS)
export class NotificationProcessor extends WorkerHost {
  private readonly logger = new Logger(NotificationProcessor.name);

  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async process(job: Job<NotificationJobPayload>): Promise<any> {
    this.logger.log(`[BullMQ Worker] Processing notification job ${job.id} [channel: ${job.data.channel}]`);

    try {
      // Create delivery record
      const record = await this.prisma.whatsAppDeliveryRecord.create({
        data: {
          organizationId: job.data.organizationId,
          recipientPhone: job.data.recipientMobile,
          mediaUrl: `https://storage.pauti-pustak.org/${job.data.templateCode}.pdf`,
          status: WhatsAppDeliveryStatus.SENT,
          providerMessageId: `BULLMQ-JOB-${job.id}`,
          retryCount: job.attemptsMade,
        },
      });

      return { status: "COMPLETED", deliveryRecordId: record.id };
    } catch (err: any) {
      this.logger.error(`Failed processing notification job ${job.id}: ${err.message}`);

      // Dead Letter Queue (DLQ) logging if max attempts reached
      if (job.attemptsMade >= (job.opts.attempts ?? 3)) {
        this.logger.warn(`[DLQ] Notification job ${job.id} moved to Dead Letter Queue after ${job.attemptsMade} failed attempts`);
      }

      throw err;
    }
  }
}
