import { ForbiddenException, Inject, Injectable, NotFoundException } from "@nestjs/common";
import { Bill, BillStatus, PaymentMode, PrismaService } from "@pauti-pustak/backend-database";
import { FestivalYearService } from "../common/festival-year/festival-year.service";
import { SequenceCounterService } from "../common/sequence/sequence-counter.service";
import { BILL_OCR_PORT, BillOcrPort, ProposedBillFields } from "./bill-ocr.port";
import { formatBillNumber } from "./bill-number.formatter";
import { assertBillTransition } from "./bill-state-machine";
import { CreateBillDto } from "./dto/create-bill.dto";
import { ListBillsQueryDto } from "./dto/list-bills-query.dto";
import { UpdateBillDto } from "./dto/update-bill.dto";
import { LEDGER_PORT, LedgerPort } from "./ledger.port";

const BILL_SEQUENCE_NAME = "bill";

@Injectable()
export class BillsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly festivalYear: FestivalYearService,
    private readonly sequenceCounter: SequenceCounterService,
    @Inject(LEDGER_PORT) private readonly ledger: LedgerPort,
    @Inject(BILL_OCR_PORT) private readonly ocr: BillOcrPort,
  ) {}

  /**
   * Pure, read-only: proposes field values from a bill photo for the
   * Treasurer to review. Never touches a Bill row and never submits
   * anything -- callers still go through create()/submit() explicitly.
   */
  async previewOcr(billPhotoUrl: string): Promise<ProposedBillFields> {
    return this.ocr.proposeFields(billPhotoUrl);
  }

  async create(organizationId: string, createdByUserId: string, dto: CreateBillDto): Promise<Bill> {
    const { festivalYear } = await this.festivalYear.getActiveFestivalYear(organizationId);
    const sequence = await this.sequenceCounter.getNextSequence(organizationId, festivalYear, BILL_SEQUENCE_NAME);
    const billNumber = formatBillNumber(festivalYear, sequence);

    return this.prisma.bill.create({
      data: {
        organizationId,
        festivalYear,
        billNumber,
        vendorId: dto.vendorId ?? null,
        receiverNameSnapshot: dto.receiverNameSnapshot,
        contactSnapshot: dto.contactSnapshot ?? null,
        amount: dto.amount,
        date: new Date(dto.date),
        taskOrField: dto.taskOrField,
        milestoneId: dto.milestoneId ?? null,
        billPhotoUrl: dto.billPhotoUrl ?? null,
        status: BillStatus.DRAFT,
        createdByUserId,
      },
    });
  }

  async list(organizationId: string, filter: ListBillsQueryDto): Promise<Bill[]> {
    return this.prisma.bill.findMany({
      where: {
        organizationId,
        ...(filter.status ? { status: filter.status } : {}),
        ...(filter.vendorId ? { vendorId: filter.vendorId } : {}),
        ...(filter.taskOrField ? { taskOrField: filter.taskOrField } : {}),
        ...(filter.from || filter.to
          ? {
              date: {
                ...(filter.from ? { gte: new Date(filter.from) } : {}),
                ...(filter.to ? { lte: new Date(filter.to) } : {}),
              },
            }
          : {}),
      },
      orderBy: { date: "desc" },
    });
  }

  async getById(organizationId: string, id: string): Promise<Bill> {
    return this.requireOwnedBill(organizationId, id);
  }

  /** Every editable field, but only while the bill is still Draft. */
  async update(organizationId: string, id: string, dto: UpdateBillDto): Promise<Bill> {
    const bill = await this.requireOwnedBill(organizationId, id);
    if (bill.status !== BillStatus.DRAFT) {
      throw new ForbiddenException(`Bill ${id} is ${bill.status}: only editable while Draft`);
    }

    return this.prisma.bill.update({
      where: { id: bill.id },
      data: {
        ...(dto.vendorId !== undefined ? { vendorId: dto.vendorId } : {}),
        ...(dto.receiverNameSnapshot !== undefined ? { receiverNameSnapshot: dto.receiverNameSnapshot } : {}),
        ...(dto.contactSnapshot !== undefined ? { contactSnapshot: dto.contactSnapshot } : {}),
        ...(dto.amount !== undefined ? { amount: dto.amount } : {}),
        ...(dto.date !== undefined ? { date: new Date(dto.date) } : {}),
        ...(dto.taskOrField !== undefined ? { taskOrField: dto.taskOrField } : {}),
        ...(dto.milestoneId !== undefined ? { milestoneId: dto.milestoneId } : {}),
        ...(dto.billPhotoUrl !== undefined ? { billPhotoUrl: dto.billPhotoUrl } : {}),
      },
    });
  }

  async submit(organizationId: string, id: string): Promise<Bill> {
    const bill = await this.requireOwnedBill(organizationId, id);
    assertBillTransition(bill.status, BillStatus.PENDING_APPROVAL);

    const submitted = await this.prisma.bill.update({
      where: { id: bill.id },
      data: { status: BillStatus.PENDING_APPROVAL, submittedAt: new Date() },
    });
    await this.writeAuditEvent(organizationId, submitted.id, "submitted", bill.createdByUserId);
    return submitted;
  }

  /**
   * Defense-in-depth against a misconfigured role: the seeded Treasurer
   * role holds both bill.create and bill.approve, so PermissionGuard alone
   * cannot prevent self-approval. This check runs regardless of what the
   * approving user's permissions say.
   */
  async approve(organizationId: string, id: string, approvingUserId: string): Promise<Bill> {
    const bill = await this.requireOwnedBill(organizationId, id);
    if (bill.createdByUserId === approvingUserId) {
      throw new ForbiddenException("A bill cannot be approved by the same user who created/submitted it");
    }
    assertBillTransition(bill.status, BillStatus.APPROVED);

    const approved = await this.prisma.bill.update({
      where: { id: bill.id },
      data: { status: BillStatus.APPROVED, approvedByUserId: approvingUserId, approvedAt: new Date() },
    });
    await this.writeAuditEvent(organizationId, approved.id, "approved", approvingUserId);
    return approved;
  }

  /** Mandatory reason -> back to Draft for correction/resubmission, never an automatic delete. */
  async reject(organizationId: string, id: string, rejectedByUserId: string, reason: string): Promise<Bill> {
    const bill = await this.requireOwnedBill(organizationId, id);
    assertBillTransition(bill.status, BillStatus.DRAFT);

    const rejected = await this.prisma.bill.update({
      where: { id: bill.id },
      data: { status: BillStatus.DRAFT, rejectionReason: reason },
    });
    await this.writeAuditEvent(organizationId, rejected.id, "rejected", rejectedByUserId, reason);
    return rejected;
  }

  /** Approved -> Paid, the terminal successful state. Feeds the Ledger hook once, after the status change succeeds. */
  async markPaid(organizationId: string, id: string, paidByUserId: string, paymentMode: PaymentMode): Promise<Bill> {
    const bill = await this.requireOwnedBill(organizationId, id);
    assertBillTransition(bill.status, BillStatus.PAID);

    const paidAt = new Date();
    const paid = await this.prisma.bill.update({
      where: { id: bill.id },
      data: { status: BillStatus.PAID, paymentMode, paidAt },
    });
    await this.writeAuditEvent(organizationId, paid.id, "paid", paidByUserId);

    await this.ledger.recordBillPayment({
      organizationId,
      festivalYear: paid.festivalYear,
      billId: paid.id,
      billNumber: paid.billNumber,
      vendorId: paid.vendorId,
      amount: paid.amount as unknown as number,
      paymentMode,
      paidAt,
    });

    return paid;
  }

  /** The only way to correct a Paid bill (or cancel one earlier in the workflow). Mandatory reason, audit-logged. */
  async cancel(organizationId: string, id: string, cancelledByUserId: string, reason: string): Promise<Bill> {
    const bill = await this.requireOwnedBill(organizationId, id);
    assertBillTransition(bill.status, BillStatus.CANCELLED);

    const cancelled = await this.prisma.bill.update({
      where: { id: bill.id },
      data: { status: BillStatus.CANCELLED, cancelReason: reason, cancelledByUserId, cancelledAt: new Date() },
    });
    await this.writeAuditEvent(organizationId, cancelled.id, "cancelled", cancelledByUserId, reason);
    return cancelled;
  }

  private async requireOwnedBill(organizationId: string, id: string): Promise<Bill> {
    const bill = await this.prisma.bill.findUnique({ where: { id } });
    if (!bill || bill.organizationId !== organizationId) {
      throw new NotFoundException("Bill not found");
    }
    return bill;
  }

  private async writeAuditEvent(
    organizationId: string,
    billId: string,
    actionType: string,
    performedByUserId: string | null,
    reason?: string,
  ): Promise<void> {
    await this.prisma.billAuditEvent.create({
      data: { organizationId, billId, actionType, performedByUserId, reason },
    });
  }
}
