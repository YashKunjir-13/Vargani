import { EnvironmentSchema } from '@pauti-pustak/backend-config';

describe('OpenApiAndConfigSmokeTest', () => {
  it('should validate default environment values', () => {
    const defaultEnv = EnvironmentSchema.parse({
      DATABASE_URL: 'postgresql://user:pass@localhost:5432/db',
      REDIS_URL: 'redis://localhost:6379',
      S3_ENDPOINT: 'http://localhost:9000',
      S3_ACCESS_KEY: 'key',
      S3_SECRET_KEY: 'secret',
    });

    expect(defaultEnv.PORT).toBe(3000);
    expect(defaultEnv.API_PREFIX).toBe('/api/v1');
    expect(defaultEnv.S3_BUCKET).toBe('pauti-pustak-assets');
  });
});
