import { Reflector } from "@nestjs/core";
import { AuthenticatedUser, PermissionGuard, PlatformRole } from "@pauti-pustak/backend-security";
import { ReceiptsController } from "./receipts.controller";

// Mirrors the seeded default roles in common/rbac/role-catalog.ts.
const DONOR_PERMISSIONS: string[] = ["receipt.viewOwn"];
const TREASURER_PERMISSIONS: string[] = ["payment.create", "payment.confirmMatch", "payment.view", "receipt.viewAll", "receipt.void"];

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
    getClass: () => ReceiptsController,
    switchToHttp: () => ({ getRequest: () => ({ user }) }),
  };
}

describe("ReceiptsController security", () => {
  it("rejects GET /receipts (org-wide list) for a Donor-role account", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(DONOR_PERMISSIONS, ReceiptsController.prototype.list);

    expect(() => guard.canActivate(context)).toThrow("Missing required permission: receipt.viewAll");
  });

  it("allows GET /receipts for a Treasurer", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(TREASURER_PERMISSIONS, ReceiptsController.prototype.list);

    expect(guard.canActivate(context)).toBe(true);
  });

  it("allows GET /receipts/my-history for a Donor-role account", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(DONOR_PERMISSIONS, ReceiptsController.prototype.myHistory);

    expect(guard.canActivate(context)).toBe(true);
  });

  it("rejects GET /receipts/my-history for a Treasurer who lacks receipt.viewOwn", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(TREASURER_PERMISSIONS, ReceiptsController.prototype.myHistory);

    expect(() => guard.canActivate(context)).toThrow("Missing required permission: receipt.viewOwn");
  });

  it("allows GET /receipts/:id for a Donor (receipt.viewOwn) via the OR-permission gate", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(DONOR_PERMISSIONS, ReceiptsController.prototype.getById);

    expect(guard.canActivate(context)).toBe(true);
  });

  it("allows GET /receipts/:id for a Treasurer (receipt.viewAll) via the OR-permission gate", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(TREASURER_PERMISSIONS, ReceiptsController.prototype.getById);

    expect(guard.canActivate(context)).toBe(true);
  });

  it("rejects GET /receipts/:id for an account with neither receipt.viewAll nor receipt.viewOwn", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(["payment.create"], ReceiptsController.prototype.getById);

    expect(() => guard.canActivate(context)).toThrow(
      "Missing required permission: receipt.viewAll or receipt.viewOwn",
    );
  });

  it("rejects POST /receipts/:id/void for a Donor", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(DONOR_PERMISSIONS, ReceiptsController.prototype.void);

    expect(() => guard.canActivate(context)).toThrow("Missing required permission: receipt.void");
  });

  it("allows POST /receipts/:id/void for a Treasurer holding receipt.void", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(TREASURER_PERMISSIONS, ReceiptsController.prototype.void);

    expect(guard.canActivate(context)).toBe(true);
  });

  it("rejects POST /receipts/:id/resend-whatsapp for a Donor", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(DONOR_PERMISSIONS, ReceiptsController.prototype.resendWhatsapp);

    expect(() => guard.canActivate(context)).toThrow("Missing required permission: receipt.viewAll");
  });
});
