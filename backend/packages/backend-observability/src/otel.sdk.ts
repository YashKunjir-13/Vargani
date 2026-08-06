import { OTLPMetricExporter } from "@opentelemetry/exporter-metrics-otlp-http";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { Resource } from "@opentelemetry/resources";
import { PeriodicExportingMetricReader } from "@opentelemetry/sdk-metrics";
import { NodeSDK } from "@opentelemetry/sdk-node";
import { ATTR_SERVICE_NAME, ATTR_SERVICE_VERSION } from "@opentelemetry/semantic-conventions";

export function initializeObservability(serviceName = "pauti-pustak-service"): NodeSDK | null {
  if (process.env.NODE_ENV === "test") {
    // Disable external telemetry export in test environment
    return null;
  }

  const traceExporter = new OTLPTraceExporter({
    url: `${process.env.OTEL_EXPORTER_OTLP_ENDPOINT || "http://localhost:4318"}/v1/traces`,
  });

  const metricExporter = new OTLPMetricExporter({
    url: `${process.env.OTEL_EXPORTER_OTLP_ENDPOINT || "http://localhost:4318"}/v1/metrics`,
  });

  const sdk = new NodeSDK({
    resource: new Resource({
      [ATTR_SERVICE_NAME]: serviceName,
      [ATTR_SERVICE_VERSION]: "1.0.0",
      environment: process.env.NODE_ENV || "development",
    }),
    traceExporter,
    metricReader: new PeriodicExportingMetricReader({
      exporter: metricExporter,
      exportIntervalMillis: 15000,
    }),
  });

  try {
    sdk.start();
    console.log(`[OTel] Observability SDK initialized for ${serviceName}`);
  } catch (error) {
    console.warn("[OTel] Failed to initialize telemetry SDK:", error);
  }

  return sdk;
}

export const PrismaInstrumentationExtension = {
  name: "prisma-instrumentation-extension",
  description: "Hook for registering Prisma telemetry extensions",
};

export const RedisInstrumentationExtension = {
  name: "redis-instrumentation-extension",
  description: "Hook for registering Redis telemetry extensions",
};

export const QueueInstrumentationExtension = {
  name: "queue-instrumentation-extension",
  description: "Hook for registering BullMQ telemetry extensions",
};
