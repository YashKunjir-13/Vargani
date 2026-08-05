import { Body, Controller, Get, HttpCode, HttpStatus, Param, Patch, Post, Query, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, PlatformRole, RequirePermission } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { CreateDonorDto } from "./dto/create-donor.dto";
import { MergeDonorsDto } from "./dto/merge-donors.dto";
import { SelectOrganizationDto } from "./dto/select-organization.dto";
import { UpdateDonorDto } from "./dto/update-donor.dto";
import { CheckoutPaymentDto } from "./dto/checkout-payment.dto";
import { CreateContributorAccountDto } from "../contributor/dto/create-contributor-account.dto";
import { DonorService } from "./donor.service";

@ApiTags("Donor Profiles & Duplicate Merge")
@Controller()
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class DonorController {
  constructor(private readonly donorService: DonorService) {}

  @Post("donors")
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission("donor.create")
  @ApiOperation({ summary: "Create or match an offline/online donor profile" })
  async createDonor(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateDonorDto) {
    const result = await this.donorService.createDonor(user.userId, user.organizationId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Donor profile processed");
  }

  @Get("donors")
  @RequirePermission("donor.view")
  @ApiOperation({ summary: "Search organization-related donors with pagination" })
  @ApiQuery({ name: "q", required: false })
  @ApiQuery({ name: "page", required: false })
  @ApiQuery({ name: "limit", required: false })
  async searchDonors(
    @CurrentUser() user: AuthenticatedUser,
    @Query("q") q?: string,
    @Query("page") page?: number,
    @Query("limit") limit?: number,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.donorService.searchDonors(user.organizationId, q, {
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
    });
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("donors/:id/history")
  @RequirePermission("donor.view")
  @ApiOperation({ summary: "View complete organization-scoped history for a donor profile" })
  async getTrustDonorHistory(@CurrentUser() user: AuthenticatedUser, @Param("id") donorId: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.donorService.getTrustDonorHistory(user.organizationId, donorId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("donor/profile")
  @ApiOperation({ summary: "Retrieve logged-in user's self donor profile" })
  async getSelfProfile(@CurrentUser() user: AuthenticatedUser) {
    const result = await this.donorService.getSelfProfile(user.userId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Patch("donor/profile")
  @ApiOperation({ summary: "Update logged-in user's self donor profile details" })
  async updateSelfProfile(@CurrentUser() user: AuthenticatedUser, @Body() dto: UpdateDonorDto) {
    const result = await this.donorService.updateSelfProfile(user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Self donor profile updated successfully");
  }

  @Get("donor/organizations")
  @ApiOperation({ summary: "List all organizations (mandals) where donor has accounts/contributions" })
  async getDonorOrganizations(@CurrentUser() user: AuthenticatedUser) {
    const result = await this.donorService.getDonorOrganizations(user.userId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post("donor/organizations/select")
  @ApiOperation({ summary: "Select an active organization context for donor operations" })
  async selectOrganization(@CurrentUser() user: AuthenticatedUser, @Body() dto: SelectOrganizationDto) {
    const result = await this.donorService.selectOrganization(user.userId, dto.organizationId);
    return createApiResponse(result, HttpStatus.OK, "Organization context selected");
  }

  @Get("donor/events")
  @ApiOperation({ summary: "List active events for selected organization or all donor mandals" })
  @ApiQuery({ name: "organizationId", required: false })
  async getDonorEvents(
    @CurrentUser() user: AuthenticatedUser,
    @Query("organizationId") organizationId?: string,
  ) {
    const targetOrgId = organizationId || user.organizationId;
    const result = await this.donorService.getDonorEvents(user.userId, targetOrgId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("donor/contributor-accounts")
  @ApiOperation({ summary: "List donor's contributor accounts for an event/organization" })
  @ApiQuery({ name: "organizationId", required: false })
  @ApiQuery({ name: "eventId", required: false })
  async getDonorContributorAccounts(
    @CurrentUser() user: AuthenticatedUser,
    @Query("organizationId") organizationId?: string,
    @Query("eventId") eventId?: string,
  ) {
    const targetOrgId = organizationId || user.organizationId;
    const result = await this.donorService.getDonorContributorAccounts(user.userId, targetOrgId, eventId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post("donor/contributor-accounts")
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: "Create a new contributor account under an event for the donor" })
  @ApiQuery({ name: "organizationId", required: false })
  @ApiQuery({ name: "eventId", required: true })
  async createDonorContributorAccount(
    @CurrentUser() user: AuthenticatedUser,
    @Query("eventId") eventId: string,
    @Body() dto: CreateContributorAccountDto,
    @Query("organizationId") organizationId?: string,
  ) {
    const targetOrgId = organizationId || user.organizationId;
    if (!targetOrgId) {
      throw new Error("Organization ID is required");
    }
    const result = await this.donorService.createDonorContributorAccount(
      user.userId,
      targetOrgId,
      eventId,
      dto,
    );
    return createApiResponse(result, HttpStatus.CREATED, "Contributor account created");
  }

  @Get("donor/bills")
  @ApiOperation({ summary: "List pending/issued bills for logged-in donor's contributor accounts" })
  @ApiQuery({ name: "organizationId", required: false })
  async getDonorBills(
    @CurrentUser() user: AuthenticatedUser,
    @Query("organizationId") organizationId?: string,
  ) {
    const targetOrgId = organizationId || user.organizationId;
    const result = await this.donorService.getDonorBills(user.userId, targetOrgId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("donor/bills/:id")
  @ApiOperation({ summary: "Retrieve pending bill details (verifying donor ownership)" })
  async getDonorBillDetails(@CurrentUser() user: AuthenticatedUser, @Param("id") billId: string) {
    const result = await this.donorService.getDonorBillDetails(user.userId, billId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post("donor/payments/checkout")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Process online payment checkout for a pending bill or contribution" })
  async checkoutPayment(@CurrentUser() user: AuthenticatedUser, @Body() dto: CheckoutPaymentDto) {
    const result = await this.donorService.checkoutPayment(user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Payment processed successfully");
  }

  @Get("donor/receipts")
  @ApiOperation({ summary: "List confirmed contribution receipts for logged-in donor" })
  @ApiQuery({ name: "organizationId", required: false })
  async getDonorReceipts(
    @CurrentUser() user: AuthenticatedUser,
    @Query("organizationId") organizationId?: string,
  ) {
    const targetOrgId = organizationId || user.organizationId;
    const result = await this.donorService.getDonorReceipts(user.userId, targetOrgId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("donor/receipts/:id")
  @ApiOperation({ summary: "Retrieve receipt details (verifying donor ownership)" })
  async getDonorReceiptDetails(@CurrentUser() user: AuthenticatedUser, @Param("id") receiptId: string) {
    const result = await this.donorService.getDonorReceiptDetails(user.userId, receiptId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("donor/contributions")
  @ApiOperation({ summary: "Filterable contribution history stream for logged-in donor" })
  @ApiQuery({ name: "organizationId", required: false })
  @ApiQuery({ name: "eventId", required: false })
  async getDonorContributions(
    @CurrentUser() user: AuthenticatedUser,
    @Query("organizationId") organizationId?: string,
    @Query("eventId") eventId?: string,
  ) {
    const targetOrgId = organizationId || user.organizationId;
    const result = await this.donorService.getDonorContributions(user.userId, targetOrgId, eventId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("donor/dashboard")
  @ApiOperation({ summary: "Aggregated donor portal dashboard metrics" })
  async getDonorDashboard(@CurrentUser() user: AuthenticatedUser) {
    const result = await this.donorService.getDonorDashboard(user.userId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("donors/analytics")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Trust-wide donor analytics, top donors leaderboard, and mode breakdown" })
  async getTrustDonorAnalytics(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.donorService.getTrustDonorAnalytics(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("donors/me/history")
  @ApiOperation({ summary: "View own cross-organization private donation history" })
  async getOwnHistory(@CurrentUser() user: AuthenticatedUser) {
    const result = await this.donorService.getOwnHistory(user.userId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("donors/:id")
  @RequirePermission("donor.view")
  @ApiOperation({ summary: "Retrieve donor profile and scoped history" })
  async getDonor(@Param("id") id: string) {
    const result = await this.donorService.getDonor(id);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Patch("donors/:id")
  @RequirePermission("donor.update")
  @ApiOperation({ summary: "Update permitted donor profile fields" })
  async updateDonor(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: UpdateDonorDto,
  ) {
    const result = await this.donorService.updateDonor(id, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Donor profile updated");
  }

  @Post("platform/donors/merge")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Merge duplicate donor profiles transactionally (Platform Super Admin)" })
  async mergeDonors(@CurrentUser() user: AuthenticatedUser, @Body() dto: MergeDonorsDto) {
    if (user.platformRole !== PlatformRole.SUPER_ADMIN) {
      throw new Error("Forbidden: Platform Super Admin role required for profile merging");
    }
    const result = await this.donorService.mergeDonors(user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Donor profiles merged successfully");
  }
}
