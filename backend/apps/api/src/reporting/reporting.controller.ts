import { Controller, Get, HttpStatus, Param, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, RequirePermission } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { ReportingService } from "./reporting.service";

@ApiTags("Reporting & Analytics")
@Controller("reports")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ReportingController {
  constructor(private readonly reportingService: ReportingService) {}

  @Get("events/:eventId/summary")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get event financial summary report" })
  async getEventFinancialSummary(@CurrentUser() user: AuthenticatedUser, @Param("eventId") eventId: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.reportingService.getEventFinancialSummary(user.organizationId, eventId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("events/:eventId/daily-collections")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get daily collection mode breakdown report" })
  async getDailyCollectionReport(@CurrentUser() user: AuthenticatedUser, @Param("eventId") eventId: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.reportingService.getDailyCollectionReport(user.organizationId, eventId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("events/:eventId/volunteers")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get volunteer collector performance report" })
  async getVolunteerPerformanceReport(@CurrentUser() user: AuthenticatedUser, @Param("eventId") eventId: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.reportingService.getVolunteerPerformanceReport(user.organizationId, eventId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("events/:eventId/tax-exemptions")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get 80G tax exemption donor summary report" })
  async getTaxExemptionReport(@CurrentUser() user: AuthenticatedUser, @Param("eventId") eventId: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.reportingService.getTaxExemptionReport(user.organizationId, eventId);
    return createApiResponse(result, HttpStatus.OK);
  }
}
