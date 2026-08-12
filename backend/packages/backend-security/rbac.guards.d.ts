import { CanActivate, ExecutionContext } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
export declare class TenantGuard implements CanActivate {
    private readonly reflector;
    constructor(reflector?: Reflector);
    canActivate(context: ExecutionContext): boolean;
}
export declare class EventGuard implements CanActivate {
    canActivate(context: ExecutionContext): boolean;
}
