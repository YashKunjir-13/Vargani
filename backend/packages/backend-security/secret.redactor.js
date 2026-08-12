"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.redactSecrets = redactSecrets;
const SENSITIVE_KEYS = [
    "password",
    "secret",
    "token",
    "authorization",
    "apiKey",
    "privateKey",
    "razorpayKeySecret",
    "cookie",
];
function redactSecrets(obj) {
    if (!obj || typeof obj !== "object") {
        return obj;
    }
    const redacted = Array.isArray(obj) ? [...obj] : { ...obj };
    for (const key of Object.keys(redacted)) {
        if (SENSITIVE_KEYS.some((k) => key.toLowerCase().includes(k.toLowerCase()))) {
            redacted[key] = "[REDACTED]";
        }
        else if (typeof redacted[key] === "object") {
            redacted[key] = redactSecrets(redacted[key]);
        }
    }
    return redacted;
}
//# sourceMappingURL=secret.redactor.js.map