import { ForbiddenException, Inject, Injectable, Logger, NotFoundException } from "@nestjs/common";
import {
  DocumentPurpose,
  Prisma,
  PrismaService,
  TemplateDetectionStatus,
  TemplateType,
} from "@pauti-pustak/backend-database";
import { AssetStorageService } from "../common/storage/asset-storage.service";
import { SequenceCounterService } from "../common/sequence/sequence-counter.service";
import { FIELD_DETECTION_ENGINE, FieldDetectionEngine, FieldDetectionResult } from "./field-detection.engine";
import { validateFieldMap } from "./field-map.validator";

// Templates are not scoped to a festival year -- they carry over across
// years until replaced. The shared SequenceCounter is keyed by
// (organizationId, festivalYear, sequenceName), so this fixed sentinel lets
// templates reuse that same atomic counter for organizationId+templateType
// versioning without introducing a second counter mechanism.
const TEMPLATE_SEQUENCE_FESTIVAL_YEAR = 0;

export interface UploadReceiptTemplateParams {
  organizationId: string;
  uploadedByUserId: string;
  filename: string;
  contentType: string;
  body: Buffer;
}

@Injectable()
export class TemplatesService {
  private readonly logger = new Logger(TemplatesService.name);

  constructor(
    @Inject(PrismaService) private readonly prisma: PrismaService,
    @Inject(AssetStorageService) private readonly assetStorage: AssetStorageService,
    @Inject(SequenceCounterService) private readonly sequenceCounter: SequenceCounterService,
    @Inject(FIELD_DETECTION_ENGINE) private readonly detectionEngine: FieldDetectionEngine,
  ) {}

  /**
   * Uploads a mandal's receipt design and creates a new, Pending version.
   * Field detection is kicked off asynchronously (fire-and-forget relative
   * to this call) -- a detection failure never blocks or rolls back the
   * upload itself; it only prevents *activation* until re-upload or manual
   * calibration (see applyDetectionResult / activate).
   */
  async uploadReceiptTemplate(params: UploadReceiptTemplateParams) {
    const version = await this.nextVersion(params.organizationId, TemplateType.RECEIPT);

    const uploaded = await this.assetStorage.uploadAsset({
      organizationId: params.organizationId,
      ownerUserId: params.uploadedByUserId,
      purpose: DocumentPurpose.RECEIPT_TEMPLATE,
      filename: params.filename,
      body: params.body,
      contentType: params.contentType,
    });

    const template = await this.prisma.receiptTemplate.create({
      data: {
        organizationId: params.organizationId,
        templateType: TemplateType.RECEIPT,
        version,
        sourceFileUrl: uploaded.objectKey,
        fieldMap: [],
        detectionStatus: TemplateDetectionStatus.PENDING,
        uploadedByUserId: params.uploadedByUserId,
      },
    });

    this.runDetectionAsync(template.id, uploaded.url);

    return template;
  }

  private runDetectionAsync(templateId: string, fileUrl: string): void {
    this.detectionEngine
      .detect({ fileUrl })
      .then((result) => this.applyDetectionResult(templateId, result))
      .catch((error: unknown) => {
        this.logger.warn(
          `Field detection threw for template ${templateId}: ${error instanceof Error ? error.message : String(error)}`,
        );
        return this.applyDetectionResult(templateId, { status: "Failed", fields: [] });
      })
      .catch((error: unknown) => {
        this.logger.error(
          `Failed to persist detection outcome for template ${templateId}`,
          error instanceof Error ? error.stack : String(error),
        );
      });
  }

  /** Applies a (possibly stubbed/mocked) detection engine result to a template. Never throws to its caller. */
  async applyDetectionResult(templateId: string, result: FieldDetectionResult) {
    if (result.status === "Failed") {
      return this.prisma.receiptTemplate.update({
        where: { id: templateId },
        data: { detectionStatus: TemplateDetectionStatus.FAILED },
      });
    }

    // The engine reports its own confidence per field ("confidence"); the
    // stored fieldMap schema names that same value "detectionConfidence".
    const fieldMap = validateFieldMap(
      result.fields.map((field) => ({
        fieldKey: field.fieldKey,
        page: field.page,
        x: field.x,
        y: field.y,
        detectionConfidence: field.confidence,
      })),
    );
    return this.prisma.receiptTemplate.update({
      where: { id: templateId },
      data: {
        fieldMap: fieldMap as unknown as Prisma.InputJsonValue,
        detectionStatus: TemplateDetectionStatus.AUTO_DETECTED,
      },
    });
  }

  /** Manual calibration: overwrites the fieldMap and marks the template ManuallyCalibrated. */
  async calibrateFieldMap(organizationId: string, templateId: string, entries: unknown) {
    const template = await this.requireOwnedTemplate(organizationId, templateId);
    const fieldMap = validateFieldMap(entries);

    return this.prisma.receiptTemplate.update({
      where: { id: template.id },
      data: {
        fieldMap: fieldMap as unknown as Prisma.InputJsonValue,
        detectionStatus: TemplateDetectionStatus.MANUALLY_CALIBRATED,
      },
    });
  }

  /**
   * Activates a template version, atomically deactivating whatever version
   * of the same templateType was previously active for this organization.
   * Receipt-type templates whose detection is still Pending or has Failed
   * can never be activated -- Bill templates aren't detected at all, so
   * this gate does not apply to them.
   */
  async activate(organizationId: string, templateId: string) {
    const template = await this.requireOwnedTemplate(organizationId, templateId);

    if (
      template.templateType === TemplateType.RECEIPT &&
      (template.detectionStatus === TemplateDetectionStatus.FAILED ||
        template.detectionStatus === TemplateDetectionStatus.PENDING)
    ) {
      throw new ForbiddenException(
        `Template cannot be activated while detectionStatus is '${template.detectionStatus}'. Re-upload or manually calibrate first.`,
      );
    }

    await this.prisma.$transaction([
      this.prisma.receiptTemplate.updateMany({
        where: { organizationId, templateType: template.templateType, isActive: true },
        data: { isActive: false },
      }),
      this.prisma.receiptTemplate.update({
        where: { id: template.id },
        data: { isActive: true },
      }),
    ]);

    return this.requireOwnedTemplate(organizationId, template.id);
  }

  async list(organizationId: string, templateType?: TemplateType) {
    return this.prisma.receiptTemplate.findMany({
      where: { organizationId, ...(templateType ? { templateType } : {}) },
      orderBy: { version: "desc" },
    });
  }

  async getById(organizationId: string, templateId: string) {
    return this.requireOwnedTemplate(organizationId, templateId);
  }

  /** Only deletable if no issued receipt has ever snapshotted this exact version. */
  async delete(organizationId: string, templateId: string) {
    const template = await this.requireOwnedTemplate(organizationId, templateId);

    const usageCount = await this.prisma.receipt.count({
      where: { organizationId, templateVersion: template.id },
    });
    if (usageCount > 0) {
      throw new ForbiddenException(
        "This template version has already been used to issue a receipt and cannot be deleted.",
      );
    }

    await this.prisma.receiptTemplate.delete({ where: { id: template.id } });
  }

  /**
   * Resolves the template a NEW receipt should snapshot at issuance time:
   * the currently active version for organizationId+templateType, or null
   * if the mandal has never activated a personalized template. Callers
   * (other modules) must treat null as "fall back to the system default
   * layout" -- a normal, non-error state, never an exception.
   */
  async resolveActiveTemplate(organizationId: string, templateType: TemplateType) {
    return this.prisma.receiptTemplate.findFirst({
      where: { organizationId, templateType, isActive: true },
    });
  }

  /**
   * Historic Rendering Lock: returns the exact template version a receipt
   * snapshotted at issuance (Receipt.templateVersion stores this id),
   * regardless of what has been activated/edited since. This is what keeps
   * previously issued receipts visually frozen.
   */
  async getSnapshotByVersionId(templateVersionId: string) {
    const template = await this.prisma.receiptTemplate.findUnique({ where: { id: templateVersionId } });
    if (!template) {
      throw new NotFoundException("Template version not found");
    }
    return template;
  }

  private async nextVersion(organizationId: string, templateType: TemplateType): Promise<number> {
    const sequence = await this.sequenceCounter.getNextSequence(
      organizationId,
      TEMPLATE_SEQUENCE_FESTIVAL_YEAR,
      `template:${templateType}`,
    );
    return Number(sequence);
  }

  private async requireOwnedTemplate(organizationId: string, templateId: string) {
    const template = await this.prisma.receiptTemplate.findUnique({ where: { id: templateId } });
    if (!template || template.organizationId !== organizationId) {
      throw new NotFoundException("Template not found");
    }
    return template;
  }
}
