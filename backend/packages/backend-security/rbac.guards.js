"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.EventGuard = exports.TenantGuard = void 0;
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const auth_interfaces_1 = require("./auth.interfaces");
const public_decorator_1 = require("./public.decorator");
function extractClaimedTenantId(request) {
    return (request.headers?.["x-tenant-id"] ??
        request.body?.organizationId ??
        request.query?.organizationId);
}
let TenantGuard = class TenantGuard {
    reflector;
    constructor(reflector = new core_1.Reflector()) {
        this.reflector = reflector;
    }
    canActivate(context) {
        const isPublic = this.reflector.getAllAndOverride(public_decorator_1.IS_PUBLIC_KEY, [
            context.getHandler(),
            context.getClass(),
        ]);
        if (isPublic) {
            return true;
        }
        const request = context.switchToHttp().getRequest();
        const user = request.user;
        if (!user) {
            throw new common_1.UnauthorizedException("Unauthenticated request");
        }
        if (user.platformRole === auth_interfaces_1.PlatformRole.SUPER_ADMIN) {
            return true;
        }
        if (!user.organizationId) {
            throw new common_1.ForbiddenException("Tenant isolation violation: Tenant ID missing");
        }
        const claimedTenantId = extractClaimedTenantId(request);
        if (claimedTenantId && claimedTenantId !== user.organizationId) {
            throw new common_1.ForbiddenException("Tenant isolation violation: organizationId mismatch");
        }
        request.tenantId = user.organizationId;
        return true;
    }
};
exports.TenantGuard = TenantGuard;
exports.TenantGuard = TenantGuard = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [core_1.Reflector])
], TenantGuard);
let EventGuard = class EventGuard {
    canActivate(context) {
        const request = context.switchToHttp().getRequest();
        const user = request.user;
        const headerEventId = request.headers["x-event-id"];
        if (!user) {
            throw new common_1.UnauthorizedException("Unauthenticated request");
        }
        const eventId = headerEventId;
        if (!eventId && user.platformRole !== auth_interfaces_1.PlatformRole.SUPER_ADMIN) {
            throw new common_1.ForbiddenException("Event scope missing in request context");
        }
        request.eventId = eventId;
        return true;
    }
};
exports.EventGuard = EventGuard;
exports.EventGuard = EventGuard = __decorate([
    (0, common_1.Injectable)()
], EventGuard);
//# sourceMappingURL=rbac.guards.js.map