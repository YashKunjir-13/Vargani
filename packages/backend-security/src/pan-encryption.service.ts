import { Injectable } from "@nestjs/common";
import { createCipheriv, createDecipheriv, randomBytes, scryptSync } from "crypto";

const ALGORITHM = "aes-256-gcm";
const IV_LENGTH = 12;

/**
 * Encrypts PAN numbers at rest (columns named `panEncrypted` in the Prisma
 * schema). Key is derived from PAN_ENCRYPTION_KEY via scrypt so any
 * passphrase-shaped env value works, not just a raw 32-byte key.
 */
@Injectable()
export class PanEncryptionService {
  private readonly key: Buffer;

  constructor() {
    const secret = process.env.PAN_ENCRYPTION_KEY;
    if (!secret) {
      throw new Error("PAN_ENCRYPTION_KEY environment variable is not set");
    }
    this.key = scryptSync(secret, "pauti-pustak-pan-salt", 32);
  }

  encrypt(plainText: string): string {
    const iv = randomBytes(IV_LENGTH);
    const cipher = createCipheriv(ALGORITHM, this.key, iv);
    const ciphertext = Buffer.concat([cipher.update(plainText, "utf8"), cipher.final()]);
    const authTag = cipher.getAuthTag();
    return Buffer.concat([iv, authTag, ciphertext]).toString("base64");
  }

  decrypt(payload: string): string {
    const buffer = Buffer.from(payload, "base64");
    const iv = buffer.subarray(0, IV_LENGTH);
    const authTag = buffer.subarray(IV_LENGTH, IV_LENGTH + 16);
    const ciphertext = buffer.subarray(IV_LENGTH + 16);
    const decipher = createDecipheriv(ALGORITHM, this.key, iv);
    decipher.setAuthTag(authTag);
    return Buffer.concat([decipher.update(ciphertext), decipher.final()]).toString("utf8");
  }
}
