import { Body, Controller, Get, HttpCode, HttpStatus, Param, Patch, Post, Query, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, RequirePermission } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { CreateContributorAccountDto } from "./dto/create-contributor-account.dto";
import { MergeContributorAccountsDto } from "./dto/merge-contributor-accounts.dto";
import { ReassignCollectorDto } from "./dto/reassign-collector.dto";
import { UpdateContributorAccountDto } from "./dto/update-contributor-account.dto";
import { ContributorService } from "./contributor.service";

@ApiTags("Contributor Accounts")
@Controller()
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ContributorController {
  constructor(private readonly contributorService: ContributorService) {}

  @Get("events/:eventId/contributor-accounts")
  @RequirePermission("contributor.view")
  @ApiOperation({ summary: "Search and filter event contributor accounts" })
  @ApiQuery({ name: "areaCode", required: false })
  @ApiQuery({ name: "routeCode", required: false })
  @ApiQuery({ name: "assignedVolunteerId", required: false })
  async listAccounts(
    @CurrentUser() user: AuthenticatedUser,
    @Param("eventId") eventId: string,
    @Query("areaCode") areaCode?: string,
    @Query("routeCode") routeCode?: string,
    @Query("assignedVolunteerId") assignedVolunteerId?: string,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.contributorService.listAccounts(user.organizationId, eventId, {
      areaCode,
      routeCode,
      assignedVolunteerId,
    });
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post("events/:eventId/contributor-accounts")
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission("contributor.create")
  @ApiOperation({ summary: "Create event contributor account" })
  async createAccount(
    @CurrentUser() user: AuthenticatedUser,
    @Param("eventId") eventId: string,
    @Body() dto: CreateContributorAccountDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.contributorService.createAccount(user.organizationId, eventId, user.userId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Contributor account created");
  }

  @Patch("contributor-accounts/:id")
  @RequirePermission("contributor.update")
  @ApiOperation({ summary: "Update future-facing contributor account details" })
  async updateAccount(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: UpdateContributorAccountDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.contributorService.updateAccount(user.organizationId, id, dto);
    return createApiResponse(result, HttpStatus.OK, "Contributor account updated");
  }

  @Post("contributor-accounts/:id/reassign")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("contributor.assign")
  @ApiOperation({ summary: "Assign or reassign collector prospectively" })
  async reassignCollector(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: ReassignCollectorDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.contributorService.reassignCollector(
      user.organizationId,
      id,
      dto.assignedVolunteerId,
    );
    return createApiResponse(result, HttpStatus.OK, "Collector reassigned prospectively");
  }

  @Post("contributor-accounts/merge-preview")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("contributor.merge")
  @ApiOperation({ summary: "Preview duplicate contributor account merge impact" })
  async mergePreview(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: { survivingAccountId: string; mergedAccountId: string },
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.contributorService.mergePreview(
      user.organizationId,
      body.survivingAccountId,
      body.mergedAccountId,
    );
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post("contributor-accounts/merge")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("contributor.merge")
  @ApiOperation({ summary: "Merge duplicate contributor accounts transactionally" })
  async mergeAccounts(@CurrentUser() user: AuthenticatedUser, @Body() dto: MergeContributorAccountsDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.contributorService.mergeAccounts(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Contributor accounts merged");
  }
}
