// eslint-disable-next-line @typescript-eslint/no-var-requires
const dotenv = require("dotenv");
dotenv.config({ path: "../../.env" });
dotenv.config({ path: ".env" });
dotenv.config({ path: ".env.local" });

import { ValidationPipe, VersioningType } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import { AppLoggerService, initializeObservability } from "@pauti-pustak/backend-observability";
import compression from "compression";
import cookieParser from "cookie-parser";
import helmet from "helmet";
import { AppModule } from "./app.module";
import { AllExceptionsFilter } from "./common/all-exceptions.filter";

async function bootstrap() {
  initializeObservability("pauti-pustak-api");

  const app = await NestFactory.create(AppModule, {
    bufferLogs: true,
    // Required for Razorpay webhook signature verification, which must be
    // computed over the exact raw request bytes -- see
    // src/payments/razorpay-signature.verifier.ts.
    rawBody: true,
  });

  const logger = new AppLoggerService();
  app.useLogger(logger);

  // Security & Middleware
  app.use(helmet());
  app.use(cookieParser());
  app.use(compression());

  app.enableCors({
    origin: process.env.CORS_ORIGINS ? process.env.CORS_ORIGINS.split(",") : "*",
    credentials: true,
  });

  // Global Prefix & Versioning
  app.setGlobalPrefix("api");
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: "1",
  });

  // Global Exception Filter
  app.useGlobalFilters(new AllExceptionsFilter());

  // Validation Pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Swagger Documentation (Development & Staging only)
  const nodeEnv = process.env.NODE_ENV || "development";
  if (["development", "staging"].includes(nodeEnv)) {
    try {
      const swaggerConfig = new DocumentBuilder()
        .setTitle("Pauti Pustak API")
        .setDescription("Enterprise Multi-tenant Event Financial-Management Platform API")
        .setVersion("1.0.0")
        .addBearerAuth()
        .addApiKey({ type: "apiKey", name: "x-tenant-id", in: "header" }, "x-tenant-id")
        .build();

      const document = SwaggerModule.createDocument(app, swaggerConfig);
      SwaggerModule.setup("api/v1/docs", app, document);
      logger.log(`Swagger UI initialized at /api/v1/docs`, "Bootstrap");
    } catch (err) {
      logger.warn(`Swagger UI initialization skipped due to metadata reflection: ${err}`, "Bootstrap");
    }
  }

  const port = process.env.PORT || 3000;
  await app.listen(port);
  logger.log(`API Gateway running on port ${port} in ${nodeEnv} mode`, "Bootstrap");
}

bootstrap();
