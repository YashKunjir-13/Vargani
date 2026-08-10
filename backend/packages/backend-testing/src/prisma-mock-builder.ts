/**
 * @module prisma-mock-builder
 * @description Unified in-memory Prisma mock with Map-based storage.
 *
 * Provides a reusable, model-agnostic Prisma mock that eliminates the need
 * for each spec file to build its own `buildPrismaMock()`. Supports:
 *
 * - In-memory Map storage per model (create, findUnique, findMany, update, delete, count, upsert)
 * - $transaction support (callback & sequential)
 * - jest.fn() wrapping for assertion/spy capability
 * - afterEach-compatible reset for test isolation (no state leaks between tests)
 *
 * Usage:
 *   const prisma = createMockPrisma(['bill', 'payment', 'paymentReceipt']);
 *   // Each model gets full CRUD mocks backed by a shared Map.
 *   // Call prisma.__reset() to clear all state between tests.
 */

/** Shape of a single model's in-memory mock. */
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
  /** Direct access to the backing Map — useful for assertions. */
  __store: Map<string, T>;
}

export interface MockPrisma {
  $transaction: jest.Mock;
  $connect: jest.Mock;
  $disconnect: jest.Mock;
  $executeRaw: jest.Mock;
  $queryRaw: jest.Mock;
  /** Clears all model stores and resets all jest.fn() call counters. */
  __reset: () => void;
  /** Access any model delegate by name. */
  [model: string]: any;
}

/**
 * Creates a filter predicate from a Prisma `where` clause.
 * Handles simple equality, nested `in`, `gte`, `lte`, `contains`, `not` operators.
 */
function matchesWhere(row: any, where: Record<string, any>): boolean {
  if (!where) return true;
  for (const [key, condition] of Object.entries(where)) {
    if (condition === undefined) continue;
    const rowValue = row[key];

    // Primitive equality
    if (condition === null || typeof condition !== "object") {
      if (rowValue !== condition) return false;
      continue;
    }

    // Operator-based conditions
    if ("in" in condition) {
      if (!condition.in.includes(rowValue)) return false;
    }
    if ("gte" in condition) {
      if (rowValue < condition.gte) return false;
    }
    if ("lte" in condition) {
      if (rowValue > condition.lte) return false;
    }
    if ("contains" in condition) {
      if (typeof rowValue !== "string" || !rowValue.includes(condition.contains)) return false;
    }
    if ("not" in condition) {
      if (rowValue === condition.not) return false;
    }
    if ("equals" in condition) {
      if (rowValue !== condition.equals) return false;
    }
  }
  return true;
}

/** Internal per-model counter for generating unique IDs. */
const modelCounters = new Map<string, number>();

/**
 * Builds a fully mocked Prisma model delegate backed by an in-memory Map.
 *
 * @param modelName - Used for generating unique IDs (e.g., "bill" → "bill-1", "bill-2")
 */
function buildModelMock(modelName: string): MockModelDelegate {
  const store = new Map<string, any>();
  modelCounters.set(modelName, 0);

  const getNextId = (): string => {
    const current = (modelCounters.get(modelName) ?? 0) + 1;
    modelCounters.set(modelName, current);
    return `${modelName}-${current}`;
  };

  return {
    __store: store,

    create: jest.fn(({ data }: { data: any }) => {
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

    findUnique: jest.fn(({ where }: { where: any }) => {
      if (where.id) return Promise.resolve(store.get(where.id) ?? null);
      // Search by first non-id unique field
      for (const [key, value] of Object.entries(where)) {
        if (key === "id") continue;
        const found = [...store.values()].find((row) => row[key] === value);
        if (found) return Promise.resolve({ ...found });
      }
      return Promise.resolve(null);
    }),

    findFirst: jest.fn(({ where }: { where?: any } = {}) => {
      if (!where) {
        const first = [...store.values()][0];
        return Promise.resolve(first ? { ...first } : null);
      }
      const found = [...store.values()].find((row) => matchesWhere(row, where));
      return Promise.resolve(found ? { ...found } : null);
    }),

    findUniqueOrThrow: jest.fn(({ where }: { where: any }) => {
      const row = store.get(where.id);
      if (!row) return Promise.reject(new Error(`Record not found: ${where.id}`));
      return Promise.resolve({ ...row });
    }),

    findMany: jest.fn(({ where, orderBy }: { where?: any; orderBy?: any } = {}) => {
      let results = [...store.values()];
      if (where) {
        results = results.filter((row) => matchesWhere(row, where));
      }
      // Basic orderBy support (single field)
      if (orderBy && typeof orderBy === "object") {
        const [field, direction] = Object.entries(orderBy)[0] ?? [];
        if (field) {
          results.sort((a, b) => {
            const av = a[field];
            const bv = b[field];
            if (av < bv) return direction === "asc" ? -1 : 1;
            if (av > bv) return direction === "asc" ? 1 : -1;
            return 0;
          });
        }
      }
      return Promise.resolve(results.map((r) => ({ ...r })));
    }),

    update: jest.fn(({ where, data }: { where: any; data: any }) => {
      const existing = store.get(where.id) ?? { id: where.id, ...where };

      // Handle Prisma atomic operations (increment/decrement)
      const resolvedData: Record<string, any> = {};
      for (const [key, value] of Object.entries(data)) {
        if (value && typeof value === "object" && "increment" in (value as any)) {
          resolvedData[key] = (existing[key] ?? 0) + (value as any).increment;
        } else if (value && typeof value === "object" && "decrement" in (value as any)) {
          resolvedData[key] = (existing[key] ?? 0) - (value as any).decrement;
        } else {
          resolvedData[key] = value;
        }
      }

      const updated = { ...existing, ...resolvedData, updatedAt: new Date() };
      store.set(where.id, updated);
      return Promise.resolve({ ...updated });
    }),

    updateMany: jest.fn(({ where, data }: { where?: any; data: any }) => {
      let count = 0;
      for (const [id, row] of store.entries()) {
        if (!where || matchesWhere(row, where)) {
          store.set(id, { ...row, ...data, updatedAt: new Date() });
          count++;
        }
      }
      return Promise.resolve({ count });
    }),

    delete: jest.fn(({ where }: { where: any }) => {
      const row = store.get(where.id) ?? null;
      store.delete(where.id);
      return Promise.resolve(row);
    }),

    deleteMany: jest.fn(({ where }: { where?: any } = {}) => {
      let count = 0;
      for (const [id, row] of store.entries()) {
        if (!where || matchesWhere(row, where)) {
          store.delete(id);
          count++;
        }
      }
      return Promise.resolve({ count });
    }),

    count: jest.fn(({ where }: { where?: any } = {}) => {
      if (!where) return Promise.resolve(store.size);
      const matched = [...store.values()].filter((row) => matchesWhere(row, where));
      return Promise.resolve(matched.length);
    }),

    upsert: jest.fn(({ where, create, update }: { where: any; create: any; update: any }) => {
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

/**
 * Creates a fully-mocked PrismaClient with the specified model delegates.
 *
 * @param modelNames - Array of Prisma model names (camelCase, matching Prisma convention).
 *                     E.g., ['bill', 'payment', 'paymentReceipt', 'user', 'organization']
 *
 * @example
 * ```typescript
 * const prisma = createMockPrisma(['bill', 'billAuditEvent', 'payment']);
 *
 * // Each model has full CRUD:
 * await prisma.bill.create({ data: { ... } });
 * await prisma.bill.findUnique({ where: { id: 'bill-1' } });
 *
 * // Direct store access for assertions:
 * expect(prisma.bill.__store.size).toBe(1);
 *
 * // Reset between tests:
 * prisma.__reset();
 * ```
 */
export function createMockPrisma(modelNames: string[]): MockPrisma {
  const models: Record<string, MockModelDelegate> = {};
  for (const name of modelNames) {
    models[name] = buildModelMock(name);
  }

  const prisma: any = {
    ...models,

    $transaction: jest.fn(async (fnOrArray: any) => {
      // Callback-style transaction
      if (typeof fnOrArray === "function") {
        return fnOrArray(prisma);
      }
      // Sequential-style transaction (array of promises)
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
        // Reset all jest.fn() call histories
        for (const key of Object.keys(models[name])) {
          if (key !== "__store" && typeof (models[name] as any)[key]?.mockClear === "function") {
            (models[name] as any)[key].mockClear();
          }
        }
      }
      // Reset counters
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

  return prisma as MockPrisma;
}
