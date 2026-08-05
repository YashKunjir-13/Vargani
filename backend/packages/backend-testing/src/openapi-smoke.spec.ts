import { EnvironmentSchema } from '@pauti-pustak/backend-config';

describe('OpenApiAndConfigSmokeTest', () => {
  it('should validate default environment values', () => {
    const defaultEnv = EnvironmentSchema.parse({
      DATABASE_URL: 'postgresql://user:pass@localhost:5432/db',
      REDIS_URL: 'redis://localhost:6379',
      S3_ENDPOINT: 'http://localhost:9000',
      S3_ACCESS_KEY: 'key',
      S3_SECRET_KEY: 'secret',
      RAZORPAY_KEY_ID: 'rzp_test_123',
      RAZORPAY_KEY_SECRET: 'secret',
      RAZORPAY_WEBHOOK_SECRET: 'webhook_secret',
      PAN_ENCRYPTION_KEY: 'test-key-32-chars-long-000000000',
    });

    expect(defaultEnv.PORT).toBe(3000);
    expect(defaultEnv.API_PREFIX).toBe('/api/v1');
    expect(defaultEnv.S3_BUCKET).toBe('pauti-pustak-assets');
  });
});
