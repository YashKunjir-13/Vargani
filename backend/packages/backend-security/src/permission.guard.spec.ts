import { Reflector } from "@nestjs/core";
import { PermissionGuard, RequirePermission, PERMISSION_METADATA_KEY } from "./permission.guard";
import { AuthenticatedUser, PlatformRole } from "./auth.interfaces";

class TestController {
  @RequirePermission("receipt.viewAll")
  singleCode() {}

  @RequirePermission(["receipt.viewAll", "receipt.viewOwn"])
  eitherCode() {}

  noDecorator() {}
}

function buildContext(user: AuthenticatedUser | undefined, handler: (...args: any[]) => any): any {
  return {
    getHandler: () => handler,
    getClass: () => TestController,
    switchToHttp: () => ({ getRequest: () => ({ user }) }),
  };
}

function userWith(permissions: string[]): AuthenticatedUser {
  return { userId: "u1", platformRole: PlatformRole.USER, sessionId: "s1", permissions };
}

describe("PermissionGuard", () => {
  it("still enforces a single required code exactly as before", () => {
    const guard = new PermissionGuard(new Reflector());

    expect(() =>
      guard.canActivate(buildContext(userWith([]), TestController.prototype.singleCode)),
    ).toThrow("Missing required permission: receipt.viewAll");
    expect(
      guard.canActivate(buildContext(userWith(["receipt.viewAll"]), TestController.prototype.singleCode)),
    ).toBe(true);
  });

  it("allows access when the user holds any one of an array of required codes", () => {
    const guard = new PermissionGuard(new Reflector());

    expect(
      guard.canActivate(buildContext(userWith(["receipt.viewOwn"]), TestController.prototype.eitherCode)),
    ).toBe(true);
    expect(
      guard.canActivate(buildContext(userWith(["receipt.viewAll"]), TestController.prototype.eitherCode)),
    ).toBe(true);
  });

  it("rejects when the user holds none of the array's required codes", () => {
    const guard = new PermissionGuard(new Reflector());

    expect(() =>
      guard.canActivate(buildContext(userWith(["payment.create"]), TestController.prototype.eitherCode)),
    ).toThrow("Missing required permission: receipt.viewAll or receipt.viewOwn");
  });

  it("allows any authenticated user through a route with no @RequirePermission", () => {
    const guard = new PermissionGuard(new Reflector());

    expect(guard.canActivate(buildContext(userWith([]), TestController.prototype.noDecorator))).toBe(true);
  });
});
