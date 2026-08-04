import { Body, Controller, Get, HttpCode, HttpStatus, Param, Patch, Post, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, Public } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../../auth/current-user.decorator";
import { JwtAuthGuard } from "../../auth/jwt-auth.guard";
import { AssignRoleDto } from "./dto/assign-role.dto";
import { CreateDirectMemberDto } from "./dto/create-direct-member.dto";
import { CreateInvitationDto } from "./dto/create-invitation.dto";
import { TransferOwnershipDto } from "./dto/transfer-ownership.dto";
import { UpdateMembershipStatusDto } from "./dto/update-membership-status.dto";
import { MembershipsService } from "./memberships.service";

@ApiTags("Organization Memberships & Invitations")
@Controller("memberships")
export class MembershipsController {
  constructor(private readonly membershipsService: MembershipsService) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "List organization members" })
  async listMembers(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.membershipsService.listMembers(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post("invitations")
  @HttpCode(HttpStatus.CREATED)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Invite member by mobile or email" })
  async createInvitation(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateInvitationDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.membershipsService.createInvitation(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Invitation created");
  }

  @Post("direct")
  @HttpCode(HttpStatus.CREATED)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Create or attach a member account directly" })
  async createDirectMember(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateDirectMemberDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.membershipsService.createDirectMember(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Member added successfully");
  }

  @Post("invitations/:token/accept")
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Accept member invitation" })
  async acceptInvitation(@CurrentUser() user: AuthenticatedUser, @Param("token") token: string) {
    const result = await this.membershipsService.acceptInvitation(token, user.userId);
    return createApiResponse(result, HttpStatus.OK, "Invitation accepted");
  }

  @Patch(":id/status")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Deactivate, reactivate, or remove membership" })
  async updateStatus(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: UpdateMembershipStatusDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.membershipsService.updateStatus(user.organizationId, id, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Membership status updated");
  }

  @Patch(":id/role")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Assign one role to member" })
  async assignRole(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: AssignRoleDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.membershipsService.assignRole(user.organizationId, id, user.userId, dto.roleId);
    return createApiResponse(result, HttpStatus.OK, "Role assigned");
  }

  @Post("transfer-ownership")
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Transfer organization ownership atomically" })
  async transferOwnership(@CurrentUser() user: AuthenticatedUser, @Body() dto: TransferOwnershipDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.membershipsService.transferOwnership(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Ownership transferred");
  }
}
