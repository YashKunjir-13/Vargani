import { z } from "zod";

export const EnvironmentSchema = z.object({
  NODE_ENV: z.enum(["development", "production", "test", "staging"]).default("development"),
  PORT: z.coerce.number().default(3000),
  API_PREFIX: z.string().default("/api/v1"),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
  NATS_URL: z.string().optional(),
  JWT_PRIVATE_KEY_PATH: z.string().default("./config/certs/jwt_private.key"),
  JWT_PUBLIC_KEY_PATH: z.string().default("./config/certs/jwt_public.key"),
  JWT_ACCESS_EXPIRATION: z.string().default("15m"),
  JWT_REFRESH_EXPIRATION: z.string().default("7d"),
  S3_ENDPOINT: z.string().url(),
  S3_REGION: z.string().default("us-east-1"),
  S3_BUCKET: z.string().default("pauti-pustak-assets"),
  S3_ACCESS_KEY: z.string(),
  S3_SECRET_KEY: z.string(),
  S3_FORCE_PATH_STYLE: z.coerce.boolean().default(true),
  RAZORPAY_KEY_ID: z.string().optional(),
  RAZORPAY_KEY_SECRET: z.string().optional(),
  FIREBASE_PROJECT_ID: z.string().optional(),
  WHATSAPP_API_URL: z.string().url().optional(),
  WHATSAPP_API_TOKEN: z.string().optional(),
  WHATSAPP_SENDER_NUMBER: z.string().optional(),
  SMTP_HOST: z.string().default("localhost"),
  SMTP_PORT: z.coerce.number().default(1025),
  SMTP_USER: z.string().optional(),
  SMTP_PASSWORD: z.string().optional(),
  EMAIL_FROM: z.string().email().default("no-reply@pautipustak.local"),
  OTEL_EXPORTER_OTLP_ENDPOINT: z.string().url().default("http://localhost:4318"),
  OTEL_SERVICE_NAME: z.string().default("pauti-pustak-backend"),
});

export type AppEnvironment = z.infer<typeof EnvironmentSchema>;

export function validateEnvironment(env: Record<string, unknown> = process.env): AppEnvironment {
  const result = EnvironmentSchema.safeParse(env);
  if (!result.success) {
    console.error("Invalid environment variables:", result.error.format());
    throw new Error("Environment validation failed");
  }
  return result.data;
}
