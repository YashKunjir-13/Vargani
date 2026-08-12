"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TenantOptional = exports.IS_TENANT_OPTIONAL_KEY = void 0;
const common_1 = require("@nestjs/common");
exports.IS_TENANT_OPTIONAL_KEY = "isTenantOptional";
const TenantOptional = () => (0, common_1.SetMetadata)(exports.IS_TENANT_OPTIONAL_KEY, true);
exports.TenantOptional = TenantOptional;
//# sourceMappingURL=tenant-optional.decorator.js.map