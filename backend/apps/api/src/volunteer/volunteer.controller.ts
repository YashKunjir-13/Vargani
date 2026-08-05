import { Body, Controller, Get, HttpCode, HttpStatus, Param, Patch, Post, Query, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, RequirePermission } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { CreateAssignmentDto } from "./dto/create-assignment.dto";
import { CreateVolunteerDto } from "./dto/create-volunteer.dto";
import { EndAssignmentDto } from "./dto/end-assignment.dto";
import { LinkUserDto } from "./dto/link-user.dto";
import { SuspendVolunteerDto } from "./dto/suspend-volunteer.dto";
import { UpdateAssignmentDto } from "./dto/update-assignment.dto";
import { UpdateVolunteerDto } from "./dto/update-volunteer.dto";
import { VolunteerService } from "./volunteer.service";

@ApiTags("Volunteers & Assignments")
@Controller()
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class VolunteerController {
  constructor(private readonly volunteerService: VolunteerService) {}

  @Get("volunteers")
  @RequirePermission("volunteer.view")
  @ApiOperation({ summary: "List organization volunteers with status/type filter" })
  @ApiQuery({ name: "status", required: false })
  @ApiQuery({ name: "type", required: false })
  async listVolunteers(
    @CurrentUser() user: AuthenticatedUser,
    @Query("status") status?: any,
    @Query("type") type?: any,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.volunteerService.listVolunteers(user.organizationId, { status, type });
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post("volunteers")
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission("volunteer.create")
  @ApiOperation({ summary: "Register new volunteer master record" })
  async createVolunteer(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateVolunteerDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.volunteerService.createVolunteer(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Volunteer registered");
  }

  @Get("volunteers/:id")
  @RequirePermission("volunteer.view")
  @ApiOperation({ summary: "Retrieve volunteer details and active assignments" })
  async getVolunteer(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.volunteerService.getVolunteer(user.organizationId, id);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Patch("volunteers/:id")
  @RequirePermission("volunteer.update")
  @ApiOperation({ summary: "Update volunteer profile" })
  async updateVolunteer(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: UpdateVolunteerDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.volunteerService.updateVolunteer(user.organizationId, id, dto);
    return createApiResponse(result, HttpStatus.OK, "Volunteer updated");
  }

  @Post("volunteers/:id/activate")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("volunteer.manage")
  @ApiOperation({ summary: "Activate suspended or draft volunteer" })
  async activateVolunteer(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.volunteerService.activateVolunteer(user.organizationId, id);
    return createApiResponse(result, HttpStatus.OK, "Volunteer activated");
  }

  @Post("volunteers/:id/suspend")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("volunteer.manage")
  @ApiOperation({ summary: "Suspend volunteer and revoke active assignments" })
  async suspendVolunteer(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: SuspendVolunteerDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.volunteerService.suspendVolunteer(user.organizationId, id, dto);
    return createApiResponse(result, HttpStatus.OK, "Volunteer suspended");
  }

  @Post("volunteers/:id/link-user")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("volunteer.manage")
  @ApiOperation({ summary: "Link volunteer master record to identity user" })
  async linkUser(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: LinkUserDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.volunteerService.linkUser(user.organizationId, id, dto);
    return createApiResponse(result, HttpStatus.OK, "Volunteer linked to identity user");
  }

  @Post("events/:eventId/volunteer-assignments")
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission("volunteer.assignment.manage")
  @ApiOperation({ summary: "Assign volunteer scope and role to event" })
  async createAssignment(
    @CurrentUser() user: AuthenticatedUser,
    @Param("eventId") eventId: string,
    @Body() dto: CreateAssignmentDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.volunteerService.createAssignment(user.organizationId, eventId, user.userId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Volunteer assigned to event");
  }

  @Patch("volunteer-assignments/:id")
  @RequirePermission("volunteer.assignment.manage")
  @ApiOperation({ summary: "Update assignment timeline or notes" })
  async updateAssignment(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: UpdateAssignmentDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.volunteerService.updateAssignment(user.organizationId, id, dto);
    return createApiResponse(result, HttpStatus.OK, "Assignment updated");
  }

  @Post("volunteer-assignments/:id/end")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("volunteer.assignment.manage")
  @ApiOperation({ summary: "End volunteer scope assignment early" })
  async endAssignment(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: EndAssignmentDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.volunteerService.endAssignment(user.organizationId, id, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Assignment ended");
  }
}
