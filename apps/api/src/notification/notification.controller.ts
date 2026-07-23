import { Controller, Get, HttpCode, HttpStatus } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("Multilingual Notifications")
@Controller("notifications")
export class NotificationsController {
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Multilingual Notifications foundation placeholder" })
  async list() {
    return {
      message: "Multilingual Notifications foundation ready. Domain logic not yet implemented.",
      status: "skeleton",
    };
  }
}
