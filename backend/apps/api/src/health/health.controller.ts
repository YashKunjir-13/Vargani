import { Controller, Get } from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";
import { HealthCheck, HealthCheckService, PrismaHealthIndicator } from "@nestjs/terminus";
import { PrismaService } from "@pauti-pustak/backend-database";
import { Public } from "@pauti-pustak/backend-security";

@ApiTags("Health")
@Controller("health")
@Public()
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private prismaHealth: PrismaHealthIndicator,
    private prisma: PrismaService,
  ) {}

  @Get()
  @HealthCheck()
  check() {
    return {
      status: "ok",
      timestamp: new Date().toISOString(),
      service: "api-gateway",
    };
  }

  @Get("live")
  @HealthCheck()
  checkLive() {
    return {
      status: "ok",
      timestamp: new Date().toISOString(),
      service: "api-gateway",
    };
  }

  @Get("ready")
  @HealthCheck()
  checkReady() {
    return this.health.check([() => this.prismaHealth.pingCheck("database", this.prisma as any)]);
  }

  @Get("startup")
  @HealthCheck()
  checkStartup() {
    return {
      status: "ok",
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
    };
  }
}
