import { Controller, Get, HttpCode, HttpStatus } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("Reports, Exports, Public Transparency")
@Controller("reports")
export class ReportsController {
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Reports, Exports, Public Transparency foundation placeholder" })
  async list() {
    return {
      message: "Reports, Exports, Public Transparency foundation ready. Domain logic not yet implemented.",
      status: "skeleton",
    };
  }
}
