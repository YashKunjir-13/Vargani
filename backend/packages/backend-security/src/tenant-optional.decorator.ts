import { SetMetadata } from "@nestjs/common";

export const IS_TENANT_OPTIONAL_KEY = "isTenantOptional";

/**
 * Marks an authenticated route as exempt from mandatory organizationId requirement
 * in TenantGuard (e.g. user profile endpoints, tenant selection, donor personal dashboard).
 */
export const TenantOptional = () => SetMetadata(IS_TENANT_OPTIONAL_KEY, true);
