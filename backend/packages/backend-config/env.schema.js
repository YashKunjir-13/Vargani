"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.EnvironmentSchema = void 0;
exports.validateEnvironment = validateEnvironment;
const zod_1 = require("zod");
exports.EnvironmentSchema = zod_1.z.object({
    NODE_ENV: zod_1.z.enum(["development", "production", "test", "staging"]).default("development"),
    PORT: zod_1.z.coerce.number().default(3000),
    API_PREFIX: zod_1.z.string().default("/api/v1"),
    DATABASE_URL: zod_1.z.string().url(),
    REDIS_URL: zod_1.z.string().url(),
    NATS_URL: zod_1.z.string().optional(),
    JWT_PRIVATE_KEY_PATH: zod_1.z.string().default("./config/certs/jwt_private.key"),
    JWT_PUBLIC_KEY_PATH: zod_1.z.string().default("./config/certs/jwt_public.key"),
    JWT_ACCESS_EXPIRATION: zod_1.z.string().default("15m"),
    JWT_REFRESH_EXPIRATION: zod_1.z.string().default("7d"),
    S3_ENDPOINT: zod_1.z.string().url(),
    S3_REGION: zod_1.z.string().default("us-east-1"),
    S3_BUCKET: zod_1.z.string().default("pauti-pustak-assets"),
    S3_ACCESS_KEY: zod_1.z.string(),
    S3_SECRET_KEY: zod_1.z.string(),
    S3_FORCE_PATH_STYLE: zod_1.z.coerce.boolean().default(true),
    RAZORPAY_KEY_ID: zod_1.z.string().min(1, "RAZORPAY_KEY_ID is required to accept InApp payments"),
    RAZORPAY_KEY_SECRET: zod_1.z.string().min(1, "RAZORPAY_KEY_SECRET is required to accept InApp payments"),
    RAZORPAY_WEBHOOK_SECRET: zod_1.z.string().min(1, "RAZORPAY_WEBHOOK_SECRET is required to verify Razorpay webhooks"),
    FIREBASE_PROJECT_ID: zod_1.z.string().optional(),
    WHATSAPP_API_URL: zod_1.z.string().url().optional(),
    WHATSAPP_API_TOKEN: zod_1.z.string().optional(),
    WHATSAPP_SENDER_NUMBER: zod_1.z.string().optional(),
    SMTP_HOST: zod_1.z.string().default("localhost"),
    SMTP_PORT: zod_1.z.coerce.number().default(1025),
    SMTP_USER: zod_1.z.string().optional(),
    SMTP_PASSWORD: zod_1.z.string().optional(),
    EMAIL_FROM: zod_1.z.string().email().default("no-reply@pautipustak.local"),
    OTEL_EXPORTER_OTLP_ENDPOINT: zod_1.z.string().url().default("http://localhost:4318"),
    OTEL_SERVICE_NAME: zod_1.z.string().default("pauti-pustak-backend"),
    PAN_ENCRYPTION_KEY: zod_1.z.string(),
});
function validateEnvironment(env = process.env) {
    const result = exports.EnvironmentSchema.safeParse(env);
    if (!result.success) {
        console.error("Invalid environment variables:", result.error.format());
        throw new Error("Environment validation failed");
    }
    return result.data;
}
//# sourceMappingURL=env.schema.js.map