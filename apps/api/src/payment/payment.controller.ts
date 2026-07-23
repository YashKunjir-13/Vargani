import { Controller, Get, HttpCode, HttpStatus } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("Payment Provider Orchestration")
@Controller("payments")
export class PaymentsController {
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Payment Provider Orchestration foundation placeholder" })
  async list() {
    return {
      message: "Payment Provider Orchestration foundation ready. Domain logic not yet implemented.",
      status: "skeleton",
    };
  }
}
