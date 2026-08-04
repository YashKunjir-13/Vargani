import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Inject,
  Injectable,
  SetMetadata,
  UnauthorizedException,
} from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { AuthenticatedUser } from "./auth.interfaces";

export const PERMISSION_METADATA_KEY = "requiredPermission";

/**
 * Declares the permission code(s) a controller action requires. Implements
 * FR57: "Every protected controller action declares permission metadata and
 * PermissionGuard resolves role from trusted membership context."
 *
 * Passing an array means OR semantics -- any one of the listed codes is
 * sufficient (e.g. a receipt detail route open to both `receipt.viewAll`
 * staff and a `receipt.viewOwn` donor). A single string behaves exactly as
 * before.
 */
export const RequirePermission = (permissionCode: string | string[]) =>
  SetMetadata(PERMISSION_METADATA_KEY, permissionCode);

@Injectable()
export class PermissionGuard implements CanActivate {
  constructor(private readonly reflector: Reflector = new Reflector()) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredPermission = this.reflector.getAllAndOverride<string | string[] | undefined>(
      PERMISSION_METADATA_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!requiredPermission) {
      // No @RequirePermission declared on this route: nothing to enforce.
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user: AuthenticatedUser = request.user;

    if (!user) {
      throw new UnauthorizedException("Unauthenticated request");
    }

    const requiredCodes = Array.isArray(requiredPermission) ? requiredPermission : [requiredPermission];

    // Deliberately no Owner/Super Admin bypass here: FR54 only protects the
    // Owner *role* from having its own permissions revoked, it does not grant
    // an implicit bypass of permission checks elsewhere. Every request is
    // authorized from its actually-resolved permission set.
    const hasAnyRequiredCode = requiredCodes.some((code) => user.permissions?.includes(code));
    if (!hasAnyRequiredCode) {
      throw new ForbiddenException(`Missing required permission: ${requiredCodes.join(" or ")}`);
    }

    return true;
  }
}
