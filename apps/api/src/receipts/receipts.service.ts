import { ConflictException, Inject, Injectable, Logger, NotFoundException } from "@nestjs/common";
import {
  DocumentPurpose,
  DocumentStatus,
  PaymentReceipt,
  PaymentReceiptStatus,
  PrismaService,
  TemplateType,
  WhatsAppDeliveryStatus,
} from "@pauti-pustak/backend-database";
import { AssetStorageService } from "../common/storage/asset-storage.service";
import { SequenceCounterService } from "../common/sequence/sequence-counter.service";
import { WhatsAppDeliveryService } from "../common/whatsapp/whatsapp-delivery.service";
import { GenerateReceiptParams, ReceiptGenerationPort, VoidReceiptForPaymentParams } from "../payments/receipt-generation.port";
import { TemplatesService } from "../templates/templates.service";
import { ListReceiptsQueryDto } from "./dto/list-receipts-query.dto";
import { formatReceiptNumber } from "./receipt-number.formatter";
import { RECEIPT_PDF_RENDERER, ReceiptPdfRenderer } from "./receipt-pdf.renderer";

const RECEIPT_SEQUENCE_NAME = "receipt";

@Injectable()
export class ReceiptsService implements ReceiptGenerationPort {
  private readonly logger = new Logger(ReceiptsService.name);

  constructor(
    @Inject(PrismaService) private readonly prisma: PrismaService,
    @Inject(SequenceCounterService) private readonly sequenceCounter: SequenceCounterService,
    @Inject(AssetStorageService) private readonly assetStorage: AssetStorageService,
    @Inject(WhatsAppDeliveryService) private readonly whatsAppDelivery: WhatsAppDeliveryService,
    @Inject(TemplatesService) private readonly templatesService: TemplatesService,
    @Inject(RECEIPT_PDF_RENDERER) private readonly pdfRenderer: ReceiptPdfRenderer,
  ) {}

  /**
   * The only way a PaymentReceipt is ever created. Idempotent on paymentId:
   * if one already exists (e.g. a caller retries after a transient error
   * downstream of receipt creation), this is a no-op rather than a second
   * receipt or a numbering skip.
   */
  async generateReceipt(params: GenerateReceiptParams): Promise<void> {
    const existing = await this.prisma.paymentReceipt.findUnique({ where: { paymentId: params.paymentId } });
    if (existing) {
      this.logger.warn(`Receipt already exists for payment ${params.paymentId} (${existing.receiptNumber}); no-op`);
      return;
    }

    const organization = await this.prisma.organization.findUnique({ where: { id: params.organizationId } });
    const mandalNameSnapshot = organization?.name ?? "Unknown Mandal";

    const activeTemplate = await this.templatesService.resolveActiveTemplate(
      params.organizationId,
      TemplateType.RECEIPT,
    );

    // Atomic per (organizationId, festivalYear) -- see SequenceCounterService.
    // This is what guarantees no two concurrent confirmations ever produce
    // the same or a skipped receiptNumber.
    const sequence = await this.sequenceCounter.getNextSequence(
      params.organizationId,
      params.festivalYear,
      RECEIPT_SEQUENCE_NAME,
    );
    const receiptNumber = formatReceiptNumber(params.festivalYear, sequence);

    const [stampAssetUrl, signatureAssetUrl] = await Promise.all([
      this.resolveOrgAssetUrl(params.organizationId, DocumentPurpose.ORGANIZATION_STAMP),
      this.resolveOrgAssetUrl(params.organizationId, DocumentPurpose.AUTHORIZED_SIGNATURE),
    ]);

    const issuedDate = new Date();
    const amountSnapshot = Number(params.amount);

    const pdfBytes = await this.pdfRenderer.render({
      organizationId: params.organizationId,
      receiptNumber,
      donorNameSnapshot: params.donorNameSnapshot,
      amountSnapshot,
      issuedDate,
      mandalNameSnapshot,
      stampAssetUrl,
      signatureAssetUrl,
      templateSourceFileUrl: activeTemplate?.sourceFileUrl ?? null,
    });

    const uploaded = await this.assetStorage.uploadAsset({
      organizationId: params.organizationId,
      ownerUserId: params.createdByUserId,
      purpose: DocumentPurpose.RECEIPT_PDF,
      filename: `${receiptNumber}.pdf`,
      body: pdfBytes,
      contentType: "application/pdf",
    });

    // templateVersionId snapshots the exact ReceiptTemplate row used right
    // now; if the mandal later activates a different version, this receipt
    // (and its already-rendered pdfUrl) is entirely unaffected.
    const receipt = await this.prisma.paymentReceipt.create({
      data: {
        organizationId: params.organizationId,
        festivalYear: params.festivalYear,
        paymentId: params.paymentId,
        donorId: params.donorId,
        donorNameSnapshot: params.donorNameSnapshot,
        amountSnapshot,
        receiptNumber,
        issuedDate,
        mandalNameSnapshot,
        stampAssetUrl,
        signatureAssetUrl,
        templateVersionId: activeTemplate?.id ?? null,
        pdfUrl: uploaded.url,
        whatsappDeliveryStatus: WhatsAppDeliveryStatus.PENDING,
        whatsappRetryCount: 0,
        status: PaymentReceiptStatus.ACTIVE,
      },
    });

    await this.writeAuditEvent(receipt.organizationId, receipt.id, "generated", null);

    await this.dispatchWhatsApp(receipt, params.contactSnapshot);
  }

  /** Implements ReceiptGenerationPort's void-propagation hook: called by PaymentsService.void. */
  async voidReceiptForPayment(params: VoidReceiptForPaymentParams): Promise<void> {
    const receipt = await this.prisma.paymentReceipt.findUnique({ where: { paymentId: params.paymentId } });
    if (!receipt || receipt.status === PaymentReceiptStatus.VOIDED) {
      return;
    }

    await this.voidReceiptRecord(receipt, params.voidedByUserId, params.reason);
  }

  async list(organizationId: string, filter: ListReceiptsQueryDto): Promise<PaymentReceipt[]> {
    return this.prisma.paymentReceipt.findMany({
      where: {
        organizationId,
        ...(filter.donorId ? { donorId: filter.donorId } : {}),
        ...(filter.status ? { status: filter.status } : {}),
        ...(filter.from || filter.to
          ? {
              issuedDate: {
                ...(filter.from ? { gte: new Date(filter.from) } : {}),
                ...(filter.to ? { lte: new Date(filter.to) } : {}),
              },
            }
          : {}),
      },
      orderBy: { issuedDate: "desc" },
    });
  }

  /**
   * `receipt.viewAll` holders get any receipt in the organization.
   * `receipt.viewOwn`-only holders (Donor) only ever get their own --
   * resolved via their DonorProfile, never trusted from a query param.
   */
  async getById(organizationId: string, id: string, requestingUserId: string, hasViewAll: boolean): Promise<PaymentReceipt> {
    const receipt = await this.requireOwnedReceipt(organizationId, id);
    if (hasViewAll) {
      return receipt;
    }

    const donorProfileId = await this.resolveDonorProfileId(requestingUserId);
    if (!donorProfileId || receipt.donorId !== donorProfileId) {
      throw new NotFoundException("Receipt not found");
    }
    return receipt;
  }

  /** A logged-in Donor's complete receipt history in this organization, regardless of WhatsApp delivery outcome. */
  async myHistory(organizationId: string, requestingUserId: string): Promise<PaymentReceipt[]> {
    const donorProfileId = await this.resolveDonorProfileId(requestingUserId);
    if (!donorProfileId) {
      return [];
    }

    return this.prisma.paymentReceipt.findMany({
      where: { organizationId, donorId: donorProfileId },
      orderBy: { issuedDate: "desc" },
    });
  }

  /** Manual retry -- never regenerates the receipt or renumbers it, only re-attempts delivery of the already-rendered PDF. */
  async resendWhatsapp(organizationId: string, id: string): Promise<PaymentReceipt> {
    const receipt = await this.requireOwnedReceipt(organizationId, id);
    const payment = await this.prisma.payment.findUnique({ where: { id: receipt.paymentId } });
    const recipientPhone = await this.resolveRecipientPhone(receipt.donorId, payment?.contactSnapshot ?? null);

    if (!recipientPhone) {
      this.logger.warn(`Receipt ${receipt.id} has no resolvable phone number; resend skipped`);
      return receipt;
    }

    return this.attemptWhatsAppSend(receipt, recipientPhone);
  }

  async void(organizationId: string, id: string, voidedByUserId: string, reason: string): Promise<PaymentReceipt> {
    const receipt = await this.requireOwnedReceipt(organizationId, id);
    if (receipt.status === PaymentReceiptStatus.VOIDED) {
      throw new ConflictException(`Receipt ${id} is already Voided`);
    }
    return this.voidReceiptRecord(receipt, voidedByUserId, reason);
  }

  private async voidReceiptRecord(
    receipt: PaymentReceipt,
    voidedByUserId: string,
    reason: string,
  ): Promise<PaymentReceipt> {
    const voided = await this.prisma.paymentReceipt.update({
      where: { id: receipt.id },
      data: { status: PaymentReceiptStatus.VOIDED, voidedByUserId, voidReason: reason, voidedAt: new Date() },
    });
    await this.writeAuditEvent(voided.organizationId, voided.id, "voided", voidedByUserId, reason);
    return voided;
  }

  private async dispatchWhatsApp(receipt: PaymentReceipt, contactSnapshot: string | null): Promise<void> {
    const recipientPhone = await this.resolveRecipientPhone(receipt.donorId, contactSnapshot);
    if (!recipientPhone) {
      this.logger.warn(`Receipt ${receipt.id} has no resolvable phone number; WhatsApp dispatch skipped`);
      return;
    }
    await this.attemptWhatsAppSend(receipt, recipientPhone);
  }

  /**
   * Sends (or re-sends) the already-rendered PDF and mirrors the outcome
   * onto the receipt's own denormalized whatsappDeliveryStatus/
   * whatsappRetryCount fields. WhatsAppDeliveryService itself never throws,
   * so a delivery failure here never blocks receipt retrieval -- only the
   * tracked status reflects it.
   */
  private async attemptWhatsAppSend(receipt: PaymentReceipt, recipientPhone: string): Promise<PaymentReceipt> {
    const { deliveryId } = await this.whatsAppDelivery.sendDocument({
      organizationId: receipt.organizationId,
      recipientPhone,
      mediaUrl: receipt.pdfUrl,
      relatedEntityType: "PaymentReceipt",
      relatedEntityId: receipt.id,
    });

    const delivery = await this.prisma.whatsAppDeliveryRecord.findUnique({ where: { id: deliveryId } });
    const succeeded = delivery?.status === WhatsAppDeliveryStatus.SENT;

    return this.prisma.paymentReceipt.update({
      where: { id: receipt.id },
      data: {
        whatsappDeliveryStatus: succeeded ? WhatsAppDeliveryStatus.SENT : WhatsAppDeliveryStatus.FAILED,
        whatsappRetryCount: succeeded ? receipt.whatsappRetryCount : { increment: 1 },
      },
    });
  }

  private async resolveRecipientPhone(donorId: string | null, contactSnapshot: string | null): Promise<string | null> {
    if (donorId) {
      const donor = await this.prisma.donorProfile.findUnique({ where: { id: donorId } });
      if (donor?.mobile) {
        return donor.mobile;
      }
    }
    return contactSnapshot;
  }

  private async resolveDonorProfileId(userId: string): Promise<string | null> {
    const donor = await this.prisma.donorProfile.findUnique({ where: { userId } });
    return donor?.id ?? null;
  }

  /** Best-effort: a missing/misconfigured stamp or signature must never block receipt generation. */
  private async resolveOrgAssetUrl(organizationId: string, purpose: DocumentPurpose): Promise<string | null> {
    try {
      const asset = await this.prisma.documentAsset.findFirst({
        where: { organizationId, purpose, status: DocumentStatus.AVAILABLE },
        orderBy: { createdAt: "desc" },
      });
      if (!asset) {
        return null;
      }
      return await this.assetStorage.getDownloadUrl(asset.objectKey);
    } catch (error) {
      this.logger.warn(
        `Failed to resolve ${purpose} asset for org ${organizationId}: ${error instanceof Error ? error.message : String(error)}`,
      );
      return null;
    }
  }

  private async requireOwnedReceipt(organizationId: string, id: string): Promise<PaymentReceipt> {
    const receipt = await this.prisma.paymentReceipt.findUnique({ where: { id } });
    if (!receipt || receipt.organizationId !== organizationId) {
      throw new NotFoundException("Receipt not found");
    }
    return receipt;
  }

  private async writeAuditEvent(
    organizationId: string,
    receiptId: string,
    actionType: string,
    performedByUserId: string | null,
    reason?: string,
  ): Promise<void> {
    await this.prisma.paymentReceiptAuditEvent.create({
      data: { organizationId, receiptId, actionType, performedByUserId, reason },
    });
  }
}
