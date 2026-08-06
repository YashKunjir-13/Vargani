import { Reflector } from "@nestjs/core";
import { AuthenticatedUser, PermissionGuard, PlatformRole } from "@pauti-pustak/backend-security";
import { PaymentsController } from "./payments.controller";

// Mirrors the seeded Donor role in common/rbac/role-catalog.ts: external
// contributors only ever get receipt.viewOwn -- never any payment.* code.
const DONOR_PERMISSIONS: string[] = ["receipt.viewOwn"];
const VOLUNTEER_PERMISSIONS: string[] = ["payment.create", "receipt.viewOwn", "contribution.create"];
const TREASURER_PERMISSIONS: string[] = ["payment.create", "payment.confirmMatch", "payment.view"];

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
    getClass: () => PaymentsController,
    switchToHttp: () => ({ getRequest: () => ({ user }) }),
  };
}

describe("PaymentsController security", () => {
  it("rejects POST /payments for a Donor-role account", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(DONOR_PERMISSIONS, PaymentsController.prototype.create);

    expect(() => guard.canActivate(context)).toThrow("Missing required permission: payment.create");
  });

  it("rejects GET /payments (listing other donors' entries) for a Donor-role account", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(DONOR_PERMISSIONS, PaymentsController.prototype.list);

    expect(() => guard.canActivate(context)).toThrow("Missing required permission: payment.view");
  });

  it("rejects GET /payments/:id for a Donor-role account", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(DONOR_PERMISSIONS, PaymentsController.prototype.getById);

    expect(() => guard.canActivate(context)).toThrow("Missing required permission: payment.view");
  });

  it("allows POST /payments for a Volunteer recording a QR collection", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(VOLUNTEER_PERMISSIONS, PaymentsController.prototype.create);

    expect(guard.canActivate(context)).toBe(true);
  });

  it("rejects PATCH /payments/:id/confirm-match for a Volunteer (Treasurer-tier action)", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(VOLUNTEER_PERMISSIONS, PaymentsController.prototype.confirmMatch);

    expect(() => guard.canActivate(context)).toThrow("Missing required permission: payment.confirmMatch");
  });

  it("allows PATCH /payments/:id/confirm-match for a Treasurer", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(TREASURER_PERMISSIONS, PaymentsController.prototype.confirmMatch);

    expect(guard.canActivate(context)).toBe(true);
  });

  it("rejects POST /payments/:id/void for a Volunteer", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(VOLUNTEER_PERMISSIONS, PaymentsController.prototype.void);

    expect(() => guard.canActivate(context)).toThrow("Missing required permission: payment.confirmMatch");
  });
});
