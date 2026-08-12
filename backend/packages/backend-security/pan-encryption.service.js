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
exports.PanEncryptionService = void 0;
const common_1 = require("@nestjs/common");
const crypto_1 = require("crypto");
const ALGORITHM = "aes-256-gcm";
const IV_LENGTH = 12;
let PanEncryptionService = class PanEncryptionService {
    key;
    constructor() {
        const secret = process.env.PAN_ENCRYPTION_KEY ||
            "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";
        this.key = (0, crypto_1.scryptSync)(secret, "pauti-pustak-pan-salt", 32);
    }
    encrypt(plainText) {
        const iv = (0, crypto_1.randomBytes)(IV_LENGTH);
        const cipher = (0, crypto_1.createCipheriv)(ALGORITHM, this.key, iv);
        const ciphertext = Buffer.concat([cipher.update(plainText, "utf8"), cipher.final()]);
        const authTag = cipher.getAuthTag();
        return Buffer.concat([iv, authTag, ciphertext]).toString("base64");
    }
    decrypt(payload) {
        const buffer = Buffer.from(payload, "base64");
        const iv = buffer.subarray(0, IV_LENGTH);
        const authTag = buffer.subarray(IV_LENGTH, IV_LENGTH + 16);
        const ciphertext = buffer.subarray(IV_LENGTH + 16);
        const decipher = (0, crypto_1.createDecipheriv)(ALGORITHM, this.key, iv);
        decipher.setAuthTag(authTag);
        return Buffer.concat([decipher.update(ciphertext), decipher.final()]).toString("utf8");
    }
};
exports.PanEncryptionService = PanEncryptionService;
exports.PanEncryptionService = PanEncryptionService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], PanEncryptionService);
//# sourceMappingURL=pan-encryption.service.js.map