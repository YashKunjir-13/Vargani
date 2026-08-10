/**
 * ReceiptsService — Unit Tests
 *
 * Structure: GIVEN-WHEN-THEN behavioral contracts.
 * Mock source: @pauti-pustak/backend-testing (no inline mock construction).
 */
import { ConflictException, NotFoundException } from "@nestjs/common";
import { PaymentReceiptStatus, WhatsAppDeliveryStatus } from "@pauti-pustak/backend-database";
import {
  createMockPrisma,
  createMockSequenceCounter,
  TEST_ORG_A,
  TEST_ORG_B,
  TEST_USER_TREASURER,
  TEST_USER_DONOR,
} from "@pauti-pustak/backend-testing";
import { ReceiptsService } from "./receipts.service";

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

function buildWhatsAppDeliveryMock(prisma: ReturnType<typeof createMockPrisma>, outcome: "SENT" | "FAILED" = "SENT") {
  let counter = 0;
  return {
    sendDocument: jest.fn(() => {
      counter += 1;
      const deliveryId = `delivery-${counter}`;
      prisma.whatsAppDeliveryRecord.create({
        data: { id: deliveryId, status: outcome as WhatsAppDeliveryStatus },
      });
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
  prisma?: ReturnType<typeof createMockPrisma>;
  whatsAppOutcome?: "SENT" | "FAILED";
  activeTemplate?: any;
} = {}) {
  const prisma = overrides.prisma ?? createMockPrisma([
    "paymentReceipt",
    "paymentReceiptAuditEvent",
    "organization",
    "documentAsset",
    "donorProfile",
    "payment",
    "whatsAppDeliveryRecord",
  ]);

  // Seed default org
  prisma.organization.create({
    data: { id: TEST_ORG_A, name: "Shree Ganesh Mandal" },
  });

  const sequenceCounter = createMockSequenceCounter();
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
    organizationId: TEST_ORG_A,
    festivalYear: 2026,
    paymentId: "payment-1",
    donorId: null,
    donorNameSnapshot: "Ramesh Kulkarni",
    amount: 501,
    contactSnapshot: "9876543210",
    createdByUserId: TEST_USER_TREASURER,
    ...overrides,
  };
}

describe("ReceiptsService - sequential numbering", () => {
  it("GIVEN 20 concurrent confirmation requests WHEN receipts are generated THEN assigns unique, gapless, sequential numbers", async () => {
    const { service, prisma } = buildService();

    await Promise.all(
      Array.from({ length: 20 }, (_, i) => service.generateReceipt(generateParams({ paymentId: `payment-${i}` }))),
    );

    const receiptNumbers = [...prisma.paymentReceipt.__store.values()].map((r) => r.receiptNumber).sort();
    const expected = Array.from({ length: 20 }, (_, i) => `RCPT-2026-${String(i + 1).padStart(6, "0")}`).sort();

    expect(receiptNumbers).toHaveLength(20);
    expect(new Set(receiptNumbers).size).toBe(20);
    expect(receiptNumbers).toEqual(expected);
  });
});

describe("ReceiptsService - generation idempotency", () => {
  it("GIVEN duplicate generate calls for the same paymentId WHEN called twice THEN creates only one receipt and consumes one sequence", async () => {
    const { service, prisma, sequenceCounter } = buildService();

    await service.generateReceipt(generateParams());
    await service.generateReceipt(generateParams());

    expect(prisma.paymentReceipt.create).toHaveBeenCalledTimes(1);
    expect(sequenceCounter.getNextSequence).toHaveBeenCalledTimes(1);
    expect(prisma.paymentReceipt.__store.size).toBe(1);
  });
});

describe("ReceiptsService - delivery & resend", () => {
  it("GIVEN successful WhatsApp dispatch WHEN receipt is generated THEN tracks status as SENT", async () => {
    const { service, prisma, whatsAppDelivery } = buildService({ whatsAppOutcome: "SENT" });

    await service.generateReceipt(generateParams());

    expect(whatsAppDelivery.sendDocument).toHaveBeenCalledTimes(1);
    const receipt = [...prisma.paymentReceipt.__store.values()][0];
    expect(receipt.whatsappDeliveryStatus).toBe(WhatsAppDeliveryStatus.SENT);
  });

  it("GIVEN failed WhatsApp dispatch WHEN receipt is generated THEN tracks status as FAILED and increments retry count", async () => {
    const { service, prisma } = buildService({ whatsAppOutcome: "FAILED" });

    await service.generateReceipt(generateParams());

    const receipt = [...prisma.paymentReceipt.__store.values()][0];
    expect(receipt.whatsappDeliveryStatus).toBe(WhatsAppDeliveryStatus.FAILED);
    expect(receipt.whatsappRetryCount).toBe(1);
  });

  it("GIVEN a failed WhatsApp delivery WHEN resendWhatsapp is called THEN retries dispatch without creating a new receipt record", async () => {
    const { service, prisma } = buildService({ whatsAppOutcome: "FAILED" });
    await service.generateReceipt(generateParams());
    const before = [...prisma.paymentReceipt.__store.values()][0];

    prisma.payment.findUnique.mockResolvedValueOnce({ contactSnapshot: "9876543210" });
    await service.resendWhatsapp(TEST_ORG_A, before.id);

    expect(prisma.paymentReceipt.create).toHaveBeenCalledTimes(1);
    const after = await prisma.paymentReceipt.findUnique({ where: { id: before.id } });
    expect(after.receiptNumber).toBe(before.receiptNumber);
    expect(after.pdfUrl).toBe(before.pdfUrl);
  });
});

describe("ReceiptsService - immutability and void", () => {
  it("GIVEN an active receipt WHEN voided THEN alters only void tracking fields while preserving core financial amounts", async () => {
    const { service, prisma } = buildService();
    await service.generateReceipt(generateParams());
    const created = [...prisma.paymentReceipt.__store.values()][0];

    const voided = await service.void(TEST_ORG_A, created.id, TEST_USER_TREASURER, "Duplicate bank entry");

    expect(voided.status).toBe(PaymentReceiptStatus.VOIDED);
    expect(voided.voidedByUserId).toBe(TEST_USER_TREASURER);
    expect(voided.voidReason).toBe("Duplicate bank entry");
    expect(voided.voidedAt).toBeInstanceOf(Date);
    expect(voided.amountSnapshot).toBe(created.amountSnapshot);
    expect(voided.donorNameSnapshot).toBe(created.donorNameSnapshot);
    expect(voided.receiptNumber).toBe(created.receiptNumber);
    expect(voided.issuedDate).toEqual(created.issuedDate);
  });

  it("GIVEN an already VOIDED receipt WHEN void is attempted again THEN throws ConflictException (idempotency guard)", async () => {
    const { service, prisma } = buildService();
    await service.generateReceipt(generateParams());
    const created = [...prisma.paymentReceipt.__store.values()][0];
    await service.void(TEST_ORG_A, created.id, TEST_USER_TREASURER, "first reason");

    await expect(service.void(TEST_ORG_A, created.id, TEST_USER_TREASURER, "second reason")).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it("GIVEN the ReceiptsService interface WHEN inspecting methods THEN does not expose any direct amount modification methods", () => {
    const methodNames = Object.getOwnPropertyNames(ReceiptsService.prototype);
    expect(methodNames).not.toContain("update");
    expect(methodNames).not.toContain("updateAmount");
  });

  it("GIVEN an underlying payment void event WHEN voidReceiptForPayment is called THEN voids the matching receipt", async () => {
    const { service, prisma } = buildService();
    await service.generateReceipt(generateParams());
    const created = [...prisma.paymentReceipt.__store.values()][0];

    await service.voidReceiptForPayment({
      organizationId: TEST_ORG_A,
      paymentId: "payment-1",
      voidedByUserId: TEST_USER_TREASURER,
      reason: "Underlying payment voided",
    });

    const reloaded = await prisma.paymentReceipt.findUnique({ where: { id: created.id } });
    expect(reloaded.status).toBe(PaymentReceiptStatus.VOIDED);
  });

  it("GIVEN a non-receipted payment WHEN voidReceiptForPayment is called THEN no-ops safely", async () => {
    const { service, prisma } = buildService();

    await service.voidReceiptForPayment({
      organizationId: TEST_ORG_A,
      paymentId: "never-receipted-payment",
      voidedByUserId: TEST_USER_TREASURER,
      reason: "n/a",
    });

    expect(prisma.paymentReceiptAuditEvent.create).not.toHaveBeenCalled();
  });
});

describe("ReceiptsService - template snapshotting", () => {
  it("GIVEN an active template v1 WHEN receipt is generated THEN locks templateVersionId and remains unaffected by subsequent template updates", async () => {
    const templateV1 = { id: "template-v1", sourceFileUrl: "tenants/org/design-v1.png" };
    const { service, prisma, templatesService } = buildService({ activeTemplate: templateV1 });

    await service.generateReceipt(generateParams());
    const receipt = [...prisma.paymentReceipt.__store.values()][0];
    expect(receipt.templateVersionId).toBe("template-v1");
    const pdfUrlAtGeneration = receipt.pdfUrl;

    templatesService.resolveActiveTemplate.mockResolvedValue({
      id: "template-v2",
      sourceFileUrl: "tenants/org/design-v2.png",
    });

    const reloaded = await prisma.paymentReceipt.findUnique({ where: { id: receipt.id } });
    expect(reloaded.templateVersionId).toBe("template-v1");
    expect(reloaded.pdfUrl).toBe(pdfUrlAtGeneration);
  });

  it("GIVEN no active template WHEN receipt is generated THEN falls back to system default (null templateVersionId)", async () => {
    const { service, prisma } = buildService({ activeTemplate: null });

    await service.generateReceipt(generateParams());

    const receipt = [...prisma.paymentReceipt.__store.values()][0];
    expect(receipt.templateVersionId).toBeNull();
  });
});

describe("ReceiptsService - donor history and tenant isolation", () => {
  const DONOR_PROFILE_ID = "donor-profile-1";

  function seedDonor(prisma: ReturnType<typeof createMockPrisma>) {
    prisma.donorProfile.create({
      data: { id: DONOR_PROFILE_ID, userId: TEST_USER_DONOR, mobile: "9999999999" },
    });
  }

  it("GIVEN requesting donor user WHEN myHistory is called THEN returns only receipts matching donor account", async () => {
    const prisma = createMockPrisma([
      "paymentReceipt",
      "paymentReceiptAuditEvent",
      "organization",
      "documentAsset",
      "donorProfile",
      "payment",
      "whatsAppDeliveryRecord",
    ]);
    prisma.organization.create({ data: { id: TEST_ORG_A, name: "Shree Ganesh Mandal" } });
    seedDonor(prisma);
    const { service } = buildService({ prisma });

    await service.generateReceipt(generateParams({ paymentId: "payment-mine", donorId: DONOR_PROFILE_ID }));
    await service.generateReceipt(generateParams({ paymentId: "payment-not-mine", donorId: "some-other-donor" }));

    const history = await service.myHistory(TEST_ORG_A, TEST_USER_DONOR);

    expect(history).toHaveLength(1);
    expect(history[0].donorId).toBe(DONOR_PROFILE_ID);
  });

  it("GIVEN a user with no DonorProfile WHEN myHistory is called THEN returns empty list", async () => {
    const { service } = buildService();

    const history = await service.myHistory(TEST_ORG_A, "user-with-no-donor-profile");

    expect(history).toEqual([]);
  });

  it("GIVEN receipts in Org A and Org B WHEN Org A lists receipts THEN returns only Org A's receipts", async () => {
    const prisma = createMockPrisma([
      "paymentReceipt",
      "paymentReceiptAuditEvent",
      "organization",
      "documentAsset",
      "donorProfile",
      "payment",
      "whatsAppDeliveryRecord",
    ]);
    prisma.organization.create({ data: { id: TEST_ORG_A, name: "Mandal A" } });
    prisma.organization.create({ data: { id: TEST_ORG_B, name: "Mandal B" } });
    const { service } = buildService({ prisma });

    await service.generateReceipt(generateParams({ organizationId: TEST_ORG_A, paymentId: "payment-a" }));
    await service.generateReceipt(generateParams({ organizationId: TEST_ORG_B, paymentId: "payment-b" }));

    const results = await service.list(TEST_ORG_A, {});

    expect(results).toHaveLength(1);
    expect(results[0].organizationId).toBe(TEST_ORG_A);
  });

  it("GIVEN staff user with receipt.viewAll permission WHEN getById is called THEN returns receipt regardless of donor", async () => {
    const { service, prisma } = buildService();
    await service.generateReceipt(generateParams({ donorId: "some-donor" }));
    const created = [...prisma.paymentReceipt.__store.values()][0];

    const result = await service.getById(TEST_ORG_A, created.id, "staff-user", true);

    expect(result.id).toBe(created.id);
  });

  it("GIVEN donor with receipt.viewOwn permission WHEN requesting another donor's receipt THEN throws NotFoundException", async () => {
    const prisma = createMockPrisma([
      "paymentReceipt",
      "paymentReceiptAuditEvent",
      "organization",
      "documentAsset",
      "donorProfile",
      "payment",
      "whatsAppDeliveryRecord",
    ]);
    prisma.organization.create({ data: { id: TEST_ORG_A, name: "Shree Ganesh Mandal" } });
    seedDonor(prisma);
    const { service } = buildService({ prisma });
    await service.generateReceipt(generateParams({ donorId: "someone-elses-donor-id" }));
    const created = [...prisma.paymentReceipt.__store.values()][0];

    await expect(service.getById(TEST_ORG_A, created.id, TEST_USER_DONOR, false)).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it("GIVEN donor with receipt.viewOwn permission WHEN requesting own receipt THEN successfully returns the receipt", async () => {
    const prisma = createMockPrisma([
      "paymentReceipt",
      "paymentReceiptAuditEvent",
      "organization",
      "documentAsset",
      "donorProfile",
      "payment",
      "whatsAppDeliveryRecord",
    ]);
    prisma.organization.create({ data: { id: TEST_ORG_A, name: "Shree Ganesh Mandal" } });
    seedDonor(prisma);
    const { service } = buildService({ prisma });
    await service.generateReceipt(generateParams({ donorId: DONOR_PROFILE_ID }));
    const created = [...prisma.paymentReceipt.__store.values()][0];

    const result = await service.getById(TEST_ORG_A, created.id, TEST_USER_DONOR, false);

    expect(result.id).toBe(created.id);
  });
});
