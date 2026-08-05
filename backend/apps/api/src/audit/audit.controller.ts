import { Controller, Get, HttpCode, HttpStatus } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("Append-Only Audit Logs")
@Controller("audit-logs")
export class AuditController {
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Append-Only Audit Logs foundation placeholder" })
  async list() {
    return {
      message: "Append-Only Audit Logs foundation ready. Domain logic not yet implemented.",
      status: "skeleton",
    };
  }
}
