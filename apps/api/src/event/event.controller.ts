import { Controller, Get, HttpCode, HttpStatus } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("Event Management")
@Controller("events")
export class EventsController {
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Event Management foundation placeholder" })
  async list() {
    return {
      message: "Event Management foundation ready. Domain logic not yet implemented.",
      status: "skeleton",
    };
  }
}
