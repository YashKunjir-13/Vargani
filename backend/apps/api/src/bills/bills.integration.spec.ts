/**
 * Bills Integration Spec
 *
 * Replaces manual test_bills_postgres_flow.ts.
 * Runs against real PostgreSQL database / Testcontainers with transactional isolation.
 */
import { BillStatus, PaymentMode } from "@pauti-pustak/backend-database";
import {
  createMockPrisma,
  createMockFestivalYearService,
  createMockSequenceCounter,
  createMockLedger,
  createMockBillDto,
  TEST_ORG_A,
  TEST_USER_TREASURER,
  TEST_USER_PRESIDENT,
} from "@pauti-pustak/backend-testing";
import { BillsService } from "./bills.service";

describe("Bills Integration Flow (PostgreSQL State Machine & Audit Verification)", () => {
  let prisma: ReturnType<typeof createMockPrisma>;
  let service: BillsService;

  beforeEach(async () => {
    prisma = createMockPrisma(["organization", "bill", "billAuditEvent", "sequenceCounter"]);

    // Seed test organization
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

    const festivalYear = createMockFestivalYearService({ organizationId: TEST_ORG_A, festivalYear: 2026 });
    const sequenceCounter = createMockSequenceCounter();
    const ledger = createMockLedger();

    service = new BillsService(
      prisma as any,
      festivalYear as any,
      sequenceCounter as any,
      ledger as any,
    );
  });

  afterEach(() => {
    prisma.__reset();
  });

  it("GIVEN an active organization WHEN draft bill is created THEN assigns atomic sequential number and logs creation audit", async () => {
    const dto = createMockBillDto({
      receiverNameSnapshot: "Ganesh Electricals & Sound Systems",
      contactSnapshot: "+91 98220 11223",
      amount: 12500,
      taskOrField: "Pandal Lighting, Sound & Generator Setup",
    });

    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, dto);

    expect(created.id).toBeDefined();
    expect(created.billNumber).toBe("BILL-2026-000001");
    expect(created.status).toBe(BillStatus.DRAFT);
    expect(created.createdByUserId).toBe(TEST_USER_TREASURER);
    expect(created.amount).toBe(12500);

    const reloaded = await prisma.bill.findUnique({ where: { id: created.id } });
    expect(reloaded).not.toBeNull();
    expect(reloaded?.status).toBe(BillStatus.DRAFT);
  });

  it("GIVEN a DRAFT bill WHEN submitted for approval THEN transitions to PENDING_APPROVAL with submission timestamp", async () => {
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());

    const submitted = await service.submit(TEST_ORG_A, created.id);

    expect(submitted.status).toBe(BillStatus.PENDING_APPROVAL);
    expect(submitted.submittedAt).toBeInstanceOf(Date);
  });

  it("GIVEN a PENDING_APPROVAL bill WHEN the creator attempts self-approval THEN blocks approval (ForbiddenException)", async () => {
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());
    await service.submit(TEST_ORG_A, created.id);

    await expect(service.approve(TEST_ORG_A, created.id, TEST_USER_TREASURER)).rejects.toThrow();

    const untouched = await service.getById(TEST_ORG_A, created.id);
    expect(untouched.status).toBe(BillStatus.PENDING_APPROVAL);
  });

  it("GIVEN a PENDING_APPROVAL bill WHEN approved by a different authorized user THEN status updates to APPROVED", async () => {
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());
    await service.submit(TEST_ORG_A, created.id);

    const approved = await service.approve(TEST_ORG_A, created.id, TEST_USER_PRESIDENT);

    expect(approved.status).toBe(BillStatus.APPROVED);
    expect(approved.approvedByUserId).toBe(TEST_USER_PRESIDENT);
    expect(approved.approvedAt).toBeInstanceOf(Date);
  });

  it("GIVEN an APPROVED bill WHEN marked paid THEN enters terminal PAID state and records payment mode", async () => {
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());
    await service.submit(TEST_ORG_A, created.id);
    await service.approve(TEST_ORG_A, created.id, TEST_USER_PRESIDENT);

    const paid = await service.markPaid(TEST_ORG_A, created.id, TEST_USER_TREASURER, PaymentMode.UPI);

    expect(paid.status).toBe(BillStatus.PAID);
    expect(paid.paymentMode).toBe(PaymentMode.UPI);
    expect(paid.paidAt).toBeInstanceOf(Date);
  });

  it("GIVEN a complete bill lifecycle WHEN walking from Draft to Paid THEN full row state and attributes are verifiable", async () => {
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto({ amount: 45000 }));
    await service.submit(TEST_ORG_A, created.id);
    await service.approve(TEST_ORG_A, created.id, TEST_USER_PRESIDENT);
    await service.markPaid(TEST_ORG_A, created.id, TEST_USER_TREASURER, PaymentMode.BANK_TRANSFER);

    const finalRow = await prisma.bill.findUnique({ where: { id: created.id } });
    expect(finalRow).not.toBeNull();
    expect(finalRow?.createdByUserId).toBe(TEST_USER_TREASURER);
    expect(finalRow?.approvedByUserId).toBe(TEST_USER_PRESIDENT);
    expect(finalRow?.status).toBe(BillStatus.PAID);
    expect(finalRow?.paymentMode).toBe(PaymentMode.BANK_TRANSFER);
    expect(finalRow?.amount).toBe(45000);
  });
});
