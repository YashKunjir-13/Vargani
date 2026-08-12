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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PermissionGuard = exports.RequirePermission = exports.PERMISSION_METADATA_KEY = void 0;
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
exports.PERMISSION_METADATA_KEY = "requiredPermission";
const RequirePermission = (permissionCode) => (0, common_1.SetMetadata)(exports.PERMISSION_METADATA_KEY, permissionCode);
exports.RequirePermission = RequirePermission;
let PermissionGuard = class PermissionGuard {
    reflector;
    constructor(reflector = new core_1.Reflector()) {
        this.reflector = reflector;
    }
    canActivate(context) {
        const requiredPermission = this.reflector.getAllAndOverride(exports.PERMISSION_METADATA_KEY, [context.getHandler(), context.getClass()]);
        if (!requiredPermission) {
            return true;
        }
        const request = context.switchToHttp().getRequest();
        const user = request.user;
        if (!user) {
            throw new common_1.UnauthorizedException("Unauthenticated request");
        }
        const requiredCodes = Array.isArray(requiredPermission) ? requiredPermission : [requiredPermission];
        const hasAnyRequiredCode = requiredCodes.some((code) => user.permissions?.includes(code) || user.permissions?.includes("*"));
        if (!hasAnyRequiredCode) {
            throw new common_1.ForbiddenException(`Missing required permission: ${requiredCodes.join(" or ")}`);
        }
        return true;
    }
};
exports.PermissionGuard = PermissionGuard;
exports.PermissionGuard = PermissionGuard = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, common_1.Optional)()),
    __metadata("design:paramtypes", [core_1.Reflector])
], PermissionGuard);
//# sourceMappingURL=permission.guard.js.map