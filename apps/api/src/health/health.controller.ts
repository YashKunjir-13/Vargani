import { Controller, Get } from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";
import { HealthCheck, HealthCheckService, PrismaHealthIndicator } from "@nestjs/terminus";
import { PrismaService } from "@pauti-pustak/backend-database";

@ApiTags("Health")
@Controller("health")
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private prismaHealth: PrismaHealthIndicator,
    private prisma: PrismaService,
  ) {}

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
    return this.health.check([() => this.prismaHealth.pingCheck("database", this.prisma)]);
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
