/**
 * BillsService — Unit Tests
 *
 * Structure: GIVEN-WHEN-THEN behavioral contracts.
 * Mock source: @pauti-pustak/backend-testing (no inline mock construction).
 */
import { ConflictException, ForbiddenException } from "@nestjs/common";
import { BillStatus, PaymentMode } from "@pauti-pustak/backend-database";
import {
  createMockPrisma,
  createMockBillDto,
  createMockFestivalYearService,
  createMockSequenceCounter,
  createMockLedger,
  createMockOcr,
  TEST_ORG_A,
  TEST_ORG_B,
  TEST_USER_TREASURER,
  TEST_USER_PRESIDENT,
} from "@pauti-pustak/backend-testing";
import { BillsService } from "./bills.service";

// ─── Shared Setup ────────────────────────────────────────────────────────────

function buildService(overrides: { festivalYear?: number; ocrProposed?: any } = {}) {
  const prisma = createMockPrisma(["bill", "billAuditEvent"]);
  const festivalYear = createMockFestivalYearService({ festivalYear: overrides.festivalYear });
  const sequenceCounter = createMockSequenceCounter();
  const ledger = createMockLedger();
  const ocr = createMockOcr(overrides.ocrProposed);

  const service = new BillsService(
    prisma as any,
    festivalYear as any,
    sequenceCounter as any,
    ledger as any,
    ocr as any,
  );

  return { service, prisma, festivalYear, sequenceCounter, ledger, ocr };
}

// ─── Create & Numbering ──────────────────────────────────────────────────────

describe("BillsService - create + numbering", () => {
  it("GIVEN three sequential bills WHEN created for the same org+year THEN assigns unique sequential bill numbers", async () => {
    const { service } = buildService();
    const dto = createMockBillDto();

    const b1 = await service.create(TEST_ORG_A, TEST_USER_TREASURER, dto);
    const b2 = await service.create(TEST_ORG_A, TEST_USER_TREASURER, dto);
    const b3 = await service.create(TEST_ORG_A, TEST_USER_TREASURER, dto);

    expect(b1.billNumber).toBe("BILL-2026-000001");
    expect(b2.billNumber).toBe("BILL-2026-000002");
    expect(b3.billNumber).toBe("BILL-2026-000003");
  });

  it("GIVEN a DTO with only required fields WHEN created THEN optional fields default to null and status is DRAFT", async () => {
    const { service } = buildService();
    const dto = createMockBillDto();

    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, dto);

    expect(created.vendorId).toBeNull();
    expect(created.contactSnapshot).toBeNull();
    expect(created.milestoneId).toBeNull();
    expect(created.billPhotoUrl).toBeNull();
    expect(created.status).toBe(BillStatus.DRAFT);
  });

  it("GIVEN a valid DTO with custom amount WHEN created THEN persists the exact amount and properties", async () => {
    const { service } = buildService();
    const dto = createMockBillDto({ amount: 25000 });

    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, dto);
    expect(created.amount).toBe(25000);
  });
});

// ─── State Machine (Full Path) ───────────────────────────────────────────────

describe("BillsService - full state machine (service level)", () => {
  it("GIVEN a DRAFT bill WHEN markPaid is called directly THEN rejects (skipping submit+approve)", async () => {
    const { service } = buildService();
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());

    await expect(
      service.markPaid(TEST_ORG_A, created.id, TEST_USER_TREASURER, PaymentMode.CASH),
    ).rejects.toBeInstanceOf(ConflictException);
  });

  it("GIVEN a DRAFT bill WHEN approve is called directly THEN rejects (skipping submit)", async () => {
    const { service } = buildService();
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());

    await expect(service.approve(TEST_ORG_A, created.id, TEST_USER_PRESIDENT)).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it("GIVEN a PENDING_APPROVAL bill WHEN markPaid is called directly THEN rejects (skipping approve)", async () => {
    const { service } = buildService();
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());
    await service.submit(TEST_ORG_A, created.id);

    await expect(
      service.markPaid(TEST_ORG_A, created.id, TEST_USER_TREASURER, PaymentMode.CASH),
    ).rejects.toBeInstanceOf(ConflictException);
  });

  it("GIVEN a DRAFT bill WHEN walking Draft→Pending→Approved→Paid THEN each transition succeeds and ledger is called", async () => {
    const { service, ledger } = buildService();
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());

    await service.submit(TEST_ORG_A, created.id);
    const approved = await service.approve(TEST_ORG_A, created.id, TEST_USER_PRESIDENT);
    expect(approved.status).toBe(BillStatus.APPROVED);

    const paid = await service.markPaid(TEST_ORG_A, created.id, TEST_USER_TREASURER, PaymentMode.UPI);
    expect(paid.status).toBe(BillStatus.PAID);
    expect(paid.paymentMode).toBe(PaymentMode.UPI);
    expect(ledger.recordBillPayment).toHaveBeenCalledTimes(1);
    expect(ledger.recordBillPayment).toHaveBeenCalledWith(
      expect.objectContaining({
        billId: created.id,
        billNumber: created.billNumber,
        paymentMode: PaymentMode.UPI,
      }),
    );
  });
});

// ─── Self-Approval Prohibition ───────────────────────────────────────────────

describe("BillsService - self-approval prohibition", () => {
  it("GIVEN a bill submitted by treasurer-1 WHEN treasurer-1 tries to approve it THEN throws ForbiddenException", async () => {
    const { service } = buildService();
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());
    await service.submit(TEST_ORG_A, created.id);

    await expect(service.approve(TEST_ORG_A, created.id, TEST_USER_TREASURER)).rejects.toBeInstanceOf(
      ForbiddenException,
    );

    const reloaded = await service.getById(TEST_ORG_A, created.id);
    expect(reloaded.status).toBe(BillStatus.PENDING_APPROVAL);
  });

  it("GIVEN a bill submitted by treasurer WHEN a different user approves THEN status moves to APPROVED", async () => {
    const { service } = buildService();
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());
    await service.submit(TEST_ORG_A, created.id);

    const approved = await service.approve(TEST_ORG_A, created.id, TEST_USER_PRESIDENT);
    expect(approved.status).toBe(BillStatus.APPROVED);
  });
});

// ─── Reject Path ─────────────────────────────────────────────────────────────

describe("BillsService - reject path", () => {
  it("GIVEN a PENDING_APPROVAL bill WHEN rejected with a reason THEN returns to DRAFT (not deleted)", async () => {
    const { service, prisma } = buildService();
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());
    await service.submit(TEST_ORG_A, created.id);

    const rejected = await service.reject(TEST_ORG_A, created.id, TEST_USER_PRESIDENT, "Amount doesn't match the photo");

    expect(rejected.status).toBe(BillStatus.DRAFT);
    expect(rejected.rejectionReason).toBe("Amount doesn't match the photo");
    expect(prisma.bill.__store.has(created.id)).toBe(true);
  });

  it("GIVEN a rejected bill (now DRAFT) WHEN edited and resubmitted THEN moves to PENDING_APPROVAL again", async () => {
    const { service } = buildService();
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());
    await service.submit(TEST_ORG_A, created.id);
    await service.reject(TEST_ORG_A, created.id, TEST_USER_PRESIDENT, "wrong amount");

    const updated = await service.update(TEST_ORG_A, created.id, { amount: 20000 });
    expect(updated.amount).toBe(20000);

    const resubmitted = await service.submit(TEST_ORG_A, created.id);
    expect(resubmitted.status).toBe(BillStatus.PENDING_APPROVAL);
  });
});

// ─── OCR Pre-fill ────────────────────────────────────────────────────────────

describe("BillsService - OCR pre-fill", () => {
  it("GIVEN a bill photo URL WHEN previewOcr is called THEN returns proposed fields without creating any bill", async () => {
    const proposed = { amount: 15000, receiverName: "Ganesh Decorators", date: "2026-08-01" };
    const { service, prisma, ocr } = buildService({ ocrProposed: proposed });

    const result = await service.previewOcr("https://storage.example/bill-photo.jpg");

    expect(ocr.proposeFields).toHaveBeenCalledWith("https://storage.example/bill-photo.jpg");
    expect(result).toEqual(proposed);
    expect(prisma.bill.create).not.toHaveBeenCalled();
  });
});

// ─── Immutability & Cancel ───────────────────────────────────────────────────

describe("BillsService - immutability and cancel", () => {
  it("GIVEN a PAID bill WHEN amount is patched directly THEN throws ForbiddenException", async () => {
    const { service } = buildService();
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());
    await service.submit(TEST_ORG_A, created.id);
    await service.approve(TEST_ORG_A, created.id, TEST_USER_PRESIDENT);
    await service.markPaid(TEST_ORG_A, created.id, TEST_USER_TREASURER, PaymentMode.CASH);

    await expect(service.update(TEST_ORG_A, created.id, { amount: 99999 })).rejects.toBeInstanceOf(
      ForbiddenException,
    );
  });

  it("GIVEN a PAID bill WHEN submit/approve/markPaid are retried THEN all throw ConflictException; only cancel succeeds", async () => {
    const { service } = buildService();
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());
    await service.submit(TEST_ORG_A, created.id);
    await service.approve(TEST_ORG_A, created.id, TEST_USER_PRESIDENT);
    await service.markPaid(TEST_ORG_A, created.id, TEST_USER_TREASURER, PaymentMode.CASH);

    await expect(service.submit(TEST_ORG_A, created.id)).rejects.toBeInstanceOf(ConflictException);
    await expect(service.approve(TEST_ORG_A, created.id, TEST_USER_PRESIDENT)).rejects.toBeInstanceOf(
      ConflictException,
    );
    await expect(
      service.markPaid(TEST_ORG_A, created.id, TEST_USER_TREASURER, PaymentMode.CASH),
    ).rejects.toBeInstanceOf(ConflictException);

    const cancelled = await service.cancel(TEST_ORG_A, created.id, TEST_USER_PRESIDENT, "Duplicate bill entry");
    expect(cancelled.status).toBe(BillStatus.CANCELLED);
    expect(cancelled.cancelReason).toBe("Duplicate bill entry");
    // Core fields untouched by cancel.
    expect(cancelled.amount).toBe(created.amount);
    expect(cancelled.receiverNameSnapshot).toBe(created.receiverNameSnapshot);
  });
});

// ─── Multi-Tenant Isolation ──────────────────────────────────────────────────

describe("BillsService - multi-tenant isolation", () => {
  it("GIVEN Org B's bill WHEN Org A tries to retrieve or approve by id THEN throws 'Bill not found'", async () => {
    const { service } = buildService();
    const created = await service.create(TEST_ORG_B, TEST_USER_TREASURER, createMockBillDto());

    await expect(service.getById(TEST_ORG_A, created.id)).rejects.toThrow("Bill not found");
    await expect(service.approve(TEST_ORG_A, created.id, TEST_USER_PRESIDENT)).rejects.toThrow("Bill not found");
  });

  it("GIVEN bills in Org A and Org B WHEN Org A lists bills THEN result contains only Org A's bills", async () => {
    const { service } = buildService();
    await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto({ taskOrField: "A task" }));
    await service.create(TEST_ORG_B, TEST_USER_TREASURER, createMockBillDto({ taskOrField: "B task" }));

    const results = await service.list(TEST_ORG_A, {});

    expect(results).toHaveLength(1);
    expect(results[0].organizationId).toBe(TEST_ORG_A);
  });
});

// ─── Edge Cases (Phase 3) ────────────────────────────────────────────────────

describe("BillsService - edge cases", () => {
  it("GIVEN an empty org WHEN list is called THEN returns empty array (not null/undefined)", async () => {
    const { service } = buildService();

    const results = await service.list(TEST_ORG_A, {});

    expect(results).toEqual([]);
    expect(Array.isArray(results)).toBe(true);
  });

  it("GIVEN a non-existent bill id WHEN getById is called THEN throws NotFoundException", async () => {
    const { service } = buildService();

    await expect(service.getById(TEST_ORG_A, "non-existent-id")).rejects.toThrow();
  });

  it("GIVEN a CANCELLED bill WHEN submit is called THEN throws ConflictException", async () => {
    const { service } = buildService();
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());
    await service.submit(TEST_ORG_A, created.id);
    await service.approve(TEST_ORG_A, created.id, TEST_USER_PRESIDENT);
    await service.markPaid(TEST_ORG_A, created.id, TEST_USER_TREASURER, PaymentMode.CASH);
    await service.cancel(TEST_ORG_A, created.id, TEST_USER_PRESIDENT, "Duplicate");

    await expect(service.submit(TEST_ORG_A, created.id)).rejects.toBeInstanceOf(ConflictException);
  });

  it("GIVEN a CANCELLED bill WHEN cancel is called again THEN throws ConflictException (idempotent guard)", async () => {
    const { service } = buildService();
    const created = await service.create(TEST_ORG_A, TEST_USER_TREASURER, createMockBillDto());
    await service.submit(TEST_ORG_A, created.id);
    await service.approve(TEST_ORG_A, created.id, TEST_USER_PRESIDENT);
    await service.markPaid(TEST_ORG_A, created.id, TEST_USER_TREASURER, PaymentMode.CASH);
    await service.cancel(TEST_ORG_A, created.id, TEST_USER_PRESIDENT, "Duplicate");

    await expect(
      service.cancel(TEST_ORG_A, created.id, TEST_USER_PRESIDENT, "Double cancel"),
    ).rejects.toBeInstanceOf(ConflictException);
  });
});
