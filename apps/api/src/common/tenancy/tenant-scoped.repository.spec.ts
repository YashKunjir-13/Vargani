import { NotFoundException } from "@nestjs/common";
import { TenantScopedRepository } from "./tenant-scoped.repository";

const TENANT_ID = "org-real";

function buildDelegateMock() {
  const rows = new Map<string, any>([
    ["row-owned", { id: "row-owned", organizationId: TENANT_ID, name: "mine" }],
    ["row-other-tenant", { id: "row-other-tenant", organizationId: "org-other", name: "not mine" }],
  ]);

  return {
    findMany: jest.fn(({ where }: any) =>
      Promise.resolve([...rows.values()].filter((r) => r.organizationId === where.organizationId)),
    ),
    findFirst: jest.fn(({ where }: any) =>
      Promise.resolve([...rows.values()].find((r) => r.organizationId === where.organizationId) ?? null),
    ),
    findUnique: jest.fn(({ where }: any) => Promise.resolve(rows.get(where.id) ?? null)),
    create: jest.fn(({ data }: any) => {
      const row = { id: `row-${rows.size + 1}`, ...data };
      rows.set(row.id, row);
      return Promise.resolve(row);
    }),
    update: jest.fn(({ where, data }: any) => {
      const row = { ...rows.get(where.id), ...data };
      rows.set(where.id, row);
      return Promise.resolve(row);
    }),
    updateMany: jest.fn(() => Promise.resolve({ count: 0 })),
    delete: jest.fn(({ where }: any) => {
      rows.delete(where.id);
      return Promise.resolve(undefined);
    }),
    deleteMany: jest.fn(() => Promise.resolve({ count: 0 })),
    count: jest.fn(({ where }: any) =>
      Promise.resolve([...rows.values()].filter((r) => r.organizationId === where.organizationId).length),
    ),
    __rows: rows,
  };
}

class TestRepository extends TenantScopedRepository<ReturnType<typeof buildDelegateMock>> {
  constructor(delegate: ReturnType<typeof buildDelegateMock>, tenantContext: { organizationId: string }) {
    super(delegate, tenantContext as any);
  }
}

describe("TenantScopedRepository", () => {
  let delegate: ReturnType<typeof buildDelegateMock>;
  let repo: TestRepository;

  beforeEach(() => {
    delegate = buildDelegateMock();
    repo = new TestRepository(delegate, { organizationId: TENANT_ID });
  });

  it("overrides a client-supplied organizationId in a filter-style where clause", async () => {
    await repo.findMany({ where: { organizationId: "org-forged", name: "mine" } });

    expect(delegate.findMany).toHaveBeenCalledWith({
      where: { name: "mine", organizationId: TENANT_ID },
    });
  });

  it("overrides a client-supplied organizationId on create", async () => {
    await repo.create({ organizationId: "org-forged", name: "new row" });

    expect(delegate.create).toHaveBeenCalledWith({
      data: { name: "new row", organizationId: TENANT_ID },
    });
  });

  it("resolves a cross-tenant id to null via findOwnedUnique, never returning another tenant's row", async () => {
    const result = await repo.findOwnedUnique({ id: "row-other-tenant" });
    expect(result).toBeNull();
  });

  it("returns the record when it actually belongs to the current tenant", async () => {
    const result = await repo.findOwnedUnique({ id: "row-owned" });
    expect(result).toMatchObject({ id: "row-owned", organizationId: TENANT_ID });
  });

  it("refuses to update a cross-tenant row, even with a valid id", async () => {
    await expect(repo.update({ id: "row-other-tenant" }, { name: "hijacked" })).rejects.toBeInstanceOf(
      NotFoundException,
    );
    expect(delegate.update).not.toHaveBeenCalled();
  });

  it("refuses to delete a cross-tenant row, even with a valid id", async () => {
    await expect(repo.delete({ id: "row-other-tenant" })).rejects.toBeInstanceOf(NotFoundException);
    expect(delegate.delete).not.toHaveBeenCalled();
  });

  it("overrides a client-supplied organizationId in the update payload, so a row can never be moved to another tenant", async () => {
    await repo.update({ id: "row-owned" }, { organizationId: "org-forged", name: "renamed" });

    expect(delegate.update).toHaveBeenCalledWith({
      where: { id: "row-owned" },
      data: { name: "renamed", organizationId: TENANT_ID },
    });
  });

  it("allows updating and deleting a row that genuinely belongs to the current tenant", async () => {
    await repo.update({ id: "row-owned" }, { name: "renamed" });
    expect(delegate.update).toHaveBeenCalled();

    await repo.delete({ id: "row-owned" });
    expect(delegate.delete).toHaveBeenCalledWith({ where: { id: "row-owned" } });
  });
});
