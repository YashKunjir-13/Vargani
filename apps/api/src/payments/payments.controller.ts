import {
  Body,
  Controller,
  Get,
  Headers,
  HttpCode,
  HttpStatus,
  Inject,
  Param,
  Patch,
  Post,
  Query,
  RawBodyRequest,
  Req,
  UnauthorizedException,
} from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import { AuthenticatedUser, CurrentUser, Public, RequirePermission } from "@pauti-pustak/backend-security";
import type { Request } from "express";
import { TenantContext } from "../common/tenancy/tenant-context";
import { CreatePaymentDto } from "./dto/create-payment.dto";
import { ListPaymentsQueryDto } from "./dto/list-payments-query.dto";
import { UpdatePaymentDto } from "./dto/update-payment.dto";
import { VoidPaymentDto } from "./dto/void-payment.dto";
import { PaymentsService } from "./payments.service";
import { RAZORPAY_SIGNATURE_VERIFIER, RazorpaySignatureVerifier } from "./razorpay-signature.verifier";

@ApiTags("Payment Collection")
@Controller({ path: "payments", version: "1" })
export class PaymentsController {
  constructor(
    @Inject(PaymentsService) private readonly paymentsService: PaymentsService,
    @Inject(TenantContext) private readonly tenantContext: TenantContext,
    @Inject(RAZORPAY_SIGNATURE_VERIFIER) private readonly signatureVerifier: RazorpaySignatureVerifier,
  ) {}

  @Post("webhook/razorpay")
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Razorpay webhook -- auto-confirms the matching InApp payment, no manual step" })
  async razorpayWebhook(
    @Req() request: RawBodyRequest<Request>,
    @Headers("x-razorpay-signature") signature?: string,
  ) {
    if (!request.rawBody || !this.signatureVerifier.verify(request.rawBody, signature)) {
      throw new UnauthorizedException("Invalid Razorpay webhook signature");
    }

    await this.paymentsService.handleRazorpayWebhook(request.body);
    return { received: true };
  }

  @Post()
  @RequirePermission("payment.create")
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: "Create an InApp order stub or a manual QR-code collection entry" })
  async create(@Body() dto: CreatePaymentDto, @CurrentUser() user: AuthenticatedUser) {
    return this.paymentsService.createPayment(this.tenantContext.organizationId, user.userId, dto);
  }

  @Get()
  @RequirePermission("payment.view")
  @ApiOperation({ summary: "List payments, optionally filtered by status/donor/channel/date range" })
  async list(@Query() query: ListPaymentsQueryDto) {
    return this.paymentsService.list(this.tenantContext.organizationId, query);
  }

  @Get(":id")
  @RequirePermission("payment.view")
  @ApiOperation({ summary: "Get a single payment" })
  async getById(@Param("id") id: string) {
    return this.paymentsService.getById(this.tenantContext.organizationId, id);
  }

  @Patch(":id")
  @RequirePermission("payment.create")
  @ApiOperation({ summary: "Edit address/contact -- blocked once the payment is Confirmed or later" })
  async update(@Param("id") id: string, @Body() dto: UpdatePaymentDto) {
    return this.paymentsService.update(this.tenantContext.organizationId, id, dto);
  }

  @Patch(":id/confirm-match")
  @RequirePermission("payment.confirmMatch")
  @ApiOperation({ summary: "Pending Match -> Confirmed after manual bank-statement review; triggers Receipt Generation" })
  async confirmMatch(@Param("id") id: string, @CurrentUser() user: AuthenticatedUser) {
    return this.paymentsService.confirmMatch(this.tenantContext.organizationId, id, user.userId);
  }

  @Post(":id/void")
  @RequirePermission("payment.confirmMatch")
  @ApiOperation({ summary: "Void a payment with a mandatory reason, logged to the audit trail" })
  async void(@Param("id") id: string, @Body() dto: VoidPaymentDto, @CurrentUser() user: AuthenticatedUser) {
    return this.paymentsService.void(this.tenantContext.organizationId, id, user.userId, dto.reason);
  }
}
