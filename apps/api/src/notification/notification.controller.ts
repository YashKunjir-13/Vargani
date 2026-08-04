import { Body, Controller, Get, HttpCode, HttpStatus, Post, Query, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, RequirePermission } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { NotificationService } from "./notification.service";

@ApiTags("Multi-Channel Notifications")
@Controller("notifications")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Post("send")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("notification.send")
  @ApiOperation({ summary: "Dispatch multi-channel notification (WhatsApp, SMS, Email)" })
  async sendNotification(
    @CurrentUser() user: AuthenticatedUser,
    @Body()
    body: {
      recipientMobile: string;
      recipientName: string;
      channel: "WHATSAPP" | "SMS" | "EMAIL";
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
}
