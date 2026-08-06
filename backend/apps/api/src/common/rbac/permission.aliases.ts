// Exact-name alias matching the requested `@RequiresPermission(...)` decorator
// spelling, backed by the existing (and already-wired) implementation in
// backend-security so there is exactly one PermissionGuard/decorator pair in
// the codebase, not two competing ones.
export { RequirePermission as RequiresPermission } from "@pauti-pustak/backend-security";
