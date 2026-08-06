import { Controller, Get, HttpStatus, Query, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, RequirePermission } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { DashboardService } from "./dashboard.service";

@ApiTags("Platform Role Dashboards")
@Controller("dashboards")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get("executive")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get Executive Dashboard KPIs (Owner, Admin)" })
  async getExecutiveDashboard(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.dashboardService.getExecutiveDashboard(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("finance")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get Finance & Treasury Dashboard (Treasurer, Finance Manager)" })
  async getFinanceDashboard(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.dashboardService.getFinanceDashboard(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("events")
  @RequirePermission("event.view")
  @ApiOperation({ summary: "Get Event Operations Dashboard (Event Manager)" })
  async getEventsDashboard(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.dashboardService.getEventsDashboard(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("volunteers")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get Field & Volunteer Operations Dashboard (Volunteer/Collector Manager)" })
  async getVolunteersDashboard(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.dashboardService.getVolunteersDashboard(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("operations")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get Desk Operations Dashboard (Receipt Operator, Data Entry Operator)" })
  async getOperationsDashboard(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.dashboardService.getOperationsDashboard(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("audit")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get Compliance & Audit Dashboard (Auditor)" })
  async getAuditDashboard(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.dashboardService.getAuditDashboard(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("executive/charts/financial-trend")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get 12-month monthly collections vs expenses financial trend chart data" })
  async getFinancialTrendChart(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.dashboardService.getFinancialTrendChart(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("finance/charts/mode-breakdown")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get collection mode percentage breakdown chart data" })
  async getModeBreakdownChart(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.dashboardService.getModeBreakdownChart(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("operations/recent")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get paginated recent operations collection stream table" })
  @ApiQuery({ name: "page", required: false })
  @ApiQuery({ name: "limit", required: false })
  @ApiQuery({ name: "mode", required: false })
  @ApiQuery({ name: "search", required: false })
  async getRecentOperationsStream(
    @CurrentUser() user: AuthenticatedUser,
    @Query("page") page?: number,
    @Query("limit") limit?: number,
    @Query("mode") mode?: string,
    @Query("search") search?: string,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.dashboardService.getRecentOperationsStream(user.organizationId, {
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
      mode,
      search,
    });
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("events/progress")
  @RequirePermission("event.view")
  @ApiOperation({ summary: "Get active events progress summary table dataset" })
  async getEventsProgressTable(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.dashboardService.getEventsProgressTable(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("audit/stream")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get paginated compliance audit trail stream table" })
  @ApiQuery({ name: "page", required: false })
  @ApiQuery({ name: "limit", required: false })
  @ApiQuery({ name: "actionType", required: false })
  async getAuditStream(
    @CurrentUser() user: AuthenticatedUser,
    @Query("page") page?: number,
    @Query("limit") limit?: number,
    @Query("actionType") actionType?: string,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.dashboardService.getAuditStream(user.organizationId, {
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
      actionType,
    });
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("volunteers/leaderboard")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get paginated volunteer collector performance leaderboard" })
  @ApiQuery({ name: "page", required: false })
  @ApiQuery({ name: "limit", required: false })
  async getVolunteersLeaderboard(
    @CurrentUser() user: AuthenticatedUser,
    @Query("page") page?: number,
    @Query("limit") limit?: number,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.dashboardService.getVolunteersLeaderboard(user.organizationId, {
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
    });
    return createApiResponse(result, HttpStatus.OK);
  }
}
