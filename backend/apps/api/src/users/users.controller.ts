import { Body, Controller, Get, HttpCode, HttpStatus, Param, Patch, Post, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, PlatformRole, TenantOptional } from "@pauti-pustak/backend-security";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { CurrentUser } from "../auth/current-user.decorator";
import { ChangeContactDto } from "./dto/change-contact.dto";
import { UpdateUserProfileDto } from "./dto/update-user-profile.dto";
import { UpdateUserStatusDto } from "./dto/update-user-status.dto";
import { UsersService } from "./users.service";

@ApiTags("User Accounts")
@Controller()
@UseGuards(JwtAuthGuard)
@TenantOptional()
@ApiBearerAuth()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get("users/me")
  @ApiOperation({ summary: "Return authenticated user and active context" })
  async getMe(@CurrentUser() user: AuthenticatedUser) {
    const result = await this.usersService.getMe(user.userId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Patch("users/me")
  @ApiOperation({ summary: "Update display name, preferred language, and avatar" })
  async updateMe(@CurrentUser() user: AuthenticatedUser, @Body() dto: UpdateUserProfileDto) {
    const result = await this.usersService.updateMe(user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Profile updated successfully");
  }

  @Post("users/me/email/change")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Begin verified email change" })
  async changeEmail(@CurrentUser() user: AuthenticatedUser, @Body() dto: ChangeContactDto) {
    const result = await this.usersService.beginEmailChange(user.userId, dto);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post("users/me/mobile/change")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Begin verified mobile change" })
  async changeMobile(@CurrentUser() user: AuthenticatedUser, @Body() dto: ChangeContactDto) {
    const result = await this.usersService.beginMobileChange(user.userId, dto);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("platform/users/:id")
  @ApiOperation({ summary: "Retrieve safe administrative profile" })
  async getPlatformUser(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (user.platformRole !== PlatformRole.SUPER_ADMIN) {
      throw new Error("Forbidden: Platform Super Admin role required");
    }
    const result = await this.usersService.getPlatformUser(id);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Patch("platform/users/:id/status")
  @ApiOperation({ summary: "Deactivate or reactivate user account with mandatory reason" })
  async updatePlatformUserStatus(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: UpdateUserStatusDto,
  ) {
    if (user.platformRole !== PlatformRole.SUPER_ADMIN) {
      throw new Error("Forbidden: Platform Super Admin role required");
    }
    const result = await this.usersService.updatePlatformUserStatus(id, dto);
    return createApiResponse(result, HttpStatus.OK, "User status updated");
  }
}
