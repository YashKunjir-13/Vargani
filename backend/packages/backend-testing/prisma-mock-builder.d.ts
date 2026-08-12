export interface MockModelDelegate<T = any> {
    create: jest.Mock;
    findUnique: jest.Mock;
    findFirst: jest.Mock;
    findMany: jest.Mock;
    findUniqueOrThrow: jest.Mock;
    update: jest.Mock;
    updateMany: jest.Mock;
    delete: jest.Mock;
    deleteMany: jest.Mock;
    count: jest.Mock;
    upsert: jest.Mock;
    __store: Map<string, T>;
}
export interface MockPrisma {
    $transaction: jest.Mock;
    $connect: jest.Mock;
    $disconnect: jest.Mock;
    $executeRaw: jest.Mock;
    $queryRaw: jest.Mock;
    __reset: () => void;
    [model: string]: any;
}
export declare function createMockPrisma(modelNames: string[]): MockPrisma;
