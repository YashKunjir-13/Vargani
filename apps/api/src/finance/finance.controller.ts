import { Controller, Get, HttpCode, HttpStatus } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("Financial Accounts, Ledger, Expenses")
@Controller("accounts")
export class FinanceController {
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Financial Accounts, Ledger, Expenses foundation placeholder" })
  async list() {
    return {
      message: "Financial Accounts, Ledger, Expenses foundation ready. Domain logic not yet implemented.",
      status: "skeleton",
    };
  }
}
