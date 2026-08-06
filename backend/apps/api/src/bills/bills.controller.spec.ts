import { Reflector } from "@nestjs/core";
import { AuthenticatedUser, PermissionGuard, PlatformRole } from "@pauti-pustak/backend-security";
import { BillsController } from "./bills.controller";

// Mirrors the seeded default roles in common/rbac/role-catalog.ts.
const VOLUNTEER_PERMISSIONS: string[] = ["payment.create", "receipt.viewOwn", "contribution.create"];
const TREASURER_PERMISSIONS: string[] = [
  "payment.create",
  "payment.confirmMatch",
  "payment.view",
  "receipt.viewAll",
  "receipt.void",
  "bill.create",
  "bill.approve",
  "bill.pay",
  "contribution.create",
];

function buildContext(permissions: string[], handler: (...args: any[]) => any): any {
  const user: AuthenticatedUser = {
    userId: "u1",
    platformRole: PlatformRole.USER,
    organizationId: "org-1",
    sessionId: "s1",
    permissions,
  };
  return {
    getHandler: () => handler,
    getClass: () => BillsController,
    switchToHttp: () => ({ getRequest: () => ({ user }) }),
  };
}

const ALL_ROUTE_HANDLERS: Array<[string, (...args: any[]) => any]> = [
  ["POST /bills", BillsController.prototype.create],
  ["GET /bills", BillsController.prototype.list],
  ["GET /bills/:id", BillsController.prototype.getById],
  ["PATCH /bills/:id", BillsController.prototype.update],
  ["PATCH /bills/:id/submit", BillsController.prototype.submit],
  ["PATCH /bills/:id/approve", BillsController.prototype.approve],
  ["PATCH /bills/:id/reject", BillsController.prototype.reject],
  ["PATCH /bills/:id/mark-paid", BillsController.prototype.markPaid],
  ["POST /bills/:id/cancel", BillsController.prototype.cancel],
];

describe("BillsController security", () => {
  it("a Volunteer (neither bill.create nor bill.approve) gets 403 on every route in this module", () => {
    const guard = new PermissionGuard(new Reflector());

    for (const [, handler] of ALL_ROUTE_HANDLERS) {
      expect(() => guard.canActivate(buildContext(VOLUNTEER_PERMISSIONS, handler))).toThrow(/Missing required permission/);
    }
  });

  it("allows POST /bills and PATCH /bills/:id for a Treasurer (bill.create)", () => {
    const guard = new PermissionGuard(new Reflector());

    expect(guard.canActivate(buildContext(TREASURER_PERMISSIONS, BillsController.prototype.create))).toBe(true);
    expect(guard.canActivate(buildContext(TREASURER_PERMISSIONS, BillsController.prototype.update))).toBe(true);
    expect(guard.canActivate(buildContext(TREASURER_PERMISSIONS, BillsController.prototype.submit))).toBe(true);
  });

  it("allows PATCH /bills/:id/approve and /reject for a holder of bill.approve", () => {
    const guard = new PermissionGuard(new Reflector());
    const presidentPermissions = ["bill.approve"];

    expect(guard.canActivate(buildContext(presidentPermissions, BillsController.prototype.approve))).toBe(true);
    expect(guard.canActivate(buildContext(presidentPermissions, BillsController.prototype.reject))).toBe(true);
    expect(guard.canActivate(buildContext(presidentPermissions, BillsController.prototype.cancel))).toBe(true);
  });

  it("rejects PATCH /bills/:id/mark-paid for a holder of bill.approve but not bill.pay", () => {
    const guard = new PermissionGuard(new Reflector());

    expect(() =>
      guard.canActivate(buildContext(["bill.approve"], BillsController.prototype.markPaid)),
    ).toThrow("Missing required permission: bill.pay");
  });

  it("allows GET /bills and GET /bills/:id for either bill.create or bill.approve holders", () => {
    const guard = new PermissionGuard(new Reflector());

    expect(guard.canActivate(buildContext(["bill.create"], BillsController.prototype.list))).toBe(true);
    expect(guard.canActivate(buildContext(["bill.approve"], BillsController.prototype.getById))).toBe(true);
  });
});
