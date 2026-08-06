import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  UseGuards,
} from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import { AuthenticatedUser, PermissionGuard, RequirePermission, TenantGuard } from "@pauti-pustak/backend-security";
import { CurrentUser } from "@pauti-pustak/backend-security";
import {
  GenerateContributionReceiptDto,
  VoidContributionReceiptDto,
} from "./contribution-receipts.dto";
import { ContributionReceiptsService } from "./contribution-receipts.service";

@ApiTags("Contribution Receipts")
@Controller("contribution-receipts")
@UseGuards(TenantGuard, PermissionGuard)
export class ContributionReceiptsController {
  constructor(private readonly service: ContributionReceiptsService) {}

  @Post("generate")
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission("receipt.viewAll")
  @ApiOperation({ summary: "Auto-generate contribution receipt for a finalized contribution" })
  async generate(@Body() dto: GenerateContributionReceiptDto) {
    return this.service.generate(dto.contributionId);
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @RequirePermission("receipt.viewAll")
  @ApiOperation({ summary: "List all contribution receipts" })
  async findAll() {
    return this.service.findAll();
  }

  @Get("my-history")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("receipt.viewOwn")
  @ApiOperation({ summary: "Get own contribution receipt history" })
  async findMyHistory(@CurrentUser() user: AuthenticatedUser) {
    const userId = user.userId || (user as any).id;
    return this.service.findMyHistory(userId);
  }

  @Get(":id")
  @HttpCode(HttpStatus.OK)
  @RequirePermission(["receipt.viewAll", "receipt.viewOwn"])
  @ApiOperation({ summary: "Get details of a contribution receipt" })
  async findOne(@Param("id") id: string) {
    return this.service.findOne(id);
  }

  @Post(":id/resend-whatsapp")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("receipt.viewAll")
  @ApiOperation({ summary: "Resend contribution receipt via WhatsApp" })
  async resendWhatsApp(@Param("id") id: string) {
    return this.service.resendWhatsApp(id);
  }

  @Post(":id/void")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("receipt.void")
  @ApiOperation({ summary: "Void a contribution receipt (Requires mandatory reason + audit log)" })
  async voidReceipt(
    @Param("id") id: string,
    @Body() dto: VoidContributionReceiptDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    const userId = user.userId || (user as any).id;
    return this.service.voidReceipt(id, dto.reason, userId);
  }
}

