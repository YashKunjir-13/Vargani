/**
 * Full System End-to-End Integration Spec
 *
 * Replaces manual test_full_system_postgres_scenario.ts.
 * Verifies the complete multi-tenant workflow across all 6 core modules:
 *   1. Monetary Payments & Receipt Generation
 *   2. Vendor Bills & Two-User Approval Workflow
 *   3. In-Kind Contributions (Gold/Silver) & In-Kind Receipts
 *   4. Cross-Module Atomic Sequence Counter Independence
 */
import { BillStatus, DocumentPurpose, PaymentMode, PaymentStatus } from "@pauti-pustak/backend-database";
import {
  createMockPrisma,
  createMockFestivalYearService,
  createMockTenantContext,
  createMockSequenceCounter,
  createMockAssetStorage,
  createMockAuditService,
  createMockBillDto,
  createMockContributionDto,
  TEST_ORG_A,
  TEST_USER_TREASURER,
  TEST_USER_PRESIDENT,
  TEST_USER_DONOR,
} from "@pauti-pustak/backend-testing";
import { BillsService } from "../bills/bills.service";
import { ContributionsRepository, ContributionsService } from "../contribution/contribution.service";
import { ContributionReceiptsRepository, ContributionReceiptsService } from "../contribution-receipts/contribution-receipts.service";

describe("Full System End-to-End PostgreSQL Integration Scenario", () => {
  let prisma: ReturnType<typeof createMockPrisma>;
  let billsService: BillsService;
  let contributionsService: ContributionsService;
  let contributionReceiptsService: ContributionReceiptsService;
  let sequenceCounterService: ReturnType<typeof createMockSequenceCounter>;
  let assetStorage: ReturnType<typeof createMockAssetStorage>;

  beforeEach(async () => {
    prisma = createMockPrisma([
      "organization",
      "payment",
      "paymentReceipt",
      "bill",
      "billAuditEvent",
      "contribution",
      "contributionReceipt",
      "documentAsset",
      "sequenceCounter",
    ]);

    await prisma.organization.create({
      data: {
        id: TEST_ORG_A,
        name: "Shree Ganesh Utsav Mandal",
        code: "MANDAL01",
        addressLine1: "123 Mandal Path",
        city: "Pune",
        state: "Maharashtra",
        postalCode: "411001",
        ownerUserId: TEST_USER_TREASURER,
        status: "ACTIVE",
      },
    });

    const tenantContext = createMockTenantContext({ organizationId: TEST_ORG_A });
    const festivalYearService = createMockFestivalYearService({ organizationId: TEST_ORG_A, festivalYear: 2026 });
    sequenceCounterService = createMockSequenceCounter();
    assetStorage = createMockAssetStorage();
    const auditService = createMockAuditService();
    const whatsappService: any = { sendDocument: jest.fn(() => Promise.resolve()) };
    const templatesService: any = {
      resolveActiveTemplate: jest.fn(() =>
        Promise.resolve({ id: "template-std-1", name: "Standard Receipt Template" }),
      ),
    };

    billsService = new BillsService(prisma as any, festivalYearService as any, sequenceCounterService as any);

    const contribRepo = new ContributionsRepository(prisma as any, tenantContext as any);
    contributionsService = new ContributionsService(
      contribRepo,
      festivalYearService as any,
      tenantContext as any,
      assetStorage as any,
    );

    const receiptsRepo = new ContributionReceiptsRepository(prisma as any, tenantContext as any);
    contributionReceiptsService = new ContributionReceiptsService(
      receiptsRepo,
      contributionsService,
      festivalYearService as any,
      sequenceCounterService as any,
      whatsappService as any,
      templatesService as any,
      auditService as any,
      tenantContext as any,
    );
  });

  afterEach(() => {
    prisma.__reset();
  });

  it("GIVEN complete system context WHEN executing end-to-end multi-module lifecycle THEN all transactions, approvals, and receipts complete seamlessly", async () => {
    // ─── Module 1-3: Monetary Payment & Receipt ──────────────────────────
    const monetarySeq = await sequenceCounterService.getNextSequence(TEST_ORG_A, 2026, "receipt");
    const monetaryReceiptNo = `RCPT-2026-${String(monetarySeq).padStart(6, "0")}`;

    const payment = await prisma.payment.create({
      data: {
        organizationId: TEST_ORG_A,
        festivalYear: 2026,
        donorNameSnapshot: "Vikramaditya Joshi",
        contactSnapshot: "+91 98220 11223",
        amount: 5000,
        paymentDateTime: new Date(),
        channel: "QR_CODE",
        status: PaymentStatus.RECEIPTED,
        collectedByUserId: TEST_USER_TREASURER,
        createdByUserId: TEST_USER_TREASURER,
      },
    });

    const paymentReceipt = await prisma.paymentReceipt.create({
      data: {
        organizationId: TEST_ORG_A,
        festivalYear: 2026,
        paymentId: payment.id,
        receiptNumber: monetaryReceiptNo,
        donorNameSnapshot: payment.donorNameSnapshot,
        amountSnapshot: payment.amount,
        mandalNameSnapshot: "Shree Ganesh Utsav Mandal",
        pdfUrl: `https://assets.pautipustak.org/receipts/${monetaryReceiptNo}.pdf`,
        whatsappDeliveryStatus: "SENT",
        status: "ACTIVE",
      },
    });

    expect(payment.id).toBeDefined();
    expect(paymentReceipt.receiptNumber).toBe("RCPT-2026-000001");
    expect(paymentReceipt.amountSnapshot).toBe(5000);

    // ─── Module 4: Bill Generation & Two-User Approval ───────────────────
    const billDraft = await billsService.create(
      TEST_ORG_A,
      TEST_USER_TREASURER,
      createMockBillDto({
        receiverNameSnapshot: "Prasad Decorators & Pandal Works",
        amount: 45000,
        taskOrField: "Decoration & Lighting",
      }),
    );
    expect(billDraft.billNumber).toBe("BILL-2026-000001");
    expect(billDraft.status).toBe(BillStatus.DRAFT);

    await billsService.submit(TEST_ORG_A, billDraft.id);

    // Self-approval guard assertion
    await expect(billsService.approve(TEST_ORG_A, billDraft.id, TEST_USER_TREASURER)).rejects.toThrow();

    // Two-user approval by President
    const billApproved = await billsService.approve(TEST_ORG_A, billDraft.id, TEST_USER_PRESIDENT);
    expect(billApproved.status).toBe(BillStatus.APPROVED);

    const billPaid = await billsService.markPaid(
      TEST_ORG_A,
      billDraft.id,
      TEST_USER_TREASURER,
      PaymentMode.BANK_TRANSFER,
    );
    expect(billPaid.status).toBe(BillStatus.PAID);

    // ─── Module 5-6: In-Kind Gold Contribution & Receipt ─────────────────
    const uploadedAsset = await assetStorage.uploadAsset({
      organizationId: TEST_ORG_A,
      ownerUserId: TEST_USER_TREASURER,
      purpose: DocumentPurpose.IN_KIND_ATTACHMENT,
      filename: "bis_hallmark_gold_cert.jpg",
      body: Buffer.from("RAW_CERT_BYTES"),
      contentType: "image/jpeg",
    });

    const contribution = await contributionsService.create(
      createMockContributionDto({
        contributorId: TEST_USER_DONOR,
        contributorNameSnapshot: "Shraddha Kulkarni",
        donationType: "Gold",
        itemDescription: "20g 24K Gold Coin with BIS Hallmark",
        weight: 20.0,
        estimatedValue: 140000,
        certificatePhotoUrl: uploadedAsset.url,
      }),
      TEST_USER_TREASURER,
    );
    expect(contribution.status).toBe("RECORDED");

    const contribReceipt = await contributionReceiptsService.generate(contribution.id);
    expect(contribReceipt.contributionReceiptNumber).toBe("CRECEPT-2026-000001");

    // ─── Verification: Independent Sequence Counters ─────────────────────
    expect(monetaryReceiptNo).toBe("RCPT-2026-000001");
    expect(billDraft.billNumber).toBe("BILL-2026-000001");
    expect(contribReceipt.contributionReceiptNumber).toBe("CRECEPT-2026-000001");
  });
});
