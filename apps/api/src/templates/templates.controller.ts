import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
  UploadedFile,
  UseInterceptors,
} from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import { TemplateType } from "@pauti-pustak/backend-database";
import { AuthenticatedUser, CurrentUser, RequirePermission } from "@pauti-pustak/backend-security";
import { TenantContext } from "../common/tenancy/tenant-context";
import { PatchFieldMapDto } from "./dto/patch-fieldmap.dto";
import { TemplatesService } from "./templates.service";

interface UploadedTemplateFile {
  originalname: string;
  mimetype: string;
  buffer: Buffer;
}

@ApiTags("Receipt & Bill Templates")
@Controller({ path: "templates", version: "1" })
export class TemplatesController {
  constructor(
    private readonly templatesService: TemplatesService,
    private readonly tenantContext: TenantContext,
  ) {}

  @Post("upload")
  @RequirePermission("template.upload")
  @UseInterceptors(FileInterceptor("file"))
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: "Upload a mandal's receipt design and enqueue field detection" })
  async upload(@UploadedFile() file: UploadedTemplateFile, @CurrentUser() user: AuthenticatedUser) {
    if (!file) {
      throw new BadRequestException("A receipt template file (JPG/PNG/PDF) is required");
    }

    return this.templatesService.uploadReceiptTemplate({
      organizationId: this.tenantContext.organizationId,
      uploadedByUserId: user.userId,
      filename: file.originalname,
      contentType: file.mimetype,
      body: file.buffer,
    });
  }

  @Get()
  @RequirePermission("template.upload")
  @ApiOperation({ summary: "List template versions, optionally filtered by templateType" })
  async list(@Query("templateType") templateType?: TemplateType) {
    return this.templatesService.list(this.tenantContext.organizationId, templateType);
  }

  @Get(":id")
  @RequirePermission("template.upload")
  @ApiOperation({ summary: "Get full template detail, including fieldMap" })
  async getById(@Param("id") id: string) {
    return this.templatesService.getById(this.tenantContext.organizationId, id);
  }

  @Patch(":id/fieldmap")
  @RequirePermission("template.upload")
  @ApiOperation({ summary: "Manually calibrate a template's fieldMap" })
  async patchFieldMap(@Param("id") id: string, @Body() dto: PatchFieldMapDto) {
    return this.templatesService.calibrateFieldMap(this.tenantContext.organizationId, id, dto.fieldMap);
  }

  @Patch(":id/activate")
  @RequirePermission("template.activate")
  @ApiOperation({ summary: "Activate a template version (deactivates the prior active version of the same type)" })
  async activate(@Param("id") id: string) {
    return this.templatesService.activate(this.tenantContext.organizationId, id);
  }

  @Delete(":id")
  @RequirePermission("template.upload")
  @ApiOperation({ summary: "Delete a template version (only if never used by an issued receipt)" })
  async delete(@Param("id") id: string) {
    await this.templatesService.delete(this.tenantContext.organizationId, id);
    return { deleted: true };
  }
}
