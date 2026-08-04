import { Injectable, Logger, NestMiddleware } from "@nestjs/common";
import { NextFunction, Request, Response } from "express";
import { AuthenticatedUser, PlatformRole } from "@pauti-pustak/backend-security";

/**
 * DEV-ONLY stand-in for real JWT authentication, which is not wired up yet
 * (AuthController is still a skeleton -- see auth.controller.ts). Populates
 * `request.user` from plain, unsigned request headers so TenantGuard/
 * PermissionGuard have something to check locally against Swagger/curl.
 *
 * Double-gated so it can never run in production: requires both
 * NODE_ENV !== "production" AND an explicit ENABLE_DEV_AUTH_BYPASS=true.
 * Delete this file once real auth issues real JWTs.
 */
@Injectable()
export class DevAuthBypassMiddleware implements NestMiddleware {
  private readonly logger = new Logger(DevAuthBypassMiddleware.name);
  private warned = false;

  static isEnabled(): boolean {
    return process.env.NODE_ENV !== "production" && process.env.ENABLE_DEV_AUTH_BYPASS === "true";
  }

  use(req: Request, _res: Response, next: NextFunction) {
    if (!this.warned) {
      this.logger.warn(
        "DevAuthBypassMiddleware is ACTIVE -- request.user is being faked from unsigned headers. " +
          "This must never run in production (guarded by NODE_ENV + ENABLE_DEV_AUTH_BYPASS).",
      );
      this.warned = true;
    }

    const organizationId =
      (req.headers["x-dev-organization-id"] as string) ||
      (req.headers["x-tenant-id"] as string) ||
      "00000000-0000-4000-a000-000000000001";
    const permissionsHeader = req.headers["x-dev-permissions"] as string | undefined;
    const platformRoleHeader = req.headers["x-dev-platform-role"] as string | undefined;

    const defaultPermissions = [
      "bill.create", "bill.approve", "bill.pay", "bill.read", "bill.view", "bill.update", "bill.submit", "bill.reject", "bill.markPaid", "bill.cancel", "bill.delete",
      "contribution.create", "contribution.read", "contribution.update", "contribution.delete", "contribution.receipt",
      "receipt.create", "receipt.read", "receipt.viewAll", "receipt.viewOwn", "receipt.void",
      "payment.create", "payment.read", "payment.confirmMatch", "payment.void"
    ];

    (req as any).user = {
      userId: (req.headers["x-dev-user-id"] as string) || "11111111-1111-4111-a111-111111111111",
      platformRole:
        platformRoleHeader === "SUPER_ADMIN" ? PlatformRole.SUPER_ADMIN : PlatformRole.USER,
      organizationId,
      roleId: (req.headers["x-dev-role-id"] as string) || undefined,
      sessionId: "dev-session",
      permissions: permissionsHeader
        ? permissionsHeader.split(",").map((code) => code.trim()).filter(Boolean)
        : defaultPermissions,
    } satisfies AuthenticatedUser;

    (req as any).tenantId = organizationId;

    next();
  }
}
