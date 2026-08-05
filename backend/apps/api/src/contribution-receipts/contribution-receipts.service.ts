import {
  ConflictException,
  Inject,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { PrismaService, TemplateType } from "@pauti-pustak/backend-database";
import { TenantContext } from "../common/tenancy/tenant-context";
import { TenantScopedRepository } from "../common/tenancy/tenant-scoped.repository";
import { FestivalYearService } from "../common/festival-year/festival-year.service";
import { SequenceCounterService } from "../common/sequence/sequence-counter.service";
import { WhatsAppDeliveryService } from "../common/whatsapp/whatsapp-delivery.service";
import { AuditService } from "../audit/audit.service";
import { ContributionsService } from "../contribution/contribution.service";
import { TemplatesService } from "../templates/templates.service";
import { ContributionReceiptNumberFormatter } from "./contribution-receipt-number.formatter";

@Injectable()
export class ContributionReceiptsRepository extends TenantScopedRepository<any> {
  constructor(@Inject(PrismaService) prisma: PrismaService, @Inject(TenantContext) tenantContext: TenantContext) {
    super(prisma.contributionReceipt, tenantContext);
  }
}

@Injectable()
export class ContributionReceiptsService {
  constructor(
    @Inject(ContributionReceiptsRepository) private readonly repository: ContributionReceiptsRepository,
    @Inject(ContributionsService) private readonly contributionsService: ContributionsService,
    @Inject(FestivalYearService) private readonly festivalYearService: FestivalYearService,
    @Inject(SequenceCounterService) private readonly sequenceCounterService: SequenceCounterService,
    @Inject(WhatsAppDeliveryService) private readonly whatsappDeliveryService: WhatsAppDeliveryService,
    @Inject(TemplatesService) private readonly templatesService: TemplatesService,
    @Inject(AuditService) private readonly auditService: AuditService,
    @Inject(TenantContext) private readonly tenantContext: TenantContext,
  ) {}

  async generate(contributionId: string) {
    const contribution = await this.contributionsService.findOne(contributionId);
    if (!contribution) {
      throw new NotFoundException(`Contribution ${contributionId} not found`);
    }

    const existing = await this.repository.findFirst({ where: { contributionId } });
    if (existing) {
      return existing;
    }

    const orgId = this.tenantContext.organizationId;
    const activeYearInfo = await this.festivalYearService.getActiveFestivalYear(orgId);
    const festivalYear = activeYearInfo.festivalYear;

    const sequenceValue = await this.sequenceCounterService.getNextSequence(
      orgId,
      festivalYear,
      "contributionReceipt",
    );

    const receiptNumber = ContributionReceiptNumberFormatter.format(
      festivalYear,
      Number(sequenceValue),
    );

    const activeTemplate = await this.templatesService
      .resolveActiveTemplate(orgId, TemplateType.RECEIPT)
      .catch(() => null);

    const pdfUrl = `https://assets.pautipustak.org/contribution-receipts/${receiptNumber}.pdf`;

    const receipt = await this.repository.create({
      festivalYear,
      contributionId: contribution.id,
      contributorId: contribution.contributorId ?? null,
      contributorNameSnapshot: contribution.contributorNameSnapshot,
      donationTypeSnapshot: contribution.donationType,
      contributionReceiptNumber: receiptNumber,
      mandalNameSnapshot: "Mandal Financial Trust",
      templateVersionId: activeTemplate?.id ?? null,
      pdfUrl,
      whatsappDeliveryStatus: "PENDING",
      whatsappRetryCount: 0,
      status: "ACTIVE",
    });

    await this.contributionsService.markReceipted(contributionId);

    if (contribution.contactSnapshot) {
      this.whatsappDeliveryService
        .sendDocument({
          organizationId: orgId,
          recipientPhone: contribution.contactSnapshot,
          mediaUrl: pdfUrl,
          relatedEntityType: "ContributionReceipt",
          relatedEntityId: receipt.id,
        })
        .catch(() => {
          // Asynchronous delivery failure never blocks receipt creation
        });
    }

    return receipt;
  }

  async findAll() {
    return this.repository.findMany({
      orderBy: { createdAt: "desc" },
    });
  }

  async findOne(id: string) {
    const receipt = await this.repository.findOwnedUnique({ id });
    if (!receipt) {
      throw new NotFoundException(`Contribution receipt ${id} not found`);
    }
    return receipt;
  }

  async findMyHistory(contributorId: string) {
    return this.repository.findMany({
      where: { contributorId },
      orderBy: { createdAt: "desc" },
    });
  }

  async resendWhatsApp(id: string) {
    const receipt = await this.findOne(id);
    if (!receipt.contactSnapshot && !receipt.pdfUrl) {
      throw new ConflictException("Receipt lacks contact details or PDF URL");
    }

    const orgId = this.tenantContext.organizationId;
    return this.whatsappDeliveryService.sendDocument({
      organizationId: orgId,
      recipientPhone: receipt.contactSnapshot || "",
      mediaUrl: receipt.pdfUrl,
      relatedEntityType: "ContributionReceipt",
      relatedEntityId: receipt.id,
    });
  }

  async voidReceipt(id: string, reason: string, actorId: string) {
    const receipt = await this.findOne(id);
    if (receipt.status === "VOIDED") {
      throw new ConflictException("Contribution receipt is already voided");
    }

    const updated = await this.repository.update(
      { id },
      {
        status: "VOIDED",
        voidedBy: actorId,
        voidReason: reason,
        voidedAt: new Date(),
      },
    );

    await this.auditService.log({
      actorId,
      action: "VOID_CONTRIBUTION_RECEIPT",
      targetTable: "contribution_receipts",
      targetId: id,
      reason,
    });

    return updated;
  }
}
