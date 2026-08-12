export declare class IntegrationTestEnvironment {
    private pgContainer?;
    private redisContainer?;
    startPostgres(): Promise<string>;
    startRedis(): Promise<string>;
    stopAll(): Promise<void>;
}
