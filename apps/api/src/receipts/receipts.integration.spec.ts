import { PaymentChannel, PaymentStatus, WhatsAppDeliveryStatus } from "@pauti-pustak/backend-database";
import { PaymentsService } from "../payments/payments.service";
import { ReceiptsService } from "./receipts.service";

const ORG_A = "org-a";
const DONOR_USER_ID = "user-donor-1";
const DONOR_PROFILE_ID = "donor-profile-1";

/**
 * A single Prisma mock shared by both PaymentsService and ReceiptsService,
 * standing in for the one real Postgres database both would talk to in
 * production -- this is what lets the end-to-end flow (confirm -> receipt
 * created -> WhatsApp attempted -> donor retrieval) actually exercise real
 * data flowing between the two services, not just each service in
 * isolation.
 */
function buildSharedPrismaMock() {
  const payments = new Map<string, any>();
  const paymentAuditEvents: any[] = [];
  const receipts = new Map<string, any>();
  const paymentReceiptAuditEvents: any[] = [];
  const organizations = new Map<string, any>([[ORG_A, { id: ORG_A, name: "Shree Ganesh Mandal" }]]);
  const donorProfiles = new Map<string, any>([
    [DONOR_PROFILE_ID, { id: DONOR_PROFILE_ID, userId: DONOR_USER_ID, mobile: "9876543210" }],
  ]);
  const deliveries = new Map<string, any>();
  let paymentIdCounter = 0;
  let receiptIdCounter = 0;
  let deliveryIdCounter = 0;

  const payment = {
    create: jest.fn(({ data }: any) => {
      paymentIdCounter += 1;
      const row = { id: `payment-${paymentIdCounter}`, createdAt: new Date(), updatedAt: new Date(), ...data };
      payments.set(row.id, row);
      return Promise.resolve({ ...row });
    }),
    findUnique: jest.fn(({ where }: any) => Promise.resolve(payments.get(where.id) ?? null)),
    update: jest.fn(({ where, data }: any) => {
      const row = { ...payments.get(where.id), ...data };
      payments.set(where.id, row);
      return Promise.resolve({ ...row });
    }),
  };

  const paymentAuditEvent = {
    create: jest.fn(({ data }: any) => {
      paymentAuditEvents.push(data);
      return Promise.resolve({ id: `payment-audit-${paymentAuditEvents.length}`, createdAt: new Date(), ...data });
    }),
  };

  const paymentReceipt = {
    create: jest.fn(({ data }: any) => {
      receiptIdCounter += 1;
      const row = { id: `receipt-${receiptIdCounter}`, createdAt: new Date(), updatedAt: new Date(), ...data };
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
        [...receipts.values()].filter(
          (r) => r.organizationId === where.organizationId && (!where.donorId || r.donorId === where.donorId),
        ),
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
      paymentReceiptAuditEvents.push(data);
      return Promise.resolve({ id: `receipt-audit-${paymentReceiptAuditEvents.length}`, createdAt: new Date(), ...data });
    }),
  };

  const organization = { findUnique: jest.fn(({ where }: any) => Promise.resolve(organizations.get(where.id) ?? null)) };
  const documentAsset = { findFirst: jest.fn(() => Promise.resolve(null)) };
  const donorProfile = {
    findUnique: jest.fn(({ where }: any) => {
      if (where.id) return Promise.resolve(donorProfiles.get(where.id) ?? null);
      if (where.userId) {
        return Promise.resolve([...donorProfiles.values()].find((d) => d.userId === where.userId) ?? null);
      }
      return Promise.resolve(null);
    }),
  };
  const whatsAppDeliveryRecord = {
    findUnique: jest.fn(({ where }: any) => Promise.resolve(deliveries.get(where.id) ?? null)),
  };

  return {
    payment,
    paymentAuditEvent,
    paymentReceipt,
    paymentReceiptAuditEvent,
    organization,
    documentAsset,
    donorProfile,
    whatsAppDeliveryRecord,
    __receipts: receipts,
    __deliveries: deliveries,
    __deliveryIdCounter: () => (deliveryIdCounter += 1),
  };
}

describe("End-to-end: confirm a payment -> receipt created -> WhatsApp attempted -> donor retrieves it", () => {
  it("flows all the way from confirmMatch to GET /receipts/my-history", async () => {
    const prisma = buildSharedPrismaMock();

    const festivalYear = { getActiveFestivalYear: jest.fn(() => Promise.resolve({ festivalYear: 2026 })) };
    const sequenceCounter = { getNextSequence: jest.fn(() => Promise.resolve(BigInt(45))) };
    const assetStorage = {
      uploadAsset: jest.fn(() => Promise.resolve({ documentId: "doc-1", objectKey: "key-1", url: "https://signed.example/rcpt.pdf" })),
      getDownloadUrl: jest.fn(() => Promise.resolve(null)),
    };
    const whatsAppDelivery = {
      sendDocument: jest.fn(() => {
        const id = `delivery-${prisma.__deliveryIdCounter()}`;
        prisma.__deliveries.set(id, { id, status: WhatsAppDeliveryStatus.SENT });
        return Promise.resolve({ deliveryId: id });
      }),
    };
    const templatesService = { resolveActiveTemplate: jest.fn(() => Promise.resolve(null)) };
    const pdfRenderer = { render: jest.fn(() => Promise.resolve(Buffer.from("stub-pdf"))) };

    const receiptsService = new ReceiptsService(
      prisma as any,
      sequenceCounter as any,
      assetStorage as any,
      whatsAppDelivery as any,
      templatesService as any,
      pdfRenderer as any,
    );

    const paymentsService = new PaymentsService(prisma as any, festivalYear as any, receiptsService);

    // 1. A QR-code payment is recorded for a registered donor.
    const created = await paymentsService.createPayment(ORG_A, "volunteer-1", {
      channel: PaymentChannel.QR_CODE,
      donorId: DONOR_PROFILE_ID,
      donorNameSnapshot: "Ramesh Kulkarni",
      amount: 501,
      collectedByUserId: "volunteer-1",
    } as any);
    expect(created.status).toBe(PaymentStatus.PENDING_MATCH);

    // 2. Confirm -> receipt created (single source-of-truth trigger).
    const receipted = await paymentsService.confirmMatch(ORG_A, created.id, "treasurer-1");
    expect(receipted.status).toBe(PaymentStatus.RECEIPTED);

    const receipt = [...prisma.__receipts.values()][0];
    expect(receipt).toBeDefined();
    expect(receipt.paymentId).toBe(created.id);
    expect(receipt.receiptNumber).toBe("RCPT-2026-000045");

    // 3. WhatsApp send was attempted as part of generation.
    expect(whatsAppDelivery.sendDocument).toHaveBeenCalledTimes(1);
    expect(receipt.whatsappDeliveryStatus).toBe(WhatsAppDeliveryStatus.SENT);

    // 4. The donor retrieves it via GET /receipts/my-history.
    const history = await receiptsService.myHistory(ORG_A, DONOR_USER_ID);
    expect(history).toHaveLength(1);
    expect(history[0].id).toBe(receipt.id);
    expect(history[0].receiptNumber).toBe("RCPT-2026-000045");
  });
});
