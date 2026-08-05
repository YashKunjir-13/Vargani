import { NotFoundException } from "@nestjs/common";
import { TenantContext } from "./tenant-context";

/**
 * The minimal, duck-typed shape of a Prisma model delegate (e.g.
 * `prisma.contributionBill`) that TenantScopedRepository drives. Kept
 * loosely typed on purpose: this base class is meant to work with any
 * Prisma model that carries an `organizationId` column, without needing a
 * generated type per model.
 */
export interface TenantScopedDelegate {
  findMany(args?: Record<string, any>): Promise<any[]>;
  findFirst(args?: Record<string, any>): Promise<any | null>;
  findUnique(args: { where: Record<string, any> }): Promise<any | null>;
  create(args: { data: Record<string, any> }): Promise<any>;
  update(args: { where: Record<string, any>; data: Record<string, any> }): Promise<any>;
  updateMany(args: {
    where?: Record<string, any>;
    data: Record<string, any>;
  }): Promise<{ count: number }>;
  delete(args: { where: Record<string, any> }): Promise<any>;
  deleteMany(args?: { where?: Record<string, any> }): Promise<{ count: number }>;
  count(args?: Record<string, any>): Promise<number>;
}

/**
 * Base repository enforcing organizationId scoping at the query layer for
 * every module built on top of it, so cross-tenant reads/writes are
 * impossible by construction rather than by convention:
 *
 *  - Filter-style operations (findMany/findFirst/count/updateMany/
 *    deleteMany) always have `organizationId` merged into `where` *last*,
 *    so a caller-supplied `where.organizationId` (e.g. forwarded straight
 *    from a query string) is unconditionally overwritten.
 *  - `create` always has `organizationId` merged into `data` last, for the
 *    same reason applied to the request body.
 *  - Prisma's unique operations (`findUnique`/`update`/`delete`) take a
 *    genuine unique selector (typically just `{ id }`) that cannot safely
 *    be widened with an arbitrary extra `organizationId` key without a
 *    matching compound-unique index. Instead, ownership is verified with a
 *    fetch-then-compare (`requireOwned`) before any unique mutation is
 *    allowed to proceed -- a cross-tenant id resolves to "not found", not
 *    to another tenant's data.
 */
export abstract class TenantScopedRepository<TDelegate extends TenantScopedDelegate> {
  protected constructor(
    protected readonly delegate: TDelegate,
    protected readonly tenantContext: TenantContext,
  ) {}

  protected get organizationId(): string {
    return this.tenantContext.organizationId;
  }

  private scopedWhere(where: Record<string, any> = {}): Record<string, any> {
    return { ...where, organizationId: this.organizationId };
  }

  private scopedWriteData<T extends Record<string, any>>(
    data: T,
  ): T & { organizationId: string } {
    return { ...data, organizationId: this.organizationId };
  }

  findMany(args: Record<string, any> = {}): Promise<any[]> {
    return this.delegate.findMany({ ...args, where: this.scopedWhere(args.where) });
  }

  findFirst(args: Record<string, any> = {}): Promise<any | null> {
    return this.delegate.findFirst({ ...args, where: this.scopedWhere(args.where) });
  }

  count(args: Record<string, any> = {}): Promise<number> {
    return this.delegate.count({ ...args, where: this.scopedWhere(args.where) });
  }

  create(data: Record<string, any>): Promise<any> {
    return this.delegate.create({ data: this.scopedWriteData(data) });
  }

  /** Returns the record only if it belongs to the current tenant, else null -- never another tenant's row. */
  async findOwnedUnique(uniqueWhere: Record<string, any>): Promise<any | null> {
    const record = await this.delegate.findUnique({ where: uniqueWhere });
    return record && record.organizationId === this.organizationId ? record : null;
  }

  /** Same as findOwnedUnique, but throws instead of returning null (safe to use before update/delete). */
  async requireOwned(uniqueWhere: Record<string, any>): Promise<any> {
    const record = await this.findOwnedUnique(uniqueWhere);
    if (!record) {
      throw new NotFoundException("Resource not found");
    }
    return record;
  }

  async update(uniqueWhere: Record<string, any>, data: Record<string, any>): Promise<any> {
    await this.requireOwned(uniqueWhere);
    // organizationId is reasserted last so a client-supplied value in the
    // update payload can never move a record to a different tenant either.
    return this.delegate.update({ where: uniqueWhere, data: this.scopedWriteData(data) });
  }

  async delete(uniqueWhere: Record<string, any>): Promise<any> {
    await this.requireOwned(uniqueWhere);
    return this.delegate.delete({ where: uniqueWhere });
  }

  updateMany(where: Record<string, any>, data: Record<string, any>): Promise<{ count: number }> {
    return this.delegate.updateMany({
      where: this.scopedWhere(where),
      data: this.scopedWriteData(data),
    });
  }

  deleteMany(where: Record<string, any> = {}): Promise<{ count: number }> {
    return this.delegate.deleteMany({ where: this.scopedWhere(where) });
  }
}
