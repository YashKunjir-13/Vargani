import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import {
  ExpensePaymentStatus,
  ExpenseStatus,
  FinancialAccountStatus,
  LedgerAccountClass,
  LedgerEntrySide,
  LedgerTransactionStatus,
  PrismaService,
  VendorStatus,
} from "@pauti-pustak/backend-database";
import { PanEncryptionService } from "@pauti-pustak/backend-security";
import { CreateAccountDto } from "./dto/create-account.dto";
import { CreateExpenseDto } from "./dto/create-expense.dto";
import { CreateLedgerTransactionDto } from "./dto/create-ledger-transaction.dto";
import { CreateVendorDto } from "./dto/create-vendor.dto";
import { PayExpenseDto } from "./dto/pay-expense.dto";
import { RejectExpenseDto } from "./dto/reject-expense.dto";
import { UpdateVendorDto } from "./dto/update-vendor.dto";

@Injectable()
export class FinanceService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly panEncryptionService: PanEncryptionService,
  ) {}

  // ---------------------------------------------------------------------------
  // Vendors
  // ---------------------------------------------------------------------------

  async listVendors(organizationId: string, status?: VendorStatus) {
    const vendors = await this.prisma.vendor.findMany({
      where: {
        organizationId,
        ...(status ? { status } : {}),
      },
      orderBy: { name: "asc" },
    });

    return vendors.map((v) => ({
      ...v,
      gstinMasked: v.gstinEncrypted ? "GSTIN-REGISTERED" : null,
      panMasked: v.panEncrypted ? "PAN-REGISTERED" : null,
    }));
  }

  async getVendor(organizationId: string, vendorId: string) {
    const vendor = await this.prisma.vendor.findFirst({
      where: { id: vendorId, organizationId },
    });

    if (!vendor) {
      throw new NotFoundException("Vendor not found");
    }

    return {
      ...vendor,
      gstinMasked: vendor.gstinEncrypted ? "GSTIN-REGISTERED" : null,
      panMasked: vendor.panEncrypted ? "PAN-REGISTERED" : null,
    };
  }

  async createVendor(organizationId: string, userId: string, dto: CreateVendorDto) {
    const existing = await this.prisma.vendor.findUnique({
      where: { organizationId_name: { organizationId, name: dto.name } },
    });

    if (existing) {
      throw new ConflictException("Vendor with this name already exists in organization");
    }

    const vendor = await this.prisma.vendor.create({
      data: {
        organizationId,
        name: dto.name,
        contactPerson: dto.contactPerson,
        mobile: dto.mobile,
        email: dto.email ? dto.email.toLowerCase().trim() : null,
        address: dto.address,
        gstinEncrypted: dto.gstin ? this.panEncryptionService.encrypt(dto.gstin) : null,
        panEncrypted: dto.panNumber ? this.panEncryptionService.encrypt(dto.panNumber) : null,
        bankAccountEncrypted: dto.bankAccountNumber ? this.panEncryptionService.encrypt(dto.bankAccountNumber) : null,
        bankIfscEncrypted: dto.bankIfsc ? this.panEncryptionService.encrypt(dto.bankIfsc) : null,
        status: VendorStatus.ACTIVE,
        createdByUserId: userId,
      },
    });

    return vendor;
  }

  async updateVendor(organizationId: string, vendorId: string, dto: UpdateVendorDto) {
    const vendor = await this.prisma.vendor.findFirst({ where: { id: vendorId, organizationId } });
    if (!vendor || vendor.status === VendorStatus.INACTIVE) {
      throw new ForbiddenException("Vendor is inactive and cannot be updated");
    }

    const updated = await this.prisma.vendor.update({
      where: { id: vendorId },
      data: {
        ...(dto.name ? { name: dto.name } : {}),
        ...(dto.contactPerson !== undefined ? { contactPerson: dto.contactPerson } : {}),
        ...(dto.mobile !== undefined ? { mobile: dto.mobile } : {}),
        ...(dto.email !== undefined ? { email: dto.email.toLowerCase().trim() } : {}),
        ...(dto.address !== undefined ? { address: dto.address } : {}),
      },
    });

    return updated;
  }

  // ---------------------------------------------------------------------------
  // Expenses & Payouts
  // ---------------------------------------------------------------------------

  async listExpenses(organizationId: string, eventId: string, status?: ExpenseStatus) {
    const expenses = await this.prisma.expense.findMany({
      where: {
        organizationId,
        eventId,
        ...(status ? { status } : {}),
      },
      orderBy: { createdAt: "desc" },
      include: { vendor: { select: { id: true, name: true } }, payments: true },
    });

    return expenses.map((e) => this.formatExpensePaise(e));
  }

  async createExpense(organizationId: string, eventId: string, userId: string, dto: CreateExpenseDto) {
    const vendor = await this.prisma.vendor.findFirst({
      where: { id: dto.vendorId, organizationId, status: VendorStatus.ACTIVE },
    });

    if (!vendor) {
      throw new NotFoundException("Active vendor not found");
    }

    const baseAmountPaise = BigInt(dto.baseAmountPaise);
    const taxAmountPaise = dto.taxAmountPaise ? BigInt(dto.taxAmountPaise) : BigInt(0);
    const requestedAmountPaise = baseAmountPaise + taxAmountPaise;

    const expense = await this.prisma.expense.create({
      data: {
        organizationId,
        eventId,
        vendorId: dto.vendorId,
        categoryCode: dto.categoryCode,
        description: dto.description,
        expenseDate: new Date(dto.expenseDate),
        baseAmountPaise,
        taxAmountPaise,
        requestedAmountPaise,
        outstandingAmountPaise: requestedAmountPaise,
        status: ExpenseStatus.SUBMITTED,
        submittedByUserId: userId,
        createdByUserId: userId,
        vendorSnapshot: { name: vendor.name, contactPerson: vendor.contactPerson },
      },
    });

    return this.formatExpensePaise(expense);
  }

  async approveExpense(organizationId: string, expenseId: string, userId: string) {
    const expense = await this.prisma.expense.findFirst({ where: { id: expenseId, organizationId } });
    if (!expense) {
      throw new NotFoundException("Expense not found");
    }

    // Defense-in-depth: Self-approval check
    if (expense.createdByUserId === userId || expense.submittedByUserId === userId) {
      throw new ForbiddenException("An expense cannot be approved by the same user who created or submitted it");
    }

    if (expense.status !== ExpenseStatus.SUBMITTED && expense.status !== ExpenseStatus.UNDER_APPROVAL) {
      throw new BadRequestException(`Expense status is ${expense.status}, cannot approve`);
    }

    const approved = await this.prisma.expense.update({
      where: { id: expenseId },
      data: {
        status: ExpenseStatus.APPROVED,
        approvedAmountPaise: expense.requestedAmountPaise,
      },
    });

    return this.formatExpensePaise(approved);
  }

  async rejectExpense(organizationId: string, expenseId: string, userId: string, dto: RejectExpenseDto) {
    const expense = await this.prisma.expense.findFirst({ where: { id: expenseId, organizationId } });
    if (!expense) {
      throw new NotFoundException("Expense not found");
    }

    const rejected = await this.prisma.expense.update({
      where: { id: expenseId },
      data: {
        status: ExpenseStatus.REJECTED,
        rejectedByUserId: userId,
        rejectionReason: dto.reason,
        rejectedAt: new Date(),
      },
    });

    return this.formatExpensePaise(rejected);
  }

  async payExpense(organizationId: string, expenseId: string, userId: string, dto: PayExpenseDto) {
    const expense = await this.prisma.expense.findFirst({ where: { id: expenseId, organizationId } });
    if (!expense) {
      throw new NotFoundException("Expense not found");
    }

    if (expense.status !== ExpenseStatus.APPROVED && expense.status !== ExpenseStatus.PARTIALLY_PAID) {
      throw new BadRequestException("Expense must be APPROVED or PARTIALLY_PAID to record payment");
    }

    const account = await this.prisma.financialAccount.findFirst({
      where: { id: dto.accountId, organizationId, status: FinancialAccountStatus.ACTIVE },
    });

    if (!account) {
      throw new NotFoundException("Active financial account not found");
    }

    const amountPaise = BigInt(dto.amountPaise);
    const newPaidAmountPaise = expense.paidAmountPaise + amountPaise;
    const approvedAmount = expense.approvedAmountPaise ?? expense.requestedAmountPaise;
    const newOutstanding = approvedAmount - newPaidAmountPaise;

    if (newOutstanding < BigInt(0)) {
      throw new BadRequestException("Payout amount exceeds outstanding approved expense amount");
    }

    const newStatus = newOutstanding === BigInt(0) ? ExpenseStatus.PAID : ExpenseStatus.PARTIALLY_PAID;

    // Record payout & update expense
    const payout = await this.prisma.expensePayment.create({
      data: {
        expenseId,
        accountId: dto.accountId,
        amountPaise,
        paymentMode: dto.paymentMode,
        transactionReference: dto.transactionReference,
        status: ExpensePaymentStatus.CONFIRMED,
        paidByUserId: userId,
        confirmedAt: new Date(),
      },
    });

    const updatedExpense = await this.prisma.expense.update({
      where: { id: expenseId },
      data: {
        paidAmountPaise: newPaidAmountPaise,
        outstandingAmountPaise: newOutstanding,
        status: newStatus,
      },
    });

    // Auto-post double-entry ledger transaction: Debit Expense, Credit Asset/Account
    await this.postLedgerTransaction(organizationId, userId, {
      type: "EXPENSE_PAYMENT" as any,
      sourceType: "EXPENSE_PAYMENT",
      sourceId: payout.id,
      idempotencyKey: `LEDGER-PAY-${payout.id}`,
      description: `Expense payout for ${expense.description}`,
      entries: [
        {
          accountCode: `EXPENSE_${expense.categoryCode}`,
          accountClass: LedgerAccountClass.EXPENSE,
          side: LedgerEntrySide.DEBIT,
          amountPaise: dto.amountPaise,
        },
        {
          accountCode: `ASSET_${account.type}`,
          accountClass: LedgerAccountClass.ASSET,
          side: LedgerEntrySide.CREDIT,
          amountPaise: dto.amountPaise,
          financialAccountId: account.id,
        },
      ],
    });

    return {
      payoutId: payout.id,
      expense: this.formatExpensePaise(updatedExpense),
    };
  }

  // ---------------------------------------------------------------------------
  // Financial Accounts & Double-Entry Ledger
  // ---------------------------------------------------------------------------

  async listAccounts(organizationId: string) {
    const accounts = await this.prisma.financialAccount.findMany({
      where: { organizationId, status: FinancialAccountStatus.ACTIVE },
      orderBy: { createdAt: "asc" },
    });

    return accounts.map((a) => ({
      ...a,
      openingBalancePaise: a.openingBalancePaise.toString(),
    }));
  }

  async createAccount(organizationId: string, userId: string, dto: CreateAccountDto) {
    const existing = await this.prisma.financialAccount.findUnique({
      where: { organizationId_type: { organizationId, type: dto.type } },
    });

    if (existing) {
      throw new ConflictException("Financial account of this type already exists in organization");
    }

    const openingBalancePaise = dto.openingBalancePaise ? BigInt(dto.openingBalancePaise) : BigInt(0);

    const account = await this.prisma.financialAccount.create({
      data: {
        organizationId,
        type: dto.type,
        displayName: dto.displayName,
        maskedIdentifier: dto.maskedIdentifier,
        openingBalancePaise,
        status: FinancialAccountStatus.ACTIVE,
        createdByUserId: userId,
      },
    });

    return {
      ...account,
      openingBalancePaise: account.openingBalancePaise.toString(),
    };
  }

  async postLedgerTransaction(organizationId: string, userId: string, dto: CreateLedgerTransactionDto) {
    // Deduplicate on idempotencyKey
    const existing = await this.prisma.ledgerTransaction.findUnique({
      where: { idempotencyKey: dto.idempotencyKey },
    });

    if (existing) {
      return existing;
    }

    // Invariant Check: Sum(Debits) == Sum(Credits) in integer paise
    let totalDebits = BigInt(0);
    let totalCredits = BigInt(0);

    for (const entry of dto.entries) {
      const amt = BigInt(entry.amountPaise);
      if (amt <= BigInt(0)) {
        throw new BadRequestException("Ledger line amount must be positive");
      }

      if (entry.side === LedgerEntrySide.DEBIT) {
        totalDebits += amt;
      } else if (entry.side === LedgerEntrySide.CREDIT) {
        totalCredits += amt;
      }
    }

    if (totalDebits !== totalCredits) {
      throw new BadRequestException(
        `Unbalanced ledger entry: Total Debits (${totalDebits}) != Total Credits (${totalCredits})`,
      );
    }

    // Write atomic ledger transaction and entry lines
    const transaction = await this.prisma.ledgerTransaction.create({
      data: {
        organizationId,
        type: dto.type,
        sourceType: dto.sourceType,
        sourceId: dto.sourceId,
        idempotencyKey: dto.idempotencyKey,
        description: dto.description,
        status: LedgerTransactionStatus.POSTED,
        postedByUserId: userId,
        postedAt: new Date(),
        entries: {
          create: dto.entries.map((e) => ({
            organizationId,
            financialAccountId: e.financialAccountId,
            accountCode: e.accountCode,
            accountClass: e.accountClass,
            side: e.side,
            amountPaise: BigInt(e.amountPaise),
          })),
        },
      },
      include: { entries: true },
    });

    return transaction;
  }

  async getTrialBalance(organizationId: string) {
    const entries = await this.prisma.ledgerEntry.groupBy({
      by: ["accountCode", "side"],
      where: { organizationId },
      _sum: { amountPaise: true },
    });

    let totalDebits = BigInt(0);
    let totalCredits = BigInt(0);
    const summary: Record<string, { debitsPaise: string; creditsPaise: string }> = {};

    for (const entry of entries) {
      const code = entry.accountCode;
      if (!summary[code]) {
        summary[code] = { debitsPaise: "0", creditsPaise: "0" };
      }

      const sumPaise = entry._sum.amountPaise ?? BigInt(0);
      if (entry.side === LedgerEntrySide.DEBIT) {
        summary[code].debitsPaise = sumPaise.toString();
        totalDebits += sumPaise;
      } else {
        summary[code].creditsPaise = sumPaise.toString();
        totalCredits += sumPaise;
      }
    }

    return {
      isBalanced: totalDebits === totalCredits,
      totalDebitsPaise: totalDebits.toString(),
      totalCreditsPaise: totalCredits.toString(),
      accounts: summary,
    };
  }

  private formatExpensePaise(expense: any) {
    return {
      ...expense,
      baseAmountPaise: expense.baseAmountPaise.toString(),
      taxAmountPaise: expense.taxAmountPaise.toString(),
      requestedAmountPaise: expense.requestedAmountPaise.toString(),
      approvedAmountPaise: expense.approvedAmountPaise ? expense.approvedAmountPaise.toString() : null,
      paidAmountPaise: expense.paidAmountPaise.toString(),
      outstandingAmountPaise: expense.outstandingAmountPaise ? expense.outstandingAmountPaise.toString() : null,
    };
  }
}
