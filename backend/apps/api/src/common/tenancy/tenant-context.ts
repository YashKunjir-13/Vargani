import { ForbiddenException, Inject, Injectable, Scope } from "@nestjs/common";
import { REQUEST } from "@nestjs/core";

interface TenantScopedRequest {
  tenantId?: string;
}

/**
 * Request-scoped accessor for the current tenant's organizationId.
 *
 * `request.tenantId` is set exclusively by TenantGuard after it has
 * validated the authenticated user's token-derived organizationId (see
 * packages/backend-security/src/rbac.guards.ts). Nothing downstream of the
 * guard re-derives organizationId from the client -- every tenant-scoped
 * repository/service pulls it from here instead, so there is exactly one
 * place in the request lifecycle where tenant identity is established.
 */
@Injectable({ scope: Scope.REQUEST })
export class TenantContext {
  constructor(@Inject(REQUEST) private readonly request: TenantScopedRequest) {}

  get organizationId(): string {
    const tenantId = this.request.tenantId;
    if (!tenantId) {
      throw new ForbiddenException(
        "Tenant context unavailable: TenantGuard must run before any tenant-scoped repository is used",
      );
    }
    return tenantId;
  }
}
