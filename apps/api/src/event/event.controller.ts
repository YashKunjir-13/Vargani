import { Body, Controller, Get, HttpCode, HttpStatus, Param, Patch, Post, Query, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, RequirePermission } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { CreateEventDto } from "./dto/create-event.dto";
import { ReopenEventDto } from "./dto/reopen-event.dto";
import { UpdateEventDto } from "./dto/update-event.dto";
import { EventService } from "./event.service";

@ApiTags("Event Management")
@Controller("events")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class EventController {
  constructor(private readonly eventService: EventService) {}

  @Get()
  @RequirePermission("event.view")
  @ApiOperation({ summary: "List events with optional filters, search, and pagination" })
  @ApiQuery({ name: "status", required: false })
  @ApiQuery({ name: "financialYear", required: false })
  @ApiQuery({ name: "search", required: false })
  @ApiQuery({ name: "page", required: false })
  @ApiQuery({ name: "limit", required: false })
  async listEvents(
    @CurrentUser() user: AuthenticatedUser,
    @Query("status") status?: any,
    @Query("financialYear") financialYear?: string,
    @Query("search") search?: string,
    @Query("page") page?: string,
    @Query("limit") limit?: string,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.eventService.listEvents(user.organizationId, {
      status,
      financialYear: financialYear ? parseInt(financialYear, 10) : undefined,
      search,
      page: page ? parseInt(page, 10) : undefined,
      limit: limit ? parseInt(limit, 10) : undefined,
    });
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission("event.create")
  @ApiOperation({ summary: "Create draft event" })
  async createEvent(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateEventDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.eventService.createEvent(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Event created successfully");
  }

  @Get(":id")
  @RequirePermission("event.view")
  @ApiOperation({ summary: "Retrieve event and financial status" })
  async getEvent(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.eventService.getEvent(user.organizationId, id);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Patch(":id")
  @RequirePermission("event.update")
  @ApiOperation({ summary: "Update mutable event fields" })
  async updateEvent(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: UpdateEventDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.eventService.updateEvent(user.organizationId, id, dto);
    return createApiResponse(result, HttpStatus.OK, "Event updated successfully");
  }

  @Post(":id/activate")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Activate event (Owner)" })
  async activateEvent(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.eventService.activateEvent(user.organizationId, id, user.userId);
    return createApiResponse(result, HttpStatus.OK, "Event activated");
  }

  @Post(":id/complete")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Complete event (Owner)" })
  async completeEvent(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.eventService.completeEvent(user.organizationId, id, user.userId);
    return createApiResponse(result, HttpStatus.OK, "Event completed");
  }

  @Post(":id/financial-close")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Financially close event (Owner)" })
  async financialCloseEvent(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.eventService.financialCloseEvent(user.organizationId, id, user.userId);
    return createApiResponse(result, HttpStatus.OK, "Event financially closed");
  }

  @Post(":id/reopen")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Reopen financially closed event with reason (Owner)" })
  async reopenEvent(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: ReopenEventDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.eventService.reopenEvent(user.organizationId, id, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Event reopened");
  }

  @Post(":id/archive")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Archive event (Owner)" })
  async archiveEvent(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.eventService.archiveEvent(user.organizationId, id, user.userId);
    return createApiResponse(result, HttpStatus.OK, "Event archived");
  }
}
