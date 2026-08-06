import { Body, Controller, Get, HttpStatus, Patch, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, PlatformRole } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../../auth/current-user.decorator";
import { JwtAuthGuard } from "../../auth/jwt-auth.guard";
import { UpdateOrganizationSettingsDto } from "./dto/update-organization-settings.dto";
import { UpdatePlatformSettingsDto } from "./dto/update-platform-settings.dto";
import { SettingsService } from "./settings.service";

@ApiTags("Organization & Platform Settings")
@Controller()
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SettingsController {
  constructor(private readonly settingsService: SettingsService) {}

  @Get("settings")
  @ApiOperation({ summary: "Retrieve safe organization settings" })
  async getOrganizationSettings(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.settingsService.getOrganizationSettings(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Patch("settings")
  @ApiOperation({ summary: "Update organization settings with versioning and audit snapshot" })
  async updateOrganizationSettings(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateOrganizationSettingsDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.settingsService.updateOrganizationSettings(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Organization settings updated");
  }

  @Get("settings/history")
  @ApiOperation({ summary: "View organization settings history" })
  async getSettingsHistory(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.settingsService.getSettingsHistory(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("platform/settings")
  @ApiOperation({ summary: "Retrieve platform settings" })
  async getPlatformSettings(@CurrentUser() user: AuthenticatedUser) {
    if (user.platformRole !== PlatformRole.SUPER_ADMIN) {
      throw new Error("Forbidden: Platform Super Admin role required");
    }
    const result = await this.settingsService.getPlatformSettings();
    return createApiResponse(result, HttpStatus.OK);
  }

  @Patch("platform/settings")
  @ApiOperation({ summary: "Create new platform settings version" })
  async updatePlatformSettings(@CurrentUser() user: AuthenticatedUser, @Body() dto: UpdatePlatformSettingsDto) {
    if (user.platformRole !== PlatformRole.SUPER_ADMIN) {
      throw new Error("Forbidden: Platform Super Admin role required");
    }
    const result = await this.settingsService.updatePlatformSettings(user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Platform settings updated");
  }
}
