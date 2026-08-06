import { NestFactory } from "@nestjs/core";
import { AppLoggerService, initializeObservability } from "@pauti-pustak/backend-observability";
import { WorkerModule } from "./worker.module";

async function bootstrap() {
  initializeObservability("pauti-pustak-worker");

  const app = await NestFactory.createApplicationContext(WorkerModule);
  const logger = new AppLoggerService();

  logger.log("Background Worker service started and consuming BullMQ queues", "Bootstrap");

  process.on("SIGTERM", async () => {
    logger.log("Worker stopping gracefully...", "Shutdown");
    await app.close();
    process.exit(0);
  });
}

bootstrap();
