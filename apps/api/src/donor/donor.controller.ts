import { Body, Controller, Get, HttpCode, HttpStatus, Param, Patch, Post, Query, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, PlatformRole, RequirePermission } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { CreateDonorDto } from "./dto/create-donor.dto";
import { MergeDonorsDto } from "./dto/merge-donors.dto";
import { UpdateDonorDto } from "./dto/update-donor.dto";
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
  @ApiOperation({ summary: "Search organization-related donors" })
  @ApiQuery({ name: "q", required: false })
  async searchDonors(@CurrentUser() user: AuthenticatedUser, @Query("q") q?: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.donorService.searchDonors(user.organizationId, q);
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
