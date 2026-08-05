import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  UseGuards,
} from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { createApiResponse } from "@pauti-pustak/backend-contracts";
import { AuthenticatedUser, CurrentUser, RequirePermission } from "@pauti-pustak/backend-security";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { CreatePresignedUploadDto } from "./dto/create-presigned-upload.dto";
import { ConfirmUploadDto } from "./dto/confirm-upload.dto";
import { ReplaceDocumentDto } from "./dto/replace-document.dto";
import { DocumentService } from "./document.service";

@ApiTags("Document Management")
@Controller("documents")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class DocumentController {
  constructor(private readonly documentService: DocumentService) {}

  @Post("presigned-upload")
  @RequirePermission("organization.update")
  @ApiOperation({ summary: "Generate presigned upload URL with SHA256 duplicate detection" })
  async createPresignedUpload(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreatePresignedUploadDto) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.documentService.createPresignedUpload(user.organizationId, user.userId, dto);
    return createApiResponse(result, HttpStatus.CREATED, "Presigned upload URL generated");
  }

  @Post(":id/confirm")
  @RequirePermission("organization.update")
  @ApiOperation({ summary: "Confirm document upload with actual file size & SHA256 checksum" })
  async confirmUpload(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: ConfirmUploadDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.documentService.confirmUpload(user.organizationId, id, dto);
    return createApiResponse(result, HttpStatus.OK, "Document upload confirmed");
  }

  @Get("stats")
  @RequirePermission("report.view")
  @ApiOperation({ summary: "Get organization document storage volume & purpose statistics" })
  async getDocumentStats(@CurrentUser() user: AuthenticatedUser) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.documentService.getDocumentStats(user.organizationId);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get(":id/presigned-download")
  @ApiOperation({ summary: "Get presigned download URL for document asset" })
  async getPresignedDownloadUrl(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.documentService.getPresignedDownloadUrl(user.organizationId, id);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Get(":id/preview")
  @ApiOperation({ summary: "Get inline preview metadata and URL for images and PDFs" })
  async previewDocument(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.documentService.previewDocument(user.organizationId, id);
    return createApiResponse(result, HttpStatus.OK);
  }

  @Post(":id/replace")
  @RequirePermission("organization.update")
  @ApiOperation({ summary: "Replace document with a new version and archive previous version" })
  async replaceDocument(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: ReplaceDocumentDto,
  ) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.documentService.replaceDocument(user.organizationId, id, user.userId, dto);
    return createApiResponse(result, HttpStatus.OK, "Document replacement initiated");
  }

  @Delete(":id")
  @RequirePermission("organization.update")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Delete and archive document asset" })
  async deleteDocument(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    if (!user.organizationId) {
      throw new Error("No organization context present");
    }
    const result = await this.documentService.deleteDocument(user.organizationId, id);
    return createApiResponse(result, HttpStatus.OK, "Document deleted and archived");
  }
}
