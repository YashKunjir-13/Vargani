import { Controller, Get, HttpCode, HttpStatus } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("Contribution Bills, Collections, Receipts")
@Controller("contributions")
export class ContributionsController {
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Contribution Bills, Collections, Receipts foundation placeholder" })
  async list() {
    return {
      message: "Contribution Bills, Collections, Receipts foundation ready. Domain logic not yet implemented.",
      status: "skeleton",
    };
  }
}
