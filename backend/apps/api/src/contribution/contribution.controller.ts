import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Inject,
  Param,
  Patch,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import { AuthenticatedUser, PermissionGuard, RequirePermission, TenantGuard } from "@pauti-pustak/backend-security";
import { CurrentUser } from "@pauti-pustak/backend-security";
import { CreateContributionDto, UpdateContributionDto } from "./contribution.dto";
import { ContributionsService } from "./contribution.service";

@ApiTags("Contributions")
@Controller("contributions")
@UseGuards(TenantGuard, PermissionGuard)
export class ContributionsController {
  constructor(@Inject(ContributionsService) private readonly service: ContributionsService) {}

  @Post("upload-certificate")
  @RequirePermission("contribution.create")
  @UseInterceptors(FileInterceptor("file"))
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: "Upload a Gold/Silver purity certificate photo to S3 asset storage" })
  async uploadCertificate(
    @UploadedFile() file: { originalname: string; buffer: Buffer; mimetype: string },
    @CurrentUser() user: AuthenticatedUser,
  ) {
    if (!file) {
      throw new BadRequestException("A certificate photo file is required");
    }
    const userId = user.userId || (user as any).id;
    return this.service.uploadCertificatePhoto(file, userId);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission("contribution.create")
  @ApiOperation({ summary: "Record a non-monetary contribution" })
  async create(@Body() dto: CreateContributionDto, @CurrentUser() user: AuthenticatedUser) {
    const userId = user.userId || (user as any).id;
    return this.service.create(dto, userId);
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @RequirePermission("contribution.create")
  @ApiOperation({ summary: "List all contributions for tenant" })
  async list() {
    return this.service.findAll();
  }

  @Get(":id")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("contribution.create")
  @ApiOperation({ summary: "Get details of a contribution" })
  async findOne(@Param("id") id: string) {
    return this.service.findOne(id);
  }

  @Patch(":id")
  @HttpCode(HttpStatus.OK)
  @RequirePermission("contribution.create")
  @ApiOperation({ summary: "Update a recorded contribution (Recorded status only)" })
  async update(@Param("id") id: string, @Body() dto: UpdateContributionDto) {
    return this.service.update(id, dto);
  }

  @Delete(":id")
  @HttpCode(HttpStatus.NO_CONTENT)
  @RequirePermission("contribution.delete")
  @ApiOperation({ summary: "Delete a recorded contribution (Treasurer/Trust President only)" })
  async delete(@Param("id") id: string) {
    await this.service.delete(id);
  }
}

