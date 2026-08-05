import { Body, Controller, Get, HttpCode, HttpStatus, Patch, Post, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, Public } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../../auth/current-user.decorator";
import { JwtAuthGuard } from "../../auth/jwt-auth.guard";
import { AuthService } from "../../auth/auth.service";
import { RegisterTrustDto } from "../../auth/dto/register-trust.dto";
import { CloseOrganizationDto } from "./dto/close-organization.dto";
import { ConfigureBankingDto } from "./dto/configure-banking.dto";
import { UpdateOrganizationDto } from "./dto/update-organization.dto";
import { OrganizationsService } from "./organizations.service";

@ApiTags("Organization Management")
@Controller("organizations")
export class OrganizationsController {
  constructor(
    private readonly organizationsService: OrganizationsService,
    private readonly authService: AuthService,
  ) {}

  @Post("register")
  @Public()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: "Register active organization and initial Owner in one transaction" })
  async register(@Body() dto: RegisterTrustDto) {
    const result = await this.authService.registerTrust(dto);
    return createApiResponse(result, HttpStatus.CREATED, "Organization registered successfully");
  }

  @Get("current")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Retrieve active organization profile" })
  async getCurrent(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.organizationsService.getCurrent(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Patch("current")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Update permitted organization profile and legal fields" })
  async updateCurrent(@CurrentUser() user: AuthenticatedUser, @Body() dto: UpdateOrganizationDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.organizationsService.updateCurrent(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Organization updated successfully");
  }

  @Patch("current/banking")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Configure bank and UPI details with encryption" })
  async configureBanking(@CurrentUser() user: AuthenticatedUser, @Body() dto: ConfigureBankingDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.organizationsService.configureBanking(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Banking details updated successfully");
  }

  @Post("current/resubmit")
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Resubmit corrected organization information" })
  async resubmit(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.organizationsService.resubmit(user.organizationId, user.userId);
    return createApiResponse(result, HttpStatus.OK, "Organization resubmitted");
  }

  @Post("current/close")
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Close organization with mandatory reason" })
  async close(@CurrentUser() user: AuthenticatedUser, @Body() dto: CloseOrganizationDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.organizationsService.close(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Organization closed");
  }
}
