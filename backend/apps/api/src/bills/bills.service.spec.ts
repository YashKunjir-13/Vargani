import { ConflictException, ForbiddenException } from "@nestjs/common";
import { BillStatus, PaymentMode } from "@pauti-pustak/backend-database";
import { BillsService } from "./bills.service";

const ORG_A = "org-a";
const ORG_B = "org-b";

function buildPrismaMock() {
  const bills = new Map<string, any>();
  const auditEvents: any[] = [];
  let idCounter = 0;

  const bill = {
    create: jest.fn(({ data }: any) => {
      idCounter += 1;
      const row = { id: `bill-${idCounter}`, createdAt: new Date(), updatedAt: new Date(), ...data };
      bills.set(row.id, row);
      return Promise.resolve({ ...row });
    }),
    findUnique: jest.fn(({ where }: any) => Promise.resolve(bills.get(where.id) ?? null)),
    findMany: jest.fn(({ where }: any) =>
      Promise.resolve(
        [...bills.values()].filter((b) => {
          if (b.organizationId !== where.organizationId) return false;
          if (where.status && b.status !== where.status) return false;
          if (where.vendorId && b.vendorId !== where.vendorId) return false;
          if (where.taskOrField && b.taskOrField !== where.taskOrField) return false;
          return true;
        }),
      ),
    ),
    update: jest.fn(({ where, data }: any) => {
      const row = { ...bills.get(where.id), ...data };
      bills.set(where.id, row);
      return Promise.resolve({ ...row });
    }),
  };

  const billAuditEvent = {
    create: jest.fn(({ data }: any) => {
      auditEvents.push(data);
      return Promise.resolve({ id: `audit-${auditEvents.length}`, createdAt: new Date(), ...data });
    }),
  };

  return { bill, billAuditEvent, __bills: bills, __auditEvents: auditEvents };
}

function buildFestivalYearMock(festivalYear = 2026) {
  return {
    getActiveFestivalYear: jest.fn(() =>
      Promise.resolve({ eventId: "event-1", organizationId: ORG_A, festivalYear, financialYearLabel: "2025-26" }),
    ),
  };
}

function buildSequenceCounterMock() {
  const counters = new Map<string, number>();
  return {
    getNextSequence: jest.fn((organizationId: string, festivalYear: number, sequenceName: string) => {
      const key = `${organizationId}:${festivalYear}:${sequenceName}`;
      const next = (counters.get(key) ?? 0) + 1;
      counters.set(key, next);
      return Promise.resolve(BigInt(next));
    }),
  };
}

function buildLedgerMock() {
  return { recordBillPayment: jest.fn(() => Promise.resolve()) };
}

function buildOcrMock(proposed: any = {}) {
  return { proposeFields: jest.fn(() => Promise.resolve(proposed)) };
}

function buildService(overrides: { festivalYear?: number; ocrProposed?: any } = {}) {
  const prisma = buildPrismaMock();
  const festivalYear = buildFestivalYearMock(overrides.festivalYear);
  const sequenceCounter = buildSequenceCounterMock();
  const ledger = buildLedgerMock();
  const ocr = buildOcrMock(overrides.ocrProposed);

  const service = new BillsService(prisma as any, festivalYear as any, sequenceCounter as any, ledger as any, ocr as any);

  return { service, prisma, festivalYear, sequenceCounter, ledger, ocr };
}

function createDto(overrides: Partial<Record<string, any>> = {}) {
  return {
    receiverNameSnapshot: "Ganesh Decorators",
    amount: 15000,
    date: "2026-08-01",
    taskOrField: "Mandap Decoration",
    ...overrides,
  };
}

describe("BillsService - create + numbering", () => {
  it("assigns unique, sequential bill numbers within an organizationId+festivalYear", async () => {
    const { service } = buildService();

    const b1 = await service.create(ORG_A, "treasurer-1", createDto());
    const b2 = await service.create(ORG_A, "treasurer-1", createDto());
    const b3 = await service.create(ORG_A, "treasurer-1", createDto());

    expect(b1.billNumber).toBe("BILL-2026-000001");
    expect(b2.billNumber).toBe("BILL-2026-000002");
    expect(b3.billNumber).toBe("BILL-2026-000003");
  });

  it("saves fine when contactSnapshot/vendorId/milestoneId/billPhotoUrl are all omitted", async () => {
    const { service } = buildService();

    const created = await service.create(ORG_A, "treasurer-1", createDto());

    expect(created.vendorId).toBeNull();
    expect(created.contactSnapshot).toBeNull();
    expect(created.milestoneId).toBeNull();
    expect(created.billPhotoUrl).toBeNull();
    expect(created.status).toBe(BillStatus.DRAFT);
  });
});

describe("BillsService - full state machine (service level)", () => {
  it("rejects Draft -> Paid directly (skipping submit and approve)", async () => {
    const { service } = buildService();
    const created = await service.create(ORG_A, "treasurer-1", createDto());

    await expect(
      service.markPaid(ORG_A, created.id, "treasurer-1", PaymentMode.CASH),
    ).rejects.toBeInstanceOf(ConflictException);
  });

  it("rejects Draft -> Approved directly (skipping submit)", async () => {
    const { service } = buildService();
    const created = await service.create(ORG_A, "treasurer-1", createDto());

    await expect(service.approve(ORG_A, created.id, "president-1")).rejects.toBeInstanceOf(ConflictException);
  });

  it("rejects Pending Approval -> Paid directly (skipping approve)", async () => {
    const { service } = buildService();
    const created = await service.create(ORG_A, "treasurer-1", createDto());
    await service.submit(ORG_A, created.id);

    await expect(
      service.markPaid(ORG_A, created.id, "treasurer-1", PaymentMode.CASH),
    ).rejects.toBeInstanceOf(ConflictException);
  });

  it("walks the full happy path: Draft -> Pending Approval -> Approved -> Paid", async () => {
    const { service, ledger } = buildService();
    const created = await service.create(ORG_A, "treasurer-1", createDto());

    await service.submit(ORG_A, created.id);
    const approved = await service.approve(ORG_A, created.id, "president-1");
    expect(approved.status).toBe(BillStatus.APPROVED);

    const paid = await service.markPaid(ORG_A, created.id, "treasurer-1", PaymentMode.UPI);
    expect(paid.status).toBe(BillStatus.PAID);
    expect(paid.paymentMode).toBe(PaymentMode.UPI);
    expect(ledger.recordBillPayment).toHaveBeenCalledTimes(1);
    expect(ledger.recordBillPayment).toHaveBeenCalledWith(
      expect.objectContaining({ billId: created.id, billNumber: created.billNumber, paymentMode: PaymentMode.UPI }),
    );
  });
});

describe("BillsService - self-approval prohibition", () => {
  it("CRITICAL: the same user who created/submitted a bill cannot also approve it, even holding bill.approve", async () => {
    const { service } = buildService();
    const created = await service.create(ORG_A, "treasurer-1", createDto());
    await service.submit(ORG_A, created.id);

    await expect(service.approve(ORG_A, created.id, "treasurer-1")).rejects.toBeInstanceOf(ForbiddenException);

    const reloaded = await service.getById(ORG_A, created.id);
    expect(reloaded.status).toBe(BillStatus.PENDING_APPROVAL);
  });

  it("allows approval by a different user", async () => {
    const { service } = buildService();
    const created = await service.create(ORG_A, "treasurer-1", createDto());
    await service.submit(ORG_A, created.id);

    const approved = await service.approve(ORG_A, created.id, "president-1");
    expect(approved.status).toBe(BillStatus.APPROVED);
  });
});

describe("BillsService - reject path", () => {
  it("returns a Pending Approval bill to Draft with a mandatory reason, not a delete", async () => {
    const { service, prisma } = buildService();
    const created = await service.create(ORG_A, "treasurer-1", createDto());
    await service.submit(ORG_A, created.id);

    const rejected = await service.reject(ORG_A, created.id, "president-1", "Amount doesn't match the photo");

    expect(rejected.status).toBe(BillStatus.DRAFT);
    expect(rejected.rejectionReason).toBe("Amount doesn't match the photo");
    expect(prisma.__bills.has(created.id)).toBe(true);
  });

  it("a rejected (now Draft) bill is editable and resubmittable again", async () => {
    const { service } = buildService();
    const created = await service.create(ORG_A, "treasurer-1", createDto());
    await service.submit(ORG_A, created.id);
    await service.reject(ORG_A, created.id, "president-1", "wrong amount");

    const updated = await service.update(ORG_A, created.id, { amount: 20000 });
    expect(updated.amount).toBe(20000);

    const resubmitted = await service.submit(ORG_A, created.id);
    expect(resubmitted.status).toBe(BillStatus.PENDING_APPROVAL);
  });
});

describe("BillsService - OCR pre-fill", () => {
  it("the OCR hook receives billPhotoUrl and returns proposed values without touching any bill or auto-submitting", async () => {
    const proposed = { amount: 15000, receiverName: "Ganesh Decorators", date: "2026-08-01" };
    const { service, prisma, ocr } = buildService({ ocrProposed: proposed });

    const result = await service.previewOcr("https://storage.example/bill-photo.jpg");

    expect(ocr.proposeFields).toHaveBeenCalledWith("https://storage.example/bill-photo.jpg");
    expect(result).toEqual(proposed);
    expect(prisma.bill.create).not.toHaveBeenCalled();
  });
});

describe("BillsService - immutability and cancel", () => {
  it("direct PATCH on a Paid bill's amount is rejected", async () => {
    const { service } = buildService();
    const created = await service.create(ORG_A, "treasurer-1", createDto());
    await service.submit(ORG_A, created.id);
    await service.approve(ORG_A, created.id, "president-1");
    await service.markPaid(ORG_A, created.id, "treasurer-1", PaymentMode.CASH);

    await expect(service.update(ORG_A, created.id, { amount: 99999 })).rejects.toBeInstanceOf(ForbiddenException);
  });

  it("only /cancel may alter a Paid bill's status thereafter", async () => {
    const { service } = buildService();
    const created = await service.create(ORG_A, "treasurer-1", createDto());
    await service.submit(ORG_A, created.id);
    await service.approve(ORG_A, created.id, "president-1");
    await service.markPaid(ORG_A, created.id, "treasurer-1", PaymentMode.CASH);

    await expect(service.submit(ORG_A, created.id)).rejects.toBeInstanceOf(ConflictException);
    await expect(service.approve(ORG_A, created.id, "president-1")).rejects.toBeInstanceOf(ConflictException);
    await expect(
      service.markPaid(ORG_A, created.id, "treasurer-1", PaymentMode.CASH),
    ).rejects.toBeInstanceOf(ConflictException);

    const cancelled = await service.cancel(ORG_A, created.id, "president-1", "Duplicate bill entry");
    expect(cancelled.status).toBe(BillStatus.CANCELLED);
    expect(cancelled.cancelReason).toBe("Duplicate bill entry");
    // Core fields untouched by cancel.
    expect(cancelled.amount).toBe(created.amount);
    expect(cancelled.receiverNameSnapshot).toBe(created.receiverNameSnapshot);
  });
});

describe("BillsService - multi-tenant isolation", () => {
  it("Org A cannot retrieve or approve Org B's bill, even by guessing the id", async () => {
    const { service } = buildService();
    const created = await service.create(ORG_B, "treasurer-1", createDto());

    await expect(service.getById(ORG_A, created.id)).rejects.toThrow("Bill not found");
    await expect(service.approve(ORG_A, created.id, "president-1")).rejects.toThrow("Bill not found");
  });

  it("Org A's list never includes Org B's bills", async () => {
    const { service } = buildService();
    await service.create(ORG_A, "treasurer-1", createDto({ taskOrField: "A task" }));
    await service.create(ORG_B, "treasurer-1", createDto({ taskOrField: "B task" }));

    const results = await service.list(ORG_A, {});

    expect(results).toHaveLength(1);
    expect(results[0].organizationId).toBe(ORG_A);
  });
});
