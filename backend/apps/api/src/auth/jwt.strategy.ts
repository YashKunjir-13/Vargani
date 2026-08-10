import { Inject, Injectable, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { PrismaService } from "@pauti-pustak/backend-database";
import { AuthenticatedUser, JwtAccessTokenPayload, PlatformRole } from "@pauti-pustak/backend-security";
import { readFileSync } from "fs";
import { resolve } from "path";
import { ExtractJwt, Strategy } from "passport-jwt";

import { readKeyFile } from "./auth.module";

function loadPublicKey(): string {
  return readKeyFile("JWT_PUBLIC_KEY_PATH", "./config/certs/jwt_public.key", false);
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(@Inject(PrismaService) private readonly prisma: PrismaService) {
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

    let permissions: string[] = [];

    if (payload.platformRole === PlatformRole.SUPER_ADMIN) {
      permissions = ["*"];
    } else if (payload.roleId) {
      const role = await this.prisma.organizationRole.findUnique({
        where: { id: payload.roleId },
        include: { permissions: { include: { permission: true } } },
      });
      if (role?.isOwnerRole) {
        permissions = ["*"];
      } else if (role?.permissions) {
        permissions = role.permissions
          .filter((rp) => rp.permission?.isActive)
          .map((rp) => rp.permission.code);
      }
    } else if (payload.organizationId) {
      const membership = await this.prisma.organizationMembership.findFirst({
        where: {
          userId: user.id,
          organizationId: payload.organizationId,
          status: "ACTIVE",
        },
        include: { role: { include: { permissions: { include: { permission: true } } } } },
      });

      if (membership?.isOwner || membership?.role?.isOwnerRole) {
        permissions = ["*"];
      } else if (membership?.role?.permissions) {
        permissions = membership.role.permissions
          .filter((rp) => rp.permission?.isActive)
          .map((rp) => rp.permission.code);
      }
    }

    return {
      userId: user.id,
      platformRole: payload.platformRole as PlatformRole,
      membershipId: payload.membershipId,
      organizationId: payload.organizationId,
      roleId: payload.roleId,
      sessionId: payload.sessionId,
      permissions,
    };
  }
}
