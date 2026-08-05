import { Body, Controller, Get, HttpCode, HttpStatus, Param, Patch, Post, Query, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, RequirePermission } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { CreateAccountDto } from "./dto/create-account.dto";
import { CreateExpenseDto } from "./dto/create-expense.dto";
import { CreateLedgerTransactionDto } from "./dto/create-ledger-transaction.dto";
import { CreateVendorDto } from "./dto/create-vendor.dto";
import { PayExpenseDto } from "./dto/pay-expense.dto";
import { RejectExpenseDto } from "./dto/reject-expense.dto";
import { UpdateVendorDto } from "./dto/update-vendor.dto";
import { FinanceService } from "./finance.service";

@ApiTags("Finance & Double-Entry Ledger")
@Controller()
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class FinanceController {
  constructor(private readonly financeService: FinanceService) {}

  // ---------------------------------------------------------------------------
  // Vendors
  // ---------------------------------------------------------------------------

  @Get("vendors")
  @RequirePermission("vendor.view")
  @ApiOperation({ summary: "List organization vendors" })
  @ApiQuery({ name: "status", required: false })
  async listVendors(@CurrentUser() user: AuthenticatedUser, @Query("status") status?: any) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.financeService.listVendors(user.organizationId, status);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post("vendors")
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission("vendor.create")
  @ApiOperation({ summary: "Register new vendor" })
  async createVendor(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateVendorDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.financeService.createVendor(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Vendor registered");
  }

  @Get("vendors/:id")
  @RequirePermission("vendor.view")
  @ApiOperation({ summary: "Get vendor details" })
  async getVendor(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.financeService.getVendor(user.organizationId, id);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Patch("vendors/:id")
  @RequirePermission("vendor.update")
  @ApiOperation({ summary: "Update vendor master record" })
  async updateVendor(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: UpdateVendorDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.financeService.updateVendor(user.organizationId, id, dto);
    return createApiResponse(result, HttpStatus.OK, "Vendor updated");
  }

  // ---------------------------------------------------------------------------
  // Expenses
  // ---------------------------------------------------------------------------

  @Get("events/:eventId/expenses")
  @RequirePermission("expense.view")
  @ApiOperation({ summary: "List event expenses" })
  @ApiQuery({ name: "status", required: false })
  async listExpenses(
    @CurrentUser() user: AuthenticatedUser,
    @Param("eventId") eventId: string,
    @Query("status") status?: any,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.financeService.listExpenses(user.organizationId, eventId, status);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post("events/:eventId/expenses")
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission("expense.create")
  @ApiOperation({ summary: "Create event expense" })
  async createExpense(
    @CurrentUser() user: AuthenticatedUser,
    @Param("eventId") eventId: string,
    @Body() dto: CreateExpenseDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.financeService.createExpense(user.organizationId, eventId, user.userId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Expense created");
  }

  @Post("expenses/:id/approve")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("expense.approve")
  @ApiOperation({ summary: "Approve expense (with self-approval defense check)" })
  async approveExpense(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.financeService.approveExpense(user.organizationId, id, user.userId);
    return createApiResponse(result, HttpStatus.OK, "Expense approved");
  }

  @Post("expenses/:id/reject")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("expense.approve")
  @ApiOperation({ summary: "Reject expense with mandatory reason" })
  async rejectExpense(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: RejectExpenseDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.financeService.rejectExpense(user.organizationId, id, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Expense rejected");
  }

  @Post("expenses/:id/pay")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("expense.pay")
  @ApiOperation({ summary: "Pay approved expense & post double-entry ledger entry" })
  async payExpense(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: PayExpenseDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.financeService.payExpense(user.organizationId, id, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Expense payout recorded and ledger posted");
  }

  // ---------------------------------------------------------------------------
  // Financial Accounts & Double-Entry Ledger
  // ---------------------------------------------------------------------------

  @Get("accounts")
  @RequirePermission("finance.view")
  @ApiOperation({ summary: "List organization financial accounts" })
  async listAccounts(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.financeService.listAccounts(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post("accounts")
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission("finance.manage")
  @ApiOperation({ summary: "Create financial account (Bank, Cash, UPI)" })
  async createAccount(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateAccountDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.financeService.createAccount(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Financial account created");
  }

  @Post("ledger/entries")
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission("finance.manage")
  @ApiOperation({ summary: "Post balanced double-entry transaction" })
  async postLedgerTransaction(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateLedgerTransactionDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.financeService.postLedgerTransaction(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Ledger transaction posted");
  }

  @Get("ledger/trial-balance")
  @RequirePermission("finance.view")
  @ApiOperation({ summary: "Calculate trial balance debits and credits summary" })
  async getTrialBalance(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.financeService.getTrialBalance(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }
}
