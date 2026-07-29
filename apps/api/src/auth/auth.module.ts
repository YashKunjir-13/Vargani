import { Module } from "@nestjs/common";
import { JwtModule } from "@nestjs/jwt";
import { PassportModule } from "@nestjs/passport";
import { HashingService, PanEncryptionService } from "@pauti-pustak/backend-security";
import { readFileSync } from "fs";
import { resolve } from "path";
import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";
import { JwtStrategy } from "./jwt.strategy";

function readKeyFile(envVar: string, fallback: string): string {
  const keyPath = process.env[envVar] ?? fallback;
  return readFileSync(resolve(process.cwd(), keyPath), "utf8");
}

@Module({
  imports: [
    PassportModule,
    JwtModule.register({
      privateKey: readKeyFile("JWT_PRIVATE_KEY_PATH", "./config/certs/jwt_private.key"),
      publicKey: readKeyFile("JWT_PUBLIC_KEY_PATH", "./config/certs/jwt_public.key"),
      signOptions: { algorithm: "RS256" },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, HashingService, PanEncryptionService],
})
export class AuthModule {}
