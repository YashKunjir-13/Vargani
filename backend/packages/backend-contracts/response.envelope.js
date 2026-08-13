"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createApiResponse = createApiResponse;
function createApiResponse(data, statusCode = 200, message, meta) {
    return {
        success: statusCode >= 200 && statusCode < 300,
        statusCode,
        data,
        message,
        meta: {
            timestamp: new Date().toISOString(),
            ...meta,
        },
    };
}
//# sourceMappingURL=response.envelope.js.map