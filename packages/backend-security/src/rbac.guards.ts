import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { AuthenticatedUser, PlatformRole } from "./auth.interfaces";

@Injectable()
export class TenantGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user: AuthenticatedUser = request.user;
    const headerTenantId = request.headers["x-tenant-id"];

    if (!user) {
      throw new UnauthorizedException("Unauthenticated request");
    }

    if (user.platformRole === PlatformRole.SUPER_ADMIN) {
      return true;
    }

    const tenantId = user.organizationId || headerTenantId;
    if (!tenantId) {
      throw new ForbiddenException("Tenant isolation violation: Tenant ID missing");
    }

    request.tenantId = tenantId;
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
