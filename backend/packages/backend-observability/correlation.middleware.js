"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CorrelationMiddleware = exports.REQUEST_ID_HEADER = exports.CORRELATION_HEADER = void 0;
const common_1 = require("@nestjs/common");
const uuid_1 = require("uuid");
exports.CORRELATION_HEADER = "x-correlation-id";
exports.REQUEST_ID_HEADER = "x-request-id";
let CorrelationMiddleware = class CorrelationMiddleware {
    use(req, res, next) {
        const correlationId = req.headers[exports.CORRELATION_HEADER] || (0, uuid_1.v4)();
        const requestId = req.headers[exports.REQUEST_ID_HEADER] || (0, uuid_1.v4)();
        req.headers[exports.CORRELATION_HEADER] = correlationId;
        req.headers[exports.REQUEST_ID_HEADER] = requestId;
        res.setHeader(exports.CORRELATION_HEADER, correlationId);
        res.setHeader(exports.REQUEST_ID_HEADER, requestId);
        next();
    }
};
exports.CorrelationMiddleware = CorrelationMiddleware;
exports.CorrelationMiddleware = CorrelationMiddleware = __decorate([
    (0, common_1.Injectable)()
], CorrelationMiddleware);
//# sourceMappingURL=correlation.middleware.js.map