import { NestFactory } from "@nestjs/core";
import { AppLoggerService, initializeObservability } from "@pauti-pustak/backend-observability";
import { SchedulerModule } from "./scheduler.module";

async function bootstrap() {
  initializeObservability("pauti-pustak-scheduler");

  const app = await NestFactory.createApplicationContext(SchedulerModule);
  const logger = new AppLoggerService();

  logger.log("CRON Scheduler service initialized", "Bootstrap");

  process.on("SIGTERM", async () => {
    logger.log("Scheduler shutting down gracefully...", "Shutdown");
    await app.close();
    process.exit(0);
  });
}

bootstrap();
