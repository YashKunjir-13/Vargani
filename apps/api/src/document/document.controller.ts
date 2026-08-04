import { Body, Controller, Get, HttpCode, HttpStatus, Param, Post, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, RequirePermission } from "@pauti-pustak/backend-security";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { DocumentPurpose } from "@pauti-pustak/backend-database";
import { DocumentService } from "./document.service";

@ApiTags("Document S3 Storage")
@Controller("documents")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class DocumentController {
  constructor(private readonly documentService: DocumentService) {}

  @Post("presigned-upload")
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission("document.upload")
  @ApiOperation({ summary: "Get short-lived S3 presigned upload URL" })
  async createPresignedUpload(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: { filename: string; contentType: string; purpose: DocumentPurpose },
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.documentService.createPresignedUpload(user.organizationId, user.userId, body);
    return createApiResponse(result, HttpStatus.CREATED, "Presigned upload URL generated");
  }

  @Get(":id/presigned-download")
  @RequirePermission("document.view")
  @ApiOperation({ summary: "Get short-lived S3 presigned download URL" })
  async getPresignedDownloadUrl(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.documentService.getPresignedDownloadUrl(user.organizationId, id);
    return createApiResponse(result, HttpStatus.OK);
  }
}
