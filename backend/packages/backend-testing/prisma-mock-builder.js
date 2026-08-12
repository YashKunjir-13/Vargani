"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createMockPrisma = createMockPrisma;
function matchesWhere(row, where) {
    if (!where)
        return true;
    for (const [key, condition] of Object.entries(where)) {
        if (condition === undefined)
            continue;
        const rowValue = row[key];
        if (condition === null || typeof condition !== "object") {
            if (rowValue !== condition)
                return false;
            continue;
        }
        if ("in" in condition) {
            if (!condition.in.includes(rowValue))
                return false;
        }
        if ("gte" in condition) {
            if (rowValue < condition.gte)
                return false;
        }
        if ("lte" in condition) {
            if (rowValue > condition.lte)
                return false;
        }
        if ("contains" in condition) {
            if (typeof rowValue !== "string" || !rowValue.includes(condition.contains))
                return false;
        }
        if ("not" in condition) {
            if (rowValue === condition.not)
                return false;
        }
        if ("equals" in condition) {
            if (rowValue !== condition.equals)
                return false;
        }
    }
    return true;
}
const modelCounters = new Map();
function buildModelMock(modelName) {
    const store = new Map();
    modelCounters.set(modelName, 0);
    const getNextId = () => {
        const current = (modelCounters.get(modelName) ?? 0) + 1;
        modelCounters.set(modelName, current);
        return `${modelName}-${current}`;
    };
    return {
        __store: store,
        create: jest.fn(({ data }) => {
            const id = data.id ?? getNextId();
            const row = {
                id,
                createdAt: new Date(),
                updatedAt: new Date(),
                ...data,
            };
            store.set(id, row);
            return Promise.resolve({ ...row });
        }),
        findUnique: jest.fn(({ where }) => {
            if (where.id)
                return Promise.resolve(store.get(where.id) ?? null);
            for (const [key, value] of Object.entries(where)) {
                if (key === "id")
                    continue;
                const found = [...store.values()].find((row) => row[key] === value);
                if (found)
                    return Promise.resolve({ ...found });
            }
            return Promise.resolve(null);
        }),
        findFirst: jest.fn(({ where } = {}) => {
            if (!where) {
                const first = [...store.values()][0];
                return Promise.resolve(first ? { ...first } : null);
            }
            const found = [...store.values()].find((row) => matchesWhere(row, where));
            return Promise.resolve(found ? { ...found } : null);
        }),
        findUniqueOrThrow: jest.fn(({ where }) => {
            const row = store.get(where.id);
            if (!row)
                return Promise.reject(new Error(`Record not found: ${where.id}`));
            return Promise.resolve({ ...row });
        }),
        findMany: jest.fn(({ where, orderBy } = {}) => {
            let results = [...store.values()];
            if (where) {
                results = results.filter((row) => matchesWhere(row, where));
            }
            if (orderBy && typeof orderBy === "object") {
                const [field, direction] = Object.entries(orderBy)[0] ?? [];
                if (field) {
                    results.sort((a, b) => {
                        const av = a[field];
                        const bv = b[field];
                        if (av < bv)
                            return direction === "asc" ? -1 : 1;
                        if (av > bv)
                            return direction === "asc" ? 1 : -1;
                        return 0;
                    });
                }
            }
            return Promise.resolve(results.map((r) => ({ ...r })));
        }),
        update: jest.fn(({ where, data }) => {
            const existing = store.get(where.id) ?? { id: where.id, ...where };
            const resolvedData = {};
            for (const [key, value] of Object.entries(data)) {
                if (value && typeof value === "object" && "increment" in value) {
                    resolvedData[key] = (existing[key] ?? 0) + value.increment;
                }
                else if (value && typeof value === "object" && "decrement" in value) {
                    resolvedData[key] = (existing[key] ?? 0) - value.decrement;
                }
                else {
                    resolvedData[key] = value;
                }
            }
            const updated = { ...existing, ...resolvedData, updatedAt: new Date() };
            store.set(where.id, updated);
            return Promise.resolve({ ...updated });
        }),
        updateMany: jest.fn(({ where, data }) => {
            let count = 0;
            for (const [id, row] of store.entries()) {
                if (!where || matchesWhere(row, where)) {
                    store.set(id, { ...row, ...data, updatedAt: new Date() });
                    count++;
                }
            }
            return Promise.resolve({ count });
        }),
        delete: jest.fn(({ where }) => {
            const row = store.get(where.id) ?? null;
            store.delete(where.id);
            return Promise.resolve(row);
        }),
        deleteMany: jest.fn(({ where } = {}) => {
            let count = 0;
            for (const [id, row] of store.entries()) {
                if (!where || matchesWhere(row, where)) {
                    store.delete(id);
                    count++;
                }
            }
            return Promise.resolve({ count });
        }),
        count: jest.fn(({ where } = {}) => {
            if (!where)
                return Promise.resolve(store.size);
            const matched = [...store.values()].filter((row) => matchesWhere(row, where));
            return Promise.resolve(matched.length);
        }),
        upsert: jest.fn(({ where, create, update }) => {
            const existing = store.get(where.id);
            if (existing) {
                const updated = { ...existing, ...update, updatedAt: new Date() };
                store.set(where.id, updated);
                return Promise.resolve({ ...updated });
            }
            const id = create.id ?? where.id ?? getNextId();
            const row = { id, createdAt: new Date(), updatedAt: new Date(), ...create };
            store.set(id, row);
            return Promise.resolve({ ...row });
        }),
    };
}
function createMockPrisma(modelNames) {
    const models = {};
    for (const name of modelNames) {
        models[name] = buildModelMock(name);
    }
    const prisma = {
        ...models,
        $transaction: jest.fn(async (fnOrArray) => {
            if (typeof fnOrArray === "function") {
                return fnOrArray(prisma);
            }
            if (Array.isArray(fnOrArray)) {
                return Promise.all(fnOrArray);
            }
            throw new Error("$transaction expects a function or array");
        }),
        $connect: jest.fn(() => Promise.resolve()),
        $disconnect: jest.fn(() => Promise.resolve()),
        $executeRaw: jest.fn(() => Promise.resolve(0)),
        $queryRaw: jest.fn(() => Promise.resolve([])),
        __reset: () => {
            for (const name of modelNames) {
                models[name].__store.clear();
                for (const key of Object.keys(models[name])) {
                    if (key !== "__store" && typeof models[name][key]?.mockClear === "function") {
                        models[name][key].mockClear();
                    }
                }
            }
            for (const name of modelNames) {
                modelCounters.set(name, 0);
            }
            prisma.$transaction.mockClear();
            prisma.$connect.mockClear();
            prisma.$disconnect.mockClear();
            prisma.$executeRaw.mockClear();
            prisma.$queryRaw.mockClear();
        },
    };
    return prisma;
}
//# sourceMappingURL=prisma-mock-builder.js.map