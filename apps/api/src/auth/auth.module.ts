import { Module } from "@nestjs/common";
import { JwtModule } from "@nestjs/jwt";
import { PassportModule } from "@nestjs/passport";
import { HashingService, PanEncryptionService } from "@pauti-pustak/backend-security";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "fs";
import { generateKeyPairSync } from "crypto";
import { resolve } from "path";
import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";
import { JwtStrategy } from "./jwt.strategy";
import { AuditModule } from "../audit/audit.module";

function readKeyFile(envVar: string, fallback: string, isPrivate: boolean): string {
  const keyPath = process.env[envVar] ?? fallback;
  const fullPath = resolve(process.cwd(), keyPath);
  if (existsSync(fullPath)) {
    return readFileSync(fullPath, "utf8");
  }

  const dir = resolve(fullPath, "..");
  if (!existsSync(dir)) {
    mkdirSync(dir, { recursive: true });
  }

  const privPath = resolve(dir, "jwt_private.key");
  const pubPath = resolve(dir, "jwt_public.key");

  if (!existsSync(privPath) || !existsSync(pubPath)) {
    const { privateKey, publicKey } = generateKeyPairSync("rsa", {
      modulusLength: 2048,
      publicKeyEncoding: { type: "spki", format: "pem" },
      privateKeyEncoding: { type: "pkcs8", format: "pem" },
    });
    if (!existsSync(privPath)) writeFileSync(privPath, privateKey);
    if (!existsSync(pubPath)) writeFileSync(pubPath, publicKey);
  }

  const targetPath = isPrivate ? privPath : pubPath;
  return readFileSync(targetPath, "utf8");
}

@Module({
  imports: [
    PassportModule,
    AuditModule,
    JwtModule.register({
      privateKey: readKeyFile("JWT_PRIVATE_KEY_PATH", "./config/certs/jwt_private.key", true),
      publicKey: readKeyFile("JWT_PUBLIC_KEY_PATH", "./config/certs/jwt_public.key", false),
      signOptions: { algorithm: "RS256" },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, HashingService, PanEncryptionService],
  exports: [AuthService, JwtModule, HashingService, PanEncryptionService],
})
export class AuthModule {}
