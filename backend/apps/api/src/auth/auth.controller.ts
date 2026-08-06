import { Body, Controller, Get, HttpCode, HttpStatus, Inject, Post, Req, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiBody, ApiOperation, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, Public } from "@pauti-pustak/backend-security";
import { Request } from "express";
import { AuthService } from "./auth.service";
import { CurrentUser } from "./current-user.decorator";
import { LoginDto } from "./dto/login.dto";
import { OtpRequestDto } from "./dto/otp-request.dto";
import { OtpVerifyDto } from "./dto/otp-verify.dto";
import { PasswordForgotDto } from "./dto/password-forgot.dto";
import { PasswordResetDto } from "./dto/password-reset.dto";
import { RefreshTokenDto } from "./dto/refresh-token.dto";
import { RegisterDonorDto } from "./dto/register-donor.dto";
import { RegisterTrustDto } from "./dto/register-trust.dto";
import { CreateMpinDto } from "./dto/create-mpin.dto";
import { LoginMpinDto } from "./dto/login-mpin.dto";
import { ChangeMpinDto } from "./dto/change-mpin.dto";
import { ForgotMpinDto } from "./dto/forgot-mpin.dto";
import { VerifyMpinResetDto } from "./dto/verify-mpin-reset.dto";
import { JwtAuthGuard } from "./jwt-auth.guard";

@ApiTags("Authentication")
@Controller("auth")
export class AuthController {
  constructor(@Inject(AuthService) private readonly authService: AuthService) {}

  @Post("otp/request")
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Create a rate-limited OTP challenge" })
  @ApiBody({ type: OtpRequestDto })
  async requestOtp(@Body() dto: OtpRequestDto, @Req() req: Request) {
    const result = await this.authService.requestOtp(dto, req.ip, req.headers["user-agent"]);
    return createApiResponse(result, HttpStatus.OK, "OTP challenge created");
  }

  @Post("otp/verify")
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Verify OTP and issue access/refresh sessions" })
  @ApiBody({ type: OtpVerifyDto })
  async verifyOtp(@Body() dto: OtpVerifyDto, @Req() req: Request) {
    const result = await this.authService.verifyOtp(dto, req.ip, req.headers["user-agent"]);
    return createApiResponse(result, HttpStatus.OK, "OTP verified successfully");
  }

  @Post("register/trust")
  @Public()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: "Register a new Trust/Mandal organization and its owner account" })
  @ApiBody({ type: RegisterTrustDto })
  async registerTrust(@Body() dto: RegisterTrustDto) {
    const result = await this.authService.registerTrust(dto);
    return createApiResponse(result, HttpStatus.CREATED, "Trust registered successfully");
  }

  @Post("register/donor")
  @Public()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: "Register a new donor account" })
  @ApiBody({ type: RegisterDonorDto })
  async registerDonor(@Body() dto: RegisterDonorDto) {
    const result = await this.authService.registerDonor(dto);
    return createApiResponse(result, HttpStatus.CREATED, "Donor registered successfully");
  }

  @Post("login")
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Authenticate verified email and password" })
  @ApiBody({ type: LoginDto })
  async login(@Body() dto: LoginDto, @Req() req: Request) {
    const result = await this.authService.login(dto, req.ip, req.headers["user-agent"]);
    return createApiResponse(result, HttpStatus.OK, "Login successful");
  }

  @Post("refresh")
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Rotate refresh token and issue new access token" })
  @ApiBody({ type: RefreshTokenDto })
  async refresh(@Body() dto: RefreshTokenDto, @Req() req: Request) {
    const result = await this.authService.refresh(dto, req.ip, req.headers["user-agent"]);
    return createApiResponse(result, HttpStatus.OK, "Session refreshed");
  }

  @Post("logout")
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Revoke the current session and clear cookie" })
  @ApiBody({ type: RefreshTokenDto })
  async logout(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: RefreshTokenDto,
    @Req() req: Request,
  ) {
    const result = await this.authService.logout(user.userId, dto.refreshToken, req.ip, req.headers["user-agent"]);
    return createApiResponse(result, HttpStatus.OK, "Logged out");
  }

  @Post("logout-all")
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Revoke all user sessions" })
  async logoutAll(
    @CurrentUser() user: AuthenticatedUser,
    @Req() req: Request,
  ) {
    const result = await this.authService.logoutAll(user.userId, req.ip, req.headers["user-agent"]);
    return createApiResponse(result, HttpStatus.OK, "All sessions revoked");
  }

  @Post("password/forgot")
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Create password-reset challenge" })
  @ApiBody({ type: PasswordForgotDto })
  async forgotPassword(@Body() dto: PasswordForgotDto, @Req() req: Request) {
    const result = await this.authService.forgotPassword(dto, req.ip, req.headers["user-agent"]);
    return createApiResponse(result, HttpStatus.OK, "Reset instructions sent if account exists");
  }

  @Post("password/reset")
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Reset password and revoke active sessions" })
  @ApiBody({ type: PasswordResetDto })
  async resetPassword(@Body() dto: PasswordResetDto, @Req() req: Request) {
    const result = await this.authService.resetPassword(dto, req.ip, req.headers["user-agent"]);
    return createApiResponse(result, HttpStatus.OK, "Password reset successfully");
  }

  @Post("mpin/create")
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Create 6-digit MPIN for authenticated user" })
  @ApiBody({ type: CreateMpinDto })
  async createMpin(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateMpinDto) {
    const result = await this.authService.createMpin(user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "MPIN created successfully");
  }

  @Post("mpin/login")
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Authenticate with mobile number and MPIN" })
  @ApiBody({ type: LoginMpinDto })
  async loginMpin(@Body() dto: LoginMpinDto, @Req() req: Request) {
    const result = await this.authService.loginMpin(dto, req.ip, req.headers["user-agent"]);
    return createApiResponse(result, HttpStatus.OK, "MPIN login successful");
  }

  @Post("mpin/change")
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Change MPIN for authenticated user" })
  @ApiBody({ type: ChangeMpinDto })
  async changeMpin(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: ChangeMpinDto,
    @Req() req: Request,
  ) {
    const result = await this.authService.changeMpin(user.userId, dto, req.ip, req.headers["user-agent"]);
    return createApiResponse(result, HttpStatus.OK, "MPIN changed successfully");
  }

  @Post("mpin/forgot")
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Initiate OTP challenge for MPIN reset" })
  @ApiBody({ type: ForgotMpinDto })
  async forgotMpin(@Body() dto: ForgotMpinDto, @Req() req: Request) {
    const result = await this.authService.forgotMpin(dto, req.ip, req.headers["user-agent"]);
    return createApiResponse(result, HttpStatus.OK, "MPIN reset OTP challenge created");
  }

  @Post("mpin/verify")
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Verify OTP and set new MPIN (Revokes active sessions)" })
  @ApiBody({ type: VerifyMpinResetDto })
  async verifyMpinReset(@Body() dto: VerifyMpinResetDto, @Req() req: Request) {
    const result = await this.authService.verifyMpinReset(dto, req.ip, req.headers["user-agent"]);
    return createApiResponse(result, HttpStatus.OK, "MPIN reset successfully");
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
