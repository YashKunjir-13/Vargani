import { Body, Controller, Get, HttpCode, HttpStatus, Post, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser } from "@pauti-pustak/backend-security";
import { AuthService } from "./auth.service";
import { CurrentUser } from "./current-user.decorator";
import { LoginDto } from "./dto/login.dto";
import { RefreshTokenDto } from "./dto/refresh-token.dto";
import { RegisterDonorDto } from "./dto/register-donor.dto";
import { RegisterTrustDto } from "./dto/register-trust.dto";
import { JwtAuthGuard } from "./jwt-auth.guard";

@ApiTags("Authentication")
@Controller("auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post("register/trust")
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: "Register a new Trust/Mandal organization and its owner account" })
  async registerTrust(@Body() dto: RegisterTrustDto) {
    const result = await this.authService.registerTrust(dto);
    return createApiResponse(result, HttpStatus.CREATED, "Trust registered successfully");
  }

  @Post("register/donor")
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: "Register a new donor account" })
  async registerDonor(@Body() dto: RegisterDonorDto) {
    const result = await this.authService.registerDonor(dto);
    return createApiResponse(result, HttpStatus.CREATED, "Donor registered successfully");
  }

  @Post("login")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Login with phone number and password" })
  async login(@Body() dto: LoginDto) {
    const result = await this.authService.login(dto);
    return createApiResponse(result, HttpStatus.OK, "Login successful");
  }

  @Post("refresh")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Exchange a refresh token for a new access token" })
  async refresh(@Body() dto: RefreshTokenDto) {
    const result = await this.authService.refresh(dto);
    return createApiResponse(result, HttpStatus.OK, "Session refreshed");
  }

  @Post("logout")
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Revoke the current refresh session" })
  async logout(@CurrentUser() user: AuthenticatedUser, @Body() dto: RefreshTokenDto) {
    const result = await this.authService.logout(user.userId, dto.refreshToken);
    return createApiResponse(result, HttpStatus.OK, "Logged out");
  }

  @Get("me")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get the current authenticated user's profile" })
  async me(@CurrentUser() user: AuthenticatedUser) {
    const result = await this.authService.getProfile(user.userId);
    return createApiResponse(result, HttpStatus.OK);
  }
}
