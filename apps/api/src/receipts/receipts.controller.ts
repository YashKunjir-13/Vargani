import { Body, Controller, Get, Param, Post, Query } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import { AuthenticatedUser, CurrentUser, RequirePermission } from "@pauti-pustak/backend-security";
import { TenantContext } from "../common/tenancy/tenant-context";
import { ListReceiptsQueryDto } from "./dto/list-receipts-query.dto";
import { VoidReceiptDto } from "./dto/void-receipt.dto";
import { ReceiptsService } from "./receipts.service";

/**
 * There is deliberately no POST /receipts/generate route: generation is
 * exclusively an in-process call from PaymentsService (via
 * ReceiptGenerationPort, implemented by ReceiptsService itself) the moment a
 * Payment transitions to Confirmed. Exposing an HTTP endpoint for it would
 * either require inventing an internal-service-auth mechanism that doesn't
 * exist elsewhere in this codebase, or leave a route reachable by ordinary
 * permission checks -- neither matches "not exposed for arbitrary user
 * calls". See ReceiptsService.generateReceipt / ReceiptsModule.
 */
@ApiTags("Receipt Generation")
@Controller({ path: "receipts", version: "1" })
export class ReceiptsController {
  constructor(
    private readonly receiptsService: ReceiptsService,
    private readonly tenantContext: TenantContext,
  ) {}

  @Get()
  @RequirePermission("receipt.viewAll")
  @ApiOperation({ summary: "List receipts org-wide, optionally filtered by donor/status/date range" })
  async list(@Query() query: ListReceiptsQueryDto) {
    return this.receiptsService.list(this.tenantContext.organizationId, query);
  }

  @Get("my-history")
  @RequirePermission("receipt.viewOwn")
  @ApiOperation({ summary: "The logged-in Donor's complete receipt history, regardless of WhatsApp delivery outcome" })
  async myHistory(@CurrentUser() user: AuthenticatedUser) {
    return this.receiptsService.myHistory(this.tenantContext.organizationId, user.userId);
  }

  @Get(":id")
  @RequirePermission(["receipt.viewAll", "receipt.viewOwn"])
  @ApiOperation({ summary: "Get a single receipt -- full org access for receipt.viewAll, own-only for receipt.viewOwn" })
  async getById(@Param("id") id: string, @CurrentUser() user: AuthenticatedUser) {
    return this.receiptsService.getById(
      this.tenantContext.organizationId,
      id,
      user.userId,
      user.permissions.includes("receipt.viewAll"),
    );
  }

  @Post(":id/resend-whatsapp")
  @RequirePermission("receipt.viewAll")
  @ApiOperation({ summary: "Manually retry WhatsApp delivery of the already-rendered receipt PDF" })
  async resendWhatsapp(@Param("id") id: string) {
    return this.receiptsService.resendWhatsapp(this.tenantContext.organizationId, id);
  }

  @Post(":id/void")
  @RequirePermission("receipt.void")
  @ApiOperation({ summary: "Void a receipt with a mandatory reason, logged to the audit trail" })
  async void(@Param("id") id: string, @Body() dto: VoidReceiptDto, @CurrentUser() user: AuthenticatedUser) {
    return this.receiptsService.void(this.tenantContext.organizationId, id, user.userId, dto.reason);
  }
}
