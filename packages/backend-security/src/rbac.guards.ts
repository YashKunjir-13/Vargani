import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Inject,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { AuthenticatedUser, PlatformRole } from "./auth.interfaces";
import { IS_PUBLIC_KEY } from "./public.decorator";

/**
 * Extracts whatever organizationId a client tried to smuggle into this
 * request outside of the trusted, server-verified `user.organizationId`
 * (header, body, or query string). Presence of one of these is only ever
 * used to *detect and reject* a mismatch -- never to establish tenant
 * identity by itself.
 */
function extractClaimedTenantId(request: any): string | undefined {
  return (
    request.headers?.["x-tenant-id"] ??
    request.body?.organizationId ??
    request.query?.organizationId
  );
}

@Injectable()
export class TenantGuard implements CanActivate {
  constructor(private readonly reflector: Reflector = new Reflector()) {}

  canActivate(context: ExecutionContext): boolean {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user: AuthenticatedUser = request.user;

    if (!user) {
      throw new UnauthorizedException("Unauthenticated request");
    }

    if (user.platformRole === PlatformRole.SUPER_ADMIN) {
      return true;
    }

    if (!user.organizationId) {
      throw new ForbiddenException("Tenant isolation violation: Tenant ID missing");
    }

    // A client-supplied organizationId (header/body/query) is never trusted
    // as the tenant identity -- it is only checked for consistency. Any
    // mismatch against the token-derived organizationId is treated as a
    // forgery attempt and rejected outright, never silently overridden or
    // silently ignored.
    const claimedTenantId = extractClaimedTenantId(request);
    if (claimedTenantId && claimedTenantId !== user.organizationId) {
      throw new ForbiddenException("Tenant isolation violation: organizationId mismatch");
    }

    request.tenantId = user.organizationId;
    return true;
  }
}

@Injectable()
export class EventGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user: AuthenticatedUser = request.user;
    const headerEventId = request.headers["x-event-id"];

    if (!user) {
      throw new UnauthorizedException("Unauthenticated request");
    }

    const eventId = headerEventId;
    if (!eventId && user.platformRole !== PlatformRole.SUPER_ADMIN) {
      throw new ForbiddenException("Event scope missing in request context");
    }

    request.eventId = eventId;
    return true;
  }
}
