import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, CurrentUser, RequirePermission } from "@pauti-pustak/backend-security";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { RegisterDeviceTokenDto } from "./dto/register-device-token.dto";
import { CreateNotificationTemplateDto } from "./dto/create-notification-template.dto";
import { NotificationService } from "./notification.service";

@ApiTags("Multi-Channel Notifications")
@Controller("notifications")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Post("device-tokens")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Register or refresh FCM device token for push notifications" })
  async registerDeviceToken(@CurrentUser() user: AuthenticatedUser, @Body() dto: RegisterDeviceTokenDto) {
    const result = await this.notificationService.registerDeviceToken(user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Device token registered");
  }

  @Post("send")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("notification.send")
  @ApiOperation({ summary: "Dispatch multi-channel notification (WhatsApp, SMS, Email, Push, In-App)" })
  async sendNotification(
    @CurrentUser() user: AuthenticatedUser,
    @Body()
    body: {
      recipientMobile: string;
      recipientName: string;
      recipientEmail?: string;
      targetUserId?: string;
      channel: "WHATSAPP" | "SMS" | "EMAIL" | "PUSH" | "IN_APP";
      templateCode: string;
      languageCode?: string;
      templateVariables?: Record<string, any>;
    },
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.notificationService.sendNotification(user.organizationId, body);
    return createApiResponse(result, HttpStatus.OK, "Notification dispatched");
  }

  @Get("logs")
  @RequirePermission("notification.view")
  @ApiOperation({ summary: "List notification delivery status logs" })
  @ApiQuery({ name: "limit", required: false })
  async getDeliveryLogs(@CurrentUser() user: AuthenticatedUser, @Query("limit") limit?: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.notificationService.getDeliveryLogs(
      user.organizationId,
      limit ? parseInt(limit, 10) : 50,
    );
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get("inbox")
  @ApiOperation({ summary: "List user in-app notifications inbox feed" })
  @ApiQuery({ name: "unreadOnly", required: false })
  async getUserNotifications(@CurrentUser() user: AuthenticatedUser, @Query("unreadOnly") unreadOnly?: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.notificationService.getUserNotifications(
      user.organizationId,
      user.userId,
      unreadOnly === "true",
    );
    return createApiResponse(result, HttpStatus.OK);
  }

  @Patch("inbox/:id/read")
  @ApiOperation({ summary: "Mark in-app notification as read" })
  async markNotificationAsRead(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.notificationService.markNotificationAsRead(user.organizationId, user.userId, id);
    return createApiResponse(result, HttpStatus.OK, "Notification marked as read");
  }

  @Get("templates")
  @RequirePermission("notification.view")
  @ApiOperation({ summary: "List organization notification templates" })
  async listTemplates(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.notificationService.listTemplates(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post("templates")
  @RequirePermission("organization.update")
  @ApiOperation({ summary: "Create custom notification template" })
  async createTemplate(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateNotificationTemplateDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.notificationService.createTemplate(user.organizationId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Template created successfully");
  }
}
