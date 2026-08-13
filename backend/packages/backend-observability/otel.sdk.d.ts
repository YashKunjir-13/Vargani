import { NodeSDK } from "@opentelemetry/sdk-node";
export declare function initializeObservability(serviceName?: string): NodeSDK | null;
export declare const PrismaInstrumentationExtension: {
    name: string;
    description: string;
};
export declare const RedisInstrumentationExtension: {
    name: string;
    description: string;
};
export declare const QueueInstrumentationExtension: {
    name: string;
    description: string;
};
