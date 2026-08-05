import { Reflector } from "@nestjs/core";
import { AuthenticatedUser, PermissionGuard, PlatformRole } from "@pauti-pustak/backend-security";
import { TemplatesController } from "./templates.controller";

function buildContext(user: AuthenticatedUser | undefined, handler: (...args: any[]) => any): any {
  return {
    getHandler: () => handler,
    getClass: () => TemplatesController,
    switchToHttp: () => ({ getRequest: () => ({ user }) }),
  };
}

describe("TemplatesController security", () => {
  it("rejects POST /templates/upload for a user without template.upload", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(
      { userId: "u1", platformRole: PlatformRole.USER, sessionId: "s1", permissions: [] } as AuthenticatedUser,
      TemplatesController.prototype.upload,
    );

    expect(() => guard.canActivate(context)).toThrow("Missing required permission: template.upload");
  });

  it("allows POST /templates/upload for a user holding template.upload", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(
      {
        userId: "u1",
        platformRole: PlatformRole.USER,
        sessionId: "s1",
        permissions: ["template.upload"],
      } as AuthenticatedUser,
      TemplatesController.prototype.upload,
    );

    expect(guard.canActivate(context)).toBe(true);
  });

  it("rejects PATCH /templates/:id/activate for a user who only holds template.upload", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(
      {
        userId: "u1",
        platformRole: PlatformRole.USER,
        sessionId: "s1",
        permissions: ["template.upload"],
      } as AuthenticatedUser,
      TemplatesController.prototype.activate,
    );

    expect(() => guard.canActivate(context)).toThrow("Missing required permission: template.activate");
  });

  it("allows PATCH /templates/:id/activate for a user holding template.activate", () => {
    const guard = new PermissionGuard(new Reflector());
    const context = buildContext(
      {
        userId: "u1",
        platformRole: PlatformRole.USER,
        sessionId: "s1",
        permissions: ["template.activate"],
      } as AuthenticatedUser,
      TemplatesController.prototype.activate,
    );

    expect(guard.canActivate(context)).toBe(true);
  });
});
