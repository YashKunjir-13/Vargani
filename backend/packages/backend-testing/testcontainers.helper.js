"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.IntegrationTestEnvironment = void 0;
const postgresql_1 = require("@testcontainers/postgresql");
const redis_1 = require("@testcontainers/redis");
class IntegrationTestEnvironment {
    pgContainer;
    redisContainer;
    async startPostgres() {
        this.pgContainer = await new postgresql_1.PostgreSqlContainer("postgres:16-alpine")
            .withDatabase("pauti_pustak_test")
            .withUsername("test_user")
            .withPassword("test_password")
            .start();
        const connectionUri = this.pgContainer.getConnectionUri();
        process.env.DATABASE_URL = connectionUri;
        return connectionUri;
    }
    async startRedis() {
        this.redisContainer = await new redis_1.RedisContainer("redis:7-alpine").start();
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
exports.IntegrationTestEnvironment = IntegrationTestEnvironment;
//# sourceMappingURL=testcontainers.helper.js.map