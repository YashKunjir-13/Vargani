import { Controller, Get, HttpCode, HttpStatus } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("Contributor Accounts")
@Controller("contributor-accounts")
export class ContributorsController {
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Contributor Accounts foundation placeholder" })
  async list() {
    return {
      message: "Contributor Accounts foundation ready. Domain logic not yet implemented.",
      status: "skeleton",
    };
  }
}
