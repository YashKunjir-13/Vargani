import { Controller, Get, HttpCode, HttpStatus } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("Volunteer Management")
@Controller("volunteers")
export class VolunteersController {
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Volunteer Management foundation placeholder" })
  async list() {
    return {
      message: "Volunteer Management foundation ready. Domain logic not yet implemented.",
      status: "skeleton",
    };
  }
}
