import { Body, Controller, Get, Inject, Param, Patch, Post, Query } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import { AuthenticatedUser, CurrentUser, RequirePermission } from "@pauti-pustak/backend-security";
import { TenantContext } from "../common/tenancy/tenant-context";
import { BillsService } from "./bills.service";
import { CancelBillDto } from "./dto/cancel-bill.dto";
import { CreateBillDto } from "./dto/create-bill.dto";
import { ListBillsQueryDto } from "./dto/list-bills-query.dto";
import { MarkPaidBillDto } from "./dto/mark-paid-bill.dto";
import { RejectBillDto } from "./dto/reject-bill.dto";
import { UpdateBillDto } from "./dto/update-bill.dto";

const VIEW_PERMISSIONS = ["bill.create", "bill.approve"];

/**
 * There is no HTTP route for OCR pre-fill: BillsService.previewOcr is a
 * pure, read-only hook (see bill-ocr.port.ts) meant to be called by a
 * client before it ever assembles a POST /bills payload -- the product
 * spec's 9 endpoints don't list it, and exposing it separately would add
 * an authenticated route that touches no bill and enforces no workflow
 * rule, which isn't this module's concern.
 */
@ApiTags("Bill Generation")
@Controller({ path: "bills", version: "1" })
export class BillsController {
  constructor(
    @Inject(BillsService) private readonly billsService: BillsService,
    @Inject(TenantContext) private readonly tenantContext: TenantContext,
  ) {}

  @Post()
  @RequirePermission("bill.create")
  @ApiOperation({ summary: "Draft a new bill against a registered vendor or an ad-hoc receiver" })
  async create(@Body() dto: CreateBillDto, @CurrentUser() user: AuthenticatedUser) {
    return this.billsService.create(this.tenantContext.organizationId, user.userId, dto);
  }

  @Get()
  @RequirePermission(VIEW_PERMISSIONS)
  @ApiOperation({ summary: "List bills, optionally filtered by status/vendor/task/date range" })
  async list(@Query() query: ListBillsQueryDto) {
    return this.billsService.list(this.tenantContext.organizationId, query);
  }

  @Get(":id")
  @RequirePermission(VIEW_PERMISSIONS)
  @ApiOperation({ summary: "Get a single bill" })
  async getById(@Param("id") id: string) {
    return this.billsService.getById(this.tenantContext.organizationId, id);
  }

  @Patch(":id")
  @RequirePermission("bill.create")
  @ApiOperation({ summary: "Edit a bill -- only while Draft" })
  async update(@Param("id") id: string, @Body() dto: UpdateBillDto) {
    return this.billsService.update(this.tenantContext.organizationId, id, dto);
  }

  @Patch(":id/submit")
  @RequirePermission("bill.create")
  @ApiOperation({ summary: "Draft -> Pending Approval" })
  async submit(@Param("id") id: string) {
    return this.billsService.submit(this.tenantContext.organizationId, id);
  }

  @Patch(":id/approve")
  @RequirePermission("bill.approve")
  @ApiOperation({ summary: "Pending Approval -> Approved -- the creator can never also be the approver" })
  async approve(@Param("id") id: string, @CurrentUser() user: AuthenticatedUser) {
    return this.billsService.approve(this.tenantContext.organizationId, id, user.userId);
  }

  @Patch(":id/reject")
  @RequirePermission("bill.approve")
  @ApiOperation({ summary: "Pending Approval -> Draft, with a mandatory reason" })
  async reject(@Param("id") id: string, @Body() dto: RejectBillDto, @CurrentUser() user: AuthenticatedUser) {
    return this.billsService.reject(this.tenantContext.organizationId, id, user.userId, dto.reason);
  }

  @Patch(":id/mark-paid")
  @RequirePermission("bill.pay")
  @ApiOperation({ summary: "Approved -> Paid, recording the actual disbursement mode" })
  async markPaid(@Param("id") id: string, @Body() dto: MarkPaidBillDto, @CurrentUser() user: AuthenticatedUser) {
    return this.billsService.markPaid(this.tenantContext.organizationId, id, user.userId, dto.paymentMode);
  }

  @Post(":id/cancel")
  @RequirePermission("bill.approve")
  @ApiOperation({ summary: "Cancel a bill (including a Paid one) with a mandatory reason, audit-logged" })
  async cancel(@Param("id") id: string, @Body() dto: CancelBillDto, @CurrentUser() user: AuthenticatedUser) {
    return this.billsService.cancel(this.tenantContext.organizationId, id, user.userId, dto.reason);
  }
}
