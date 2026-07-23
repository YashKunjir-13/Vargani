import { PostgreSqlContainer, StartedPostgreSqlContainer } from "@testcontainers/postgresql";
import { RedisContainer, StartedRedisContainer } from "@testcontainers/redis";

export class IntegrationTestEnvironment {
  private pgContainer?: StartedPostgreSqlContainer;
  private redisContainer?: StartedRedisContainer;

  async startPostgres() {
    this.pgContainer = await new PostgreSqlContainer("postgres:16-alpine")
      .withDatabase("pauti_pustak_test")
      .withUsername("test_user")
      .withPassword("test_password")
      .start();

    const connectionUri = this.pgContainer.getConnectionUri();
    process.env.DATABASE_URL = connectionUri;
    return connectionUri;
  }

  async startRedis() {
    this.redisContainer = await new RedisContainer("redis:7-alpine").start();
    const redisUrl = `redis://${this.redisContainer.getHost()}:${this.redisContainer.getPort()}`;
    process.env.REDIS_URL = redisUrl;
    return redisUrl;
  }

  async stopAll() {
    if (this.pgContainer) {
      await this.pgContainer.stop();
    }
    if (this.redisContainer) {
      await this.redisContainer.stop();
    }
  }
}
