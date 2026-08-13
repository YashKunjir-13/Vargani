import { CanActivate, ExecutionContext } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
export declare const PERMISSION_METADATA_KEY = "requiredPermission";
export declare const RequirePermission: (permissionCode: string | string[]) => import("@nestjs/common").CustomDecorator<string>;
export declare class PermissionGuard implements CanActivate {
    private readonly reflector;
    constructor(reflector?: Reflector);
    canActivate(context: ExecutionContext): boolean;
}
