import { ConflictException, NotFoundException } from "@nestjs/common";
import { PaymentReceiptStatus, WhatsAppDeliveryStatus } from "@pauti-pustak/backend-database";
import { ReceiptsService } from "./receipts.service";

const ORG_A = "org-a";
const ORG_B = "org-b";

function buildPrismaMock() {
  const receipts = new Map<string, any>();
  const auditEvents: any[] = [];
  const organizations = new Map<string, any>([[ORG_A, { id: ORG_A, name: "Shree Ganesh Mandal" }]]);
  const documentAssets: any[] = [];
  const donorProfiles = new Map<string, any>();
  const payments = new Map<string, any>();
  const deliveries = new Map<string, any>();
  let idCounter = 0;

  const paymentReceipt = {
    create: jest.fn(({ data }: any) => {
      idCounter += 1;
      const row = { id: `receipt-${idCounter}`, createdAt: new Date(), updatedAt: new Date(), ...data };
      receipts.set(row.id, row);
      return Promise.resolve({ ...row });
    }),
    findUnique: jest.fn(({ where }: any) => {
      if (where.id) return Promise.resolve(receipts.get(where.id) ?? null);
      if (where.paymentId) {
        return Promise.resolve([...receipts.values()].find((r) => r.paymentId === where.paymentId) ?? null);
      }
      return Promise.resolve(null);
    }),
    findMany: jest.fn(({ where }: any) =>
      Promise.resolve(
        [...receipts.values()].filter((r) => {
          if (r.organizationId !== where.organizationId) return false;
          if (where.donorId && r.donorId !== where.donorId) return false;
          if (where.status && r.status !== where.status) return false;
          return true;
        }),
      ),
    ),
    update: jest.fn(({ where, data }: any) => {
      const existing = receipts.get(where.id);
      const resolvedData = Object.fromEntries(
        Object.entries(data).map(([key, value]: [string, any]) =>
          value && typeof value === "object" && "increment" in value
            ? [key, (existing?.[key] ?? 0) + value.increment]
            : [key, value],
        ),
      );
      const row = { ...existing, ...resolvedData };
      receipts.set(where.id, row);
      return Promise.resolve({ ...row });
    }),
  };

  const paymentReceiptAuditEvent = {
    create: jest.fn(({ data }: any) => {
      auditEvents.push(data);
      return Promise.resolve({ id: `audit-${auditEvents.length}`, createdAt: new Date(), ...data });
    }),
  };

  const organization = {
    findUnique: jest.fn(({ where }: any) => Promise.resolve(organizations.get(where.id) ?? null)),
  };

  const documentAsset = {
    findFirst: jest.fn(({ where }: any) =>
      Promise.resolve(
        documentAssets.find((a) => a.organizationId === where.organizationId && a.purpose === where.purpose) ??
          null,
      ),
    ),
  };

  const donorProfile = {
    findUnique: jest.fn(({ where }: any) => {
      if (where.id) return Promise.resolve(donorProfiles.get(where.id) ?? null);
      if (where.userId) {
        return Promise.resolve([...donorProfiles.values()].find((d) => d.userId === where.userId) ?? null);
      }
      return Promise.resolve(null);
    }),
  };

  const payment = {
    findUnique: jest.fn(({ where }: any) => Promise.resolve(payments.get(where.id) ?? null)),
  };

  const whatsAppDeliveryRecord = {
    findUnique: jest.fn(({ where }: any) => Promise.resolve(deliveries.get(where.id) ?? null)),
  };

  return {
    paymentReceipt,
    paymentReceiptAuditEvent,
    organization,
    documentAsset,
    donorProfile,
    payment,
    whatsAppDeliveryRecord,
    __receipts: receipts,
    __auditEvents: auditEvents,
    __organizations: organizations,
    __documentAssets: documentAssets,
    __donorProfiles: donorProfiles,
    __payments: payments,
    __deliveries: deliveries,
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

function buildAssetStorageMock() {
  let counter = 0;
  return {
    uploadAsset: jest.fn(() => {
      counter += 1;
      return Promise.resolve({
        documentId: `doc-${counter}`,
        objectKey: `tenants/org/receipt-${counter}.pdf`,
        url: `https://signed.example/receipt-${counter}.pdf`,
      });
    }),
    getDownloadUrl: jest.fn((objectKey: string) => Promise.resolve(`https://signed.example/${objectKey}`)),
  };
}

function buildWhatsAppDeliveryMock(prisma: ReturnType<typeof buildPrismaMock>, outcome: "SENT" | "FAILED" = "SENT") {
  let counter = 0;
  return {
    sendDocument: jest.fn(() => {
      counter += 1;
      const deliveryId = `delivery-${counter}`;
      prisma.__deliveries.set(deliveryId, { id: deliveryId, status: outcome as WhatsAppDeliveryStatus });
      return Promise.resolve({ deliveryId });
    }),
  };
}

function buildTemplatesServiceMock(activeTemplate: any = null) {
  return { resolveActiveTemplate: jest.fn(() => Promise.resolve(activeTemplate)) };
}

function buildPdfRendererMock() {
  return { render: jest.fn(() => Promise.resolve(Buffer.from("stub-pdf"))) };
}

function buildService(overrides: {
  prisma?: ReturnType<typeof buildPrismaMock>;
  whatsAppOutcome?: "SENT" | "FAILED";
  activeTemplate?: any;
} = {}) {
  const prisma = overrides.prisma ?? buildPrismaMock();
  const sequenceCounter = buildSequenceCounterMock();
  const assetStorage = buildAssetStorageMock();
  const whatsAppDelivery = buildWhatsAppDeliveryMock(prisma, overrides.whatsAppOutcome);
  const templatesService = buildTemplatesServiceMock(overrides.activeTemplate);
  const pdfRenderer = buildPdfRendererMock();

  const service = new ReceiptsService(
    prisma as any,
    sequenceCounter as any,
    assetStorage as any,
    whatsAppDelivery as any,
    templatesService as any,
    pdfRenderer as any,
  );

  return { service, prisma, sequenceCounter, assetStorage, whatsAppDelivery, templatesService, pdfRenderer };
}

function generateParams(overrides: Partial<Record<string, any>> = {}) {
  return {
    organizationId: ORG_A,
    festivalYear: 2026,
    paymentId: "payment-1",
    donorId: null,
    donorNameSnapshot: "Ramesh Kulkarni",
    amount: 501,
    contactSnapshot: "9876543210",
    createdByUserId: "user-1",
    ...overrides,
  };
}

describe("ReceiptsService - sequential numbering", () => {
  it("assigns unique, gapless, sequential receipt numbers under simulated concurrent confirmations", async () => {
    const { service, prisma } = buildService();

    await Promise.all(
      Array.from({ length: 20 }, (_, i) => service.generateReceipt(generateParams({ paymentId: `payment-${i}` }))),
    );

    const receiptNumbers = [...prisma.__receipts.values()].map((r) => r.receiptNumber).sort();
    const expected = Array.from({ length: 20 }, (_, i) => `RCPT-2026-${String(i + 1).padStart(6, "0")}`).sort();

    expect(receiptNumbers).toHaveLength(20);
    expect(new Set(receiptNumbers).size).toBe(20);
    expect(receiptNumbers).toEqual(expected);
  });
});

describe("ReceiptsService - generation idempotency", () => {
  it("no-ops (does not create a second receipt or consume another sequence number) if one already exists for the paymentId", async () => {
    const { service, prisma, sequenceCounter } = buildService();

    await service.generateReceipt(generateParams());
    await service.generateReceipt(generateParams());

    expect(prisma.paymentReceipt.create).toHaveBeenCalledTimes(1);
    expect(sequenceCounter.getNextSequence).toHaveBeenCalledTimes(1);
    expect([...prisma.__receipts.values()]).toHaveLength(1);
  });
});

describe("ReceiptsService - generation content", () => {
  it("dispatches WhatsApp delivery on generation and tracks the outcome on the receipt", async () => {
    const { service, prisma, whatsAppDelivery } = buildService({ whatsAppOutcome: "SENT" });

    await service.generateReceipt(generateParams());

    expect(whatsAppDelivery.sendDocument).toHaveBeenCalledTimes(1);
    const receipt = [...prisma.__receipts.values()][0];
    expect(receipt.whatsappDeliveryStatus).toBe(WhatsAppDeliveryStatus.SENT);
  });

  it("marks whatsappDeliveryStatus Failed and increments retryCount when delivery fails", async () => {
    const { service, prisma } = buildService({ whatsAppOutcome: "FAILED" });

    await service.generateReceipt(generateParams());

    const receipt = [...prisma.__receipts.values()][0];
    expect(receipt.whatsappDeliveryStatus).toBe(WhatsAppDeliveryStatus.FAILED);
    expect(receipt.whatsappRetryCount).toBe(1);
  });

  it("resend-whatsapp is retryable without regenerating the receipt", async () => {
    const { service, prisma } = buildService({ whatsAppOutcome: "FAILED" });
    await service.generateReceipt(generateParams());
    const before = (await prisma.paymentReceipt.findUnique({ where: { paymentId: "payment-1" } }))!;

    prisma.payment.findUnique.mockResolvedValueOnce({ contactSnapshot: "9876543210" });
    await service.resendWhatsapp(ORG_A, before.id);

    expect(prisma.paymentReceipt.create).toHaveBeenCalledTimes(1);
    const after = await prisma.paymentReceipt.findUnique({ where: { id: before.id } });
    expect(after.receiptNumber).toBe(before.receiptNumber);
    expect(after.pdfUrl).toBe(before.pdfUrl);
  });
});

describe("ReceiptsService - immutability and void", () => {
  it("void changes only status/voidReason/voidedByUserId/voidedAt -- amountSnapshot and other core fields are untouched", async () => {
    const { service, prisma } = buildService();
    await service.generateReceipt(generateParams());
    const created = [...prisma.__receipts.values()][0];

    const voided = await service.void(ORG_A, created.id, "senior-1", "Duplicate bank entry");

    expect(voided.status).toBe(PaymentReceiptStatus.VOIDED);
    expect(voided.voidedByUserId).toBe("senior-1");
    expect(voided.voidReason).toBe("Duplicate bank entry");
    expect(voided.voidedAt).toBeInstanceOf(Date);
    expect(voided.amountSnapshot).toBe(created.amountSnapshot);
    expect(voided.donorNameSnapshot).toBe(created.donorNameSnapshot);
    expect(voided.receiptNumber).toBe(created.receiptNumber);
    expect(voided.issuedDate).toEqual(created.issuedDate);
  });

  it("rejects voiding an already-Voided receipt", async () => {
    const { service, prisma } = buildService();
    await service.generateReceipt(generateParams());
    const created = [...prisma.__receipts.values()][0];
    await service.void(ORG_A, created.id, "senior-1", "first reason");

    await expect(service.void(ORG_A, created.id, "senior-1", "second reason")).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it("has no method that edits amountSnapshot -- ReceiptsService exposes only generation, listing, resend, and void", () => {
    const methodNames = Object.getOwnPropertyNames(ReceiptsService.prototype);
    expect(methodNames).not.toContain("update");
    expect(methodNames).not.toContain("updateAmount");
  });

  it("voidReceiptForPayment (the Payment-void propagation hook) voids the matching receipt", async () => {
    const { service, prisma } = buildService();
    await service.generateReceipt(generateParams());
    const created = [...prisma.__receipts.values()][0];

    await service.voidReceiptForPayment({
      organizationId: ORG_A,
      paymentId: "payment-1",
      voidedByUserId: "senior-1",
      reason: "Underlying payment voided",
    });

    const reloaded = await prisma.paymentReceipt.findUnique({ where: { id: created.id } });
    expect(reloaded.status).toBe(PaymentReceiptStatus.VOIDED);
  });

  it("voidReceiptForPayment is a no-op when the payment was never receipted", async () => {
    const { service, prisma } = buildService();

    await service.voidReceiptForPayment({
      organizationId: ORG_A,
      paymentId: "never-receipted-payment",
      voidedByUserId: "senior-1",
      reason: "n/a",
    });

    expect(prisma.paymentReceiptAuditEvent.create).not.toHaveBeenCalled();
  });
});

describe("ReceiptsService - template snapshot", () => {
  it("generating under Template v1 then activating v2 leaves the stored templateVersionId and pdfUrl tied to v1", async () => {
    const templateV1 = { id: "template-v1", sourceFileUrl: "tenants/org/design-v1.png" };
    const { service, prisma, templatesService } = buildService({ activeTemplate: templateV1 });

    await service.generateReceipt(generateParams());
    const receipt = [...prisma.__receipts.values()][0];
    expect(receipt.templateVersionId).toBe("template-v1");
    const pdfUrlAtGeneration = receipt.pdfUrl;

    // Simulate the mandal activating v2 afterward -- resolveActiveTemplate would
    // now return v2 for any *new* generation, but this receipt was already created.
    templatesService.resolveActiveTemplate.mockResolvedValue({
      id: "template-v2",
      sourceFileUrl: "tenants/org/design-v2.png",
    });

    const reloaded = await prisma.paymentReceipt.findUnique({ where: { id: receipt.id } });
    expect(reloaded.templateVersionId).toBe("template-v1");
    expect(reloaded.pdfUrl).toBe(pdfUrlAtGeneration);
  });

  it("falls back to the system default (null templateVersionId) when no template is active", async () => {
    const { service, prisma } = buildService({ activeTemplate: null });

    await service.generateReceipt(generateParams());

    const receipt = [...prisma.__receipts.values()][0];
    expect(receipt.templateVersionId).toBeNull();
  });
});

describe("ReceiptsService - donor history and access", () => {
  const DONOR_USER_ID = "user-donor-1";
  const DONOR_PROFILE_ID = "donor-profile-1";

  function seedDonor(prisma: ReturnType<typeof buildPrismaMock>) {
    prisma.__donorProfiles.set(DONOR_PROFILE_ID, { id: DONOR_PROFILE_ID, userId: DONOR_USER_ID, mobile: "9999999999" });
  }

  it("my-history only ever returns receipts where donorId matches the requesting donor's own account", async () => {
    const prisma = buildPrismaMock();
    seedDonor(prisma);
    const { service } = buildService({ prisma });

    await service.generateReceipt(generateParams({ paymentId: "payment-mine", donorId: DONOR_PROFILE_ID }));
    await service.generateReceipt(generateParams({ paymentId: "payment-not-mine", donorId: "some-other-donor" }));

    const history = await service.myHistory(ORG_A, DONOR_USER_ID);

    expect(history).toHaveLength(1);
    expect(history[0].donorId).toBe(DONOR_PROFILE_ID);
  });

  it("returns an empty history for a user with no DonorProfile at all", async () => {
    const { service } = buildService();

    const history = await service.myHistory(ORG_A, "user-with-no-donor-profile");

    expect(history).toEqual([]);
  });

  it("Org A's list never includes Org B's receipts", async () => {
    const prisma = buildPrismaMock();
    prisma.__organizations.set(ORG_B, { id: ORG_B, name: "Other Mandal" });
    const { service } = buildService({ prisma });

    await service.generateReceipt(generateParams({ organizationId: ORG_A, paymentId: "payment-a" }));
    await service.generateReceipt(generateParams({ organizationId: ORG_B, paymentId: "payment-b" }));

    const results = await service.list(ORG_A, {});

    expect(results).toHaveLength(1);
    expect(results[0].organizationId).toBe(ORG_A);
  });

  it("getById with receipt.viewAll returns any receipt in the org, regardless of donor", async () => {
    const prisma = buildPrismaMock();
    const { service } = buildService({ prisma });
    await service.generateReceipt(generateParams({ donorId: "some-donor" }));
    const created = [...prisma.__receipts.values()][0];

    const result = await service.getById(ORG_A, created.id, "staff-user", true);

    expect(result.id).toBe(created.id);
  });

  it("getById with only receipt.viewOwn 404s on a receipt that isn't the requesting donor's own", async () => {
    const prisma = buildPrismaMock();
    seedDonor(prisma);
    const { service } = buildService({ prisma });
    await service.generateReceipt(generateParams({ donorId: "someone-elses-donor-id" }));
    const created = [...prisma.__receipts.values()][0];

    await expect(service.getById(ORG_A, created.id, DONOR_USER_ID, false)).rejects.toBeInstanceOf(NotFoundException);
  });

  it("getById with only receipt.viewOwn succeeds for the donor's own receipt", async () => {
    const prisma = buildPrismaMock();
    seedDonor(prisma);
    const { service } = buildService({ prisma });
    await service.generateReceipt(generateParams({ donorId: DONOR_PROFILE_ID }));
    const created = [...prisma.__receipts.values()][0];

    const result = await service.getById(ORG_A, created.id, DONOR_USER_ID, false);

    expect(result.id).toBe(created.id);
  });
});
