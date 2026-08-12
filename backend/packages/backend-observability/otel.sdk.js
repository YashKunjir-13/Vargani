"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.QueueInstrumentationExtension = exports.RedisInstrumentationExtension = exports.PrismaInstrumentationExtension = void 0;
exports.initializeObservability = initializeObservability;
const exporter_metrics_otlp_http_1 = require("@opentelemetry/exporter-metrics-otlp-http");
const exporter_trace_otlp_http_1 = require("@opentelemetry/exporter-trace-otlp-http");
const resources_1 = require("@opentelemetry/resources");
const sdk_metrics_1 = require("@opentelemetry/sdk-metrics");
const sdk_node_1 = require("@opentelemetry/sdk-node");
const semantic_conventions_1 = require("@opentelemetry/semantic-conventions");
function initializeObservability(serviceName = "pauti-pustak-service") {
    if (process.env.NODE_ENV === "test") {
        return null;
    }
    const traceExporter = new exporter_trace_otlp_http_1.OTLPTraceExporter({
        url: `${process.env.OTEL_EXPORTER_OTLP_ENDPOINT || "http://localhost:4318"}/v1/traces`,
    });
    const metricExporter = new exporter_metrics_otlp_http_1.OTLPMetricExporter({
        url: `${process.env.OTEL_EXPORTER_OTLP_ENDPOINT || "http://localhost:4318"}/v1/metrics`,
    });
    const sdk = new sdk_node_1.NodeSDK({
        resource: new resources_1.Resource({
            [semantic_conventions_1.ATTR_SERVICE_NAME]: serviceName,
            [semantic_conventions_1.ATTR_SERVICE_VERSION]: "1.0.0",
            environment: process.env.NODE_ENV || "development",
        }),
        traceExporter,
        metricReader: new sdk_metrics_1.PeriodicExportingMetricReader({
            exporter: metricExporter,
            exportIntervalMillis: 15000,
        }),
    });
    try {
        sdk.start();
        console.log(`[OTel] Observability SDK initialized for ${serviceName}`);
    }
    catch (error) {
        console.warn("[OTel] Failed to initialize telemetry SDK:", error);
    }
    return sdk;
}
exports.PrismaInstrumentationExtension = {
    name: "prisma-instrumentation-extension",
    description: "Hook for registering Prisma telemetry extensions",
};
exports.RedisInstrumentationExtension = {
    name: "redis-instrumentation-extension",
    description: "Hook for registering Redis telemetry extensions",
};
exports.QueueInstrumentationExtension = {
    name: "queue-instrumentation-extension",
    description: "Hook for registering BullMQ telemetry extensions",
};
//# sourceMappingURL=otel.sdk.js.map