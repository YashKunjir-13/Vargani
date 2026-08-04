import { Body, Controller, Get, HttpCode, HttpStatus, Param, Post, Query, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, PlatformRole } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { PlatformAdminService } from "./platform-admin.service";

@ApiTags("Platform Super Admin")
@Controller("platform/organizations")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class PlatformAdminController {
  constructor(private readonly platformAdminService: PlatformAdminService) {}

  @Get()
  @ApiOperation({ summary: "List all tenant organizations across platform (Platform Super Admin)" })
  @ApiQuery({ name: "status", required: false })
  async listAllOrganizations(@CurrentUser() user: AuthenticatedUser, @Query("status") status?: any) {
    this.assertSuperAdmin(user);
    const result = await this.platformAdminService.listAllOrganizations(status);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post(":id/approve")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Approve pending tenant organization registration (Platform Super Admin)" })
  async approveOrganization(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    this.assertSuperAdmin(user);
    const result = await this.platformAdminService.approveOrganization(id, user.userId);
    return createApiResponse(result, HttpStatus.OK, "Organization approved and activated");
  }

  @Post(":id/reject")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Reject pending tenant organization registration (Platform Super Admin)" })
  async rejectOrganization(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() body: { reason: string },
  ) {
    this.assertSuperAdmin(user);
    const result = await this.platformAdminService.rejectOrganization(id, user.userId, body.reason);
    return createApiResponse(result, HttpStatus.OK, "Organization registration rejected");
  }

  private assertSuperAdmin(user: AuthenticatedUser) {
    if (user.platformRole !== PlatformRole.SUPER_ADMIN) {
      throw new Error("Forbidden: Platform Super Admin role required");
    }
  }
}
