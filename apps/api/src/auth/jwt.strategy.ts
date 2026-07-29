import { Injectable, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { PrismaService } from "@pauti-pustak/backend-database";
import { AuthenticatedUser, JwtAccessTokenPayload, PlatformRole } from "@pauti-pustak/backend-security";
import { readFileSync } from "fs";
import { resolve } from "path";
import { ExtractJwt, Strategy } from "passport-jwt";

function loadPublicKey(): string {
  const keyPath = process.env.JWT_PUBLIC_KEY_PATH ?? "./config/certs/jwt_public.key";
  return readFileSync(resolve(process.cwd(), keyPath), "utf8");
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: loadPublicKey(),
      algorithms: ["RS256"],
    });
  }

  async validate(payload: JwtAccessTokenPayload): Promise<AuthenticatedUser> {
    const user = await this.prisma.user.findUnique({ where: { id: payload.sub } });

    if (!user) {
      throw new UnauthorizedException("Account no longer exists");
    }
    if (user.status !== "ACTIVE") {
      throw new UnauthorizedException("Account is inactive");
    }
    if (user.tokenVersion !== payload.tokenVersion) {
      throw new UnauthorizedException("Session has been invalidated, please login again");
    }

    return {
      userId: user.id,
      platformRole: payload.platformRole as PlatformRole,
      membershipId: payload.membershipId,
      organizationId: payload.organizationId,
      roleId: payload.roleId,
      sessionId: payload.sessionId,
      permissions: [],
    };
  }
}
