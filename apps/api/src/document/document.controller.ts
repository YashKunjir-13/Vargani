import { Controller, Get, HttpCode, HttpStatus } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("Documents, Vouchers, Redaction")
@Controller("documents")
export class DocumentsController {
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Documents, Vouchers, Redaction foundation placeholder" })
  async list() {
    return {
      message: "Documents, Vouchers, Redaction foundation ready. Domain logic not yet implemented.",
      status: "skeleton",
    };
  }
}
