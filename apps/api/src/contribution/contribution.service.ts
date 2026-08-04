import {
  ConflictException,
  Inject,
  Injectable,
  NotFoundException,
  Optional,
} from "@nestjs/common";
import { DocumentPurpose, PrismaService } from "@pauti-pustak/backend-database";
import { TenantContext } from "../common/tenancy/tenant-context";
import { TenantScopedRepository } from "../common/tenancy/tenant-scoped.repository";
import { FestivalYearService } from "../common/festival-year/festival-year.service";
import { AssetStorageService } from "../common/storage/asset-storage.service";
import { CreateContributionDto, UpdateContributionDto } from "./contribution.dto";

@Injectable()
export class ContributionsRepository extends TenantScopedRepository<any> {
  constructor(@Inject(PrismaService) prisma: PrismaService, @Inject(TenantContext) tenantContext: TenantContext) {
    super(prisma.contribution, tenantContext);
  }
}

@Injectable()
export class ContributionsService {
  constructor(
    @Inject(ContributionsRepository) private readonly repository: ContributionsRepository,
    @Inject(FestivalYearService) private readonly festivalYearService: FestivalYearService,
    @Inject(TenantContext) private readonly tenantContext: TenantContext,
    @Optional() @Inject(AssetStorageService) private readonly assetStorage?: AssetStorageService,
  ) {}

  async uploadCertificatePhoto(file: { originalname: string; buffer: Buffer; mimetype: string }, userId: string) {
    if (!this.assetStorage) {
      throw new Error("AssetStorageService is not configured");
    }
    const orgId = this.tenantContext.organizationId;
    return this.assetStorage.uploadAsset({
      organizationId: orgId,
      ownerUserId: userId,
      purpose: DocumentPurpose.IN_KIND_ATTACHMENT,
      filename: file.originalname,
      body: file.buffer,
      contentType: file.mimetype,
    });
  }

  async create(dto: CreateContributionDto, userId: string) {
    const orgId = this.tenantContext.organizationId;
    const activeYearInfo = await this.festivalYearService.getActiveFestivalYear(orgId);
    const festivalYear = activeYearInfo.festivalYear;

    return this.repository.create({
      festivalYear,
      contributorId: dto.contributorId ?? null,
      contributorNameSnapshot: dto.contributorNameSnapshot,
      contactSnapshot: dto.contactSnapshot ?? null,
      date: dto.date ? new Date(dto.date) : new Date(),
      donationType: dto.donationType,
      itemDescription: dto.itemDescription ?? null,
      weight: dto.weight ?? null,
      estimatedValue: dto.estimatedValue ?? null,
      certificatePhotoUrl: dto.certificatePhotoUrl ?? null,
      recordedBy: userId,
      status: "RECORDED",
    });
  }

  async findAll() {
    return this.repository.findMany({
      orderBy: { createdAt: "desc" },
    });
  }

  async findOne(id: string) {
    const contribution = await this.repository.findOwnedUnique({ id });
    if (!contribution) {
      throw new NotFoundException(`Contribution ${id} not found`);
    }
    return contribution;
  }

  async update(id: string, dto: UpdateContributionDto) {
    const existing = await this.findOne(id);
    if (existing.status !== "RECORDED") {
      throw new ConflictException(
        `Cannot edit contribution in ${existing.status} status; only RECORDED contributions may be updated`,
      );
    }

    return this.repository.update(
      { id },
      {
        ...(dto.contributorNameSnapshot && { contributorNameSnapshot: dto.contributorNameSnapshot }),
        ...(dto.contactSnapshot !== undefined && { contactSnapshot: dto.contactSnapshot }),
        ...(dto.donationType && { donationType: dto.donationType }),
        ...(dto.itemDescription !== undefined && { itemDescription: dto.itemDescription }),
        ...(dto.weight !== undefined && { weight: dto.weight }),
        ...(dto.estimatedValue !== undefined && { estimatedValue: dto.estimatedValue }),
        ...(dto.certificatePhotoUrl !== undefined && { certificatePhotoUrl: dto.certificatePhotoUrl }),
      },
    );
  }

  async delete(id: string) {
    const existing = await this.findOne(id);
    if (existing.status !== "RECORDED") {
      throw new ConflictException(
        `Cannot delete contribution in ${existing.status} status; only RECORDED contributions may be deleted`,
      );
    }

    return this.repository.delete({ id });
  }

  async markReceipted(id: string) {
    return this.repository.update({ id }, { status: "RECEIPTED" });
  }
}
