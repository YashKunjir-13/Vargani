import { BullModule } from "@nestjs/bullmq";
import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { PrismaModule } from "@pauti-pustak/backend-database";
import { QueueName } from "@pauti-pustak/backend-shared-kernel";
import { BillPdfProcessor, ReceiptPdfProcessor } from "./processors/pdf.processor";

const redisHost = process.env.REDIS_HOST || "localhost";
const redisPort = Number(process.env.REDIS_PORT) || 6379;

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [".env.local", ".env"],
    }),
    BullModule.forRoot({
      connection: {
        host: redisHost,
        port: redisPort,
      },
    }),
    BullModule.registerQueue(
      { name: QueueName.BILL_PDF },
      { name: QueueName.RECEIPT_PDF },
      { name: QueueName.NOTIFICATIONS },
      { name: QueueName.PAYMENT_RECONCILIATION },
    ),
    PrismaModule,
  ],
  providers: [BillPdfProcessor, ReceiptPdfProcessor],
})
export class WorkerModule {}
