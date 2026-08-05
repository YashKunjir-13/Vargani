import { SetMetadata } from "@nestjs/common";

export const IS_PUBLIC_KEY = "isPublic";

/**
 * Marks a route as exempt from the global TenantGuard/PermissionGuard checks
 * (e.g. health checks, login/refresh, public event pages). Everything else is
 * protected by default once those guards are registered as APP_GUARD.
 */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
