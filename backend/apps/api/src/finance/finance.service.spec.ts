import { Test, TestingModule } from "@nestjs/testing";
import { ExpenseStatus, FinancialAccountStatus, LedgerAccountClass, LedgerEntrySide, PrismaService, VendorStatus } from "@pauti-pustak/backend-database";
import { PanEncryptionService } from "@pauti-pustak/backend-security";
import { BadRequestException, ForbiddenException } from "@nestjs/common";
import { FinanceService } from "./finance.service";

describe("FinanceService (Phase 3 Unit Tests)", () => {
  let service: FinanceService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      vendor: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      expense: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      expensePayment: {
        create: jest.fn(),
      },
      financialAccount: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        create: jest.fn(),
      },
      ledgerTransaction: {
        findUnique: jest.fn(),
        create: jest.fn(),
      },
      ledgerEntry: {
        groupBy: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FinanceService,
        { provide: PrismaService, useValue: prisma },
        PanEncryptionService,
      ],
    }).compile();

    service = module.get<FinanceService>(FinanceService);
  });

  describe("Vendors & Encrypted Details", () => {
    it("creates vendor with encrypted GSTIN/PAN", async () => {
      prisma.vendor.findUnique.mockResolvedValue(null);
      prisma.vendor.create.mockResolvedValue({
        id: "v-1",
        organizationId: "org-1",
        name: "Shiv Mandap",
        status: VendorStatus.ACTIVE,
        gstinEncrypted: "encrypted",
      });

      const res = await service.createVendor("org-1", "u-1", {
        name: "Shiv Mandap",
        gstin: "27ABCDE1234F1Z5",
      });

      expect(res.id).toBe("v-1");
      expect(prisma.vendor.create).toHaveBeenCalled();
    });
  });

  describe("Expense Lifecycle & Self-Approval Guard", () => {
    it("creates expense calculating base + tax in integer paise", async () => {
      prisma.vendor.findFirst.mockResolvedValue({ id: "v-1", name: "Shiv Mandap", status: VendorStatus.ACTIVE });
      prisma.expense.create.mockResolvedValue({
        id: "exp-1",
        organizationId: "org-1",
        eventId: "evt-1",
        baseAmountPaise: BigInt(5000000),
        taxAmountPaise: BigInt(900000),
        requestedAmountPaise: BigInt(5900000),
        paidAmountPaise: BigInt(0),
        status: ExpenseStatus.SUBMITTED,
      });

      const res = await service.createExpense("org-1", "evt-1", "user-creator", {
        vendorId: "v-1",
        categoryCode: "DECORATION",
        description: "Stage Mandap",
        expenseDate: "2026-09-05T00:00:00.000Z",
        baseAmountPaise: "5000000",
        taxAmountPaise: "900000",
      });

      expect(res.requestedAmountPaise).toBe("5900000");
    });

    it("prevents self-approval by the expense creator", async () => {
      prisma.expense.findFirst.mockResolvedValue({
        id: "exp-1",
        organizationId: "org-1",
        createdByUserId: "user-creator",
        submittedByUserId: "user-creator",
        status: ExpenseStatus.SUBMITTED,
      });

      await expect(
        service.approveExpense("org-1", "exp-1", "user-creator"),
      ).rejects.toThrow(ForbiddenException);
    });

    it("allows approval by a different authorized user", async () => {
      prisma.expense.findFirst.mockResolvedValue({
        id: "exp-1",
        organizationId: "org-1",
        createdByUserId: "user-creator",
        submittedByUserId: "user-creator",
        requestedAmountPaise: BigInt(5900000),
        status: ExpenseStatus.SUBMITTED,
      });
      prisma.expense.update.mockResolvedValue({
        id: "exp-1",
        requestedAmountPaise: BigInt(5900000),
        approvedAmountPaise: BigInt(5900000),
        paidAmountPaise: BigInt(0),
        status: ExpenseStatus.APPROVED,
        baseAmountPaise: BigInt(5000000),
        taxAmountPaise: BigInt(900000),
      });

      const res = await service.approveExpense("org-1", "exp-1", "user-approver");
      expect(res.status).toBe(ExpenseStatus.APPROVED);
    });
  });

  describe("Double-Entry Ledger Balancing", () => {
    it("posts balanced double-entry transaction (Debits == Credits)", async () => {
      prisma.ledgerTransaction.findUnique.mockResolvedValue(null);
      prisma.ledgerTransaction.create.mockResolvedValue({
        id: "tx-1",
        status: "POSTED",
      });

      const res = await service.postLedgerTransaction("org-1", "user-1", {
        type: "DONATION_RECEIPT" as any,
        sourceType: "COLLECTION_RECORD",
        sourceId: "col-1",
        idempotencyKey: "IDEM-123",
        entries: [
          {
            accountCode: "CASH",
            accountClass: LedgerAccountClass.ASSET,
            side: LedgerEntrySide.DEBIT,
            amountPaise: "500000",
          },
          {
            accountCode: "DONATION_INCOME",
            accountClass: LedgerAccountClass.INCOME,
            side: LedgerEntrySide.CREDIT,
            amountPaise: "500000",
          },
        ],
      });

      expect(res.id).toBe("tx-1");
    });

    it("rejects unbalanced double-entry transaction", async () => {
      prisma.ledgerTransaction.findUnique.mockResolvedValue(null);

      await expect(
        service.postLedgerTransaction("org-1", "user-1", {
          type: "DONATION_RECEIPT" as any,
          sourceType: "COLLECTION_RECORD",
          sourceId: "col-1",
          idempotencyKey: "IDEM-123",
          entries: [
            {
              accountCode: "CASH",
              accountClass: LedgerAccountClass.ASSET,
              side: LedgerEntrySide.DEBIT,
              amountPaise: "500000",
            },
            {
              accountCode: "DONATION_INCOME",
              accountClass: LedgerAccountClass.INCOME,
              side: LedgerEntrySide.CREDIT,
              amountPaise: "400000", // Unbalanced!
            },
          ],
        }),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
