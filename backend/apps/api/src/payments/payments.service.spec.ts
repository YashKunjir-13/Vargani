import { ConflictException, ForbiddenException, NotFoundException } from "@nestjs/common";
import { PaymentChannel, PaymentStatus } from "@pauti-pustak/backend-database";
import { PaymentsService } from "./payments.service";

const ORG_A = "org-a";
const ORG_B = "org-b";

function buildPrismaMock() {
  const payments = new Map<string, any>();
  const auditEvents: any[] = [];
  let idCounter = 0;

  const payment = {
    create: jest.fn(({ data }: any) => {
      idCounter += 1;
      const row = {
        id: `payment-${idCounter}`,
        createdAt: new Date(),
        updatedAt: new Date(),
        razorpayPaymentId: null,
        matchedByUserId: null,
        matchedAt: null,
        voidReason: null,
        ...data,
      };
      payments.set(row.id, row);
      return Promise.resolve({ ...row });
    }),
    findUnique: jest.fn(({ where }: any) => {
      if (where.id) return Promise.resolve(payments.get(where.id) ?? null);
      if (where.razorpayOrderId) {
        return Promise.resolve(
          [...payments.values()].find((p) => p.razorpayOrderId === where.razorpayOrderId) ?? null,
        );
      }
      return Promise.resolve(null);
    }),
    findMany: jest.fn(({ where }: any) =>
      Promise.resolve(
        [...payments.values()].filter((p) => {
          if (p.organizationId !== where.organizationId) return false;
          if (where.status && p.status !== where.status) return false;
          if (where.channel && p.channel !== where.channel) return false;
          if (where.donorId && p.donorId !== where.donorId) return false;
          return true;
        }),
      ),
    ),
    update: jest.fn(({ where, data }: any) => {
      const row = { ...payments.get(where.id), ...data };
      payments.set(where.id, row);
      return Promise.resolve({ ...row });
    }),
    delete: jest.fn(({ where }: any) => {
      const row = payments.get(where.id) ?? null;
      payments.delete(where.id);
      return Promise.resolve(row);
    }),
  };

  const paymentAuditEvent = {
    create: jest.fn(({ data }: any) => {
      auditEvents.push(data);
      return Promise.resolve({ id: `audit-${auditEvents.length}`, createdAt: new Date(), ...data });
    }),
  };

  return { payment, paymentAuditEvent, __payments: payments, __auditEvents: auditEvents };
}

function buildFestivalYearMock(festivalYear = 2026) {
  return {
    getActiveFestivalYear: jest.fn(() =>
      Promise.resolve({ eventId: "event-1", organizationId: ORG_A, festivalYear, financialYearLabel: "2025-26" }),
    ),
  };
}

function buildReceiptGenerationMock() {
  return {
    generateReceipt: jest.fn(() => Promise.resolve()),
    voidReceiptForPayment: jest.fn(() => Promise.resolve()),
  };
}

let razorpayOrderCounter = 0;
function buildRazorpayOrdersMock() {
  return {
    createOrder: jest.fn(({ amountRupees }: { amountRupees: number }) => {
      razorpayOrderCounter += 1;
      return Promise.resolve({
        id: `order_mock_${razorpayOrderCounter}`,
        amount: Math.round(amountRupees * 100),
        currency: "INR",
      });
    }),
  };
}

function buildService(
  overrides: {
    receiptGeneration?: ReturnType<typeof buildReceiptGenerationMock>;
    razorpayOrders?: ReturnType<typeof buildRazorpayOrdersMock>;
  } = {},
) {
  const prisma = buildPrismaMock();
  const festivalYear = buildFestivalYearMock();
  const receiptGeneration = overrides.receiptGeneration ?? buildReceiptGenerationMock();
  const razorpayOrders = overrides.razorpayOrders ?? buildRazorpayOrdersMock();
  const service = new PaymentsService(prisma as any, festivalYear as any, receiptGeneration as any, razorpayOrders as any);
  return { service, prisma, festivalYear, receiptGeneration, razorpayOrders };
}

function qrCreateDto(overrides: Partial<Record<string, any>> = {}) {
  return {
    channel: PaymentChannel.QR_CODE,
    donorNameSnapshot: "Ramesh Kulkarni",
    amount: 501,
    ...overrides,
  };
}

describe("PaymentsService - create", () => {
  it("saves fine when address and contact are both omitted", async () => {
    const { service } = buildService();

    const created = await service.createPayment(ORG_A, "user-1", qrCreateDto());

    expect(created.addressSnapshot).toBeNull();
    expect(created.contactSnapshot).toBeNull();
    expect(created.donorNameSnapshot).toBe("Ramesh Kulkarni");
    expect(created.status).toBe(PaymentStatus.PENDING_MATCH);
  });

  it("never accepts a Cash channel -- only InApp/QRCode exist on the DTO/enum", () => {
    expect(Object.values(PaymentChannel)).toEqual([PaymentChannel.IN_APP, PaymentChannel.QR_CODE]);
  });
});

describe("PaymentsService - Razorpay webhook", () => {
  function webhookPayload(orderId: string | null, paymentId = "pay_123") {
    return {
      event: "payment.captured",
      payload: { payment: { entity: { order_id: orderId ?? undefined, id: paymentId } } },
    };
  }

  it("auto-transitions the matching InApp payment to Confirmed with no manual action, then to Receipted", async () => {
    const { service, prisma, receiptGeneration } = buildService();
    const created = await service.createPayment(ORG_A, "user-1", qrCreateDto({ channel: PaymentChannel.IN_APP }));
    expect(created.status).toBe(PaymentStatus.PENDING_MATCH);

    await service.handleRazorpayWebhook(webhookPayload(created.razorpayOrderId, "pay_999"));

    const reloaded = await prisma.payment.findUnique({ where: { id: created.id } });
    expect(reloaded.status).toBe(PaymentStatus.RECEIPTED);
    expect(reloaded.razorpayPaymentId).toBe("pay_999");
    // No human ever matched this payment -- it was confirmed by the webhook alone.
    expect(reloaded.matchedByUserId).toBeNull();
    expect(receiptGeneration.generateReceipt).toHaveBeenCalledWith(
      expect.objectContaining({ paymentId: created.id }),
    );
  });

  it("logs an unmatched webhook for manual investigation instead of dropping it or creating a payment", async () => {
    const { service, prisma } = buildService();

    await service.handleRazorpayWebhook(webhookPayload("order_does_not_exist"));

    expect(prisma.payment.create).not.toHaveBeenCalled();
    expect(prisma.__auditEvents).toHaveLength(1);
    expect(prisma.__auditEvents[0]).toMatchObject({ actionType: "webhook_unmatched" });
  });

  it("logs (not silently drops) a webhook for an order that is already Confirmed", async () => {
    const { service, prisma } = buildService();
    const created = await service.createPayment(ORG_A, "user-1", qrCreateDto({ channel: PaymentChannel.IN_APP }));
    await service.handleRazorpayWebhook(webhookPayload(created.razorpayOrderId));
    prisma.__auditEvents.length = 0;

    await service.handleRazorpayWebhook(webhookPayload(created.razorpayOrderId));

    expect(prisma.__auditEvents).toHaveLength(1);
    expect(prisma.__auditEvents[0]).toMatchObject({ actionType: "webhook_unmatched", paymentId: created.id });
  });

  it("ignores a payment.failed event -- it must never confirm a payment or generate a receipt", async () => {
    const { service, prisma, receiptGeneration } = buildService();
    const created = await service.createPayment(ORG_A, "user-1", qrCreateDto({ channel: PaymentChannel.IN_APP }));

    await service.handleRazorpayWebhook({
      event: "payment.failed",
      payload: { payment: { entity: { order_id: created.razorpayOrderId ?? undefined, id: "pay_failed_1" } } },
    });

    const reloaded = await prisma.payment.findUnique({ where: { id: created.id } });
    expect(reloaded.status).toBe(PaymentStatus.PENDING_MATCH);
    expect(receiptGeneration.generateReceipt).not.toHaveBeenCalled();
    expect(prisma.__auditEvents).toHaveLength(0);
  });
});

describe("PaymentsService - InApp order creation", () => {
  it("creates a Razorpay order server-side for the recorded amount and stores its id", async () => {
    const { service, razorpayOrders } = buildService();

    const created = await service.createPayment(ORG_A, "user-1", qrCreateDto({ channel: PaymentChannel.IN_APP, amount: 750 }));

    expect(razorpayOrders.createOrder).toHaveBeenCalledWith(
      expect.objectContaining({ amountRupees: 750, receipt: created.id }),
    );
    expect(created.razorpayOrderId).toMatch(/^order_mock_/);
  });

  it("never creates a Razorpay order for a QR-code entry", async () => {
    const { service, razorpayOrders } = buildService();

    await service.createPayment(ORG_A, "user-1", qrCreateDto());

    expect(razorpayOrders.createOrder).not.toHaveBeenCalled();
  });

  it("rolls back the payment record if Razorpay order creation fails, and never returns a dangling stub", async () => {
    const razorpayOrders = buildRazorpayOrdersMock();
    razorpayOrders.createOrder.mockRejectedValueOnce(new Error("Razorpay API unreachable"));
    const { service, prisma } = buildService({ razorpayOrders });

    await expect(service.createPayment(ORG_A, "user-1", qrCreateDto({ channel: PaymentChannel.IN_APP }))).rejects.toThrow(
      "Unable to start the Razorpay payment. Please try again.",
    );

    expect(prisma.payment.delete).toHaveBeenCalledTimes(1);
    expect(prisma.__payments.size).toBe(0);
  });
});

describe("PaymentsService - confirmMatch / Receipt Generation", () => {
  it("confirming a QR entry triggers Receipt Generation and lands on Receipted", async () => {
    const { service, receiptGeneration } = buildService();
    const created = await service.createPayment(ORG_A, "user-1", qrCreateDto());

    const result = await service.confirmMatch(ORG_A, created.id, "treasurer-1");

    expect(receiptGeneration.generateReceipt).toHaveBeenCalledTimes(1);
    expect(receiptGeneration.generateReceipt).toHaveBeenCalledWith(
      expect.objectContaining({ organizationId: ORG_A, paymentId: created.id, amount: 501 }),
    );
    expect(result.status).toBe(PaymentStatus.RECEIPTED);
    expect(result.matchedByUserId).toBe("treasurer-1");
  });

  it("an unconfirmed (Pending Match) QR entry never auto-generates a receipt", async () => {
    const { service, receiptGeneration } = buildService();
    await service.createPayment(ORG_A, "user-1", qrCreateDto());

    expect(receiptGeneration.generateReceipt).not.toHaveBeenCalled();
  });

  it("rejects confirming a payment that is already Confirmed/Receipted/Voided", async () => {
    const { service } = buildService();
    const created = await service.createPayment(ORG_A, "user-1", qrCreateDto());
    await service.confirmMatch(ORG_A, created.id, "treasurer-1");

    await expect(service.confirmMatch(ORG_A, created.id, "treasurer-1")).rejects.toBeInstanceOf(ConflictException);
  });
});

describe("PaymentsService - editable fields", () => {
  it("allows editing address/contact while Pending Match", async () => {
    const { service } = buildService();
    const created = await service.createPayment(ORG_A, "user-1", qrCreateDto());

    const updated = await service.update(ORG_A, created.id, { addressSnapshot: "12 MG Road" });

    expect(updated.addressSnapshot).toBe("12 MG Road");
  });

  it("blocks editing address/contact once Confirmed", async () => {
    const { service } = buildService();
    const created = await service.createPayment(ORG_A, "user-1", qrCreateDto());
    await service.confirmMatch(ORG_A, created.id, "treasurer-1");

    await expect(service.update(ORG_A, created.id, { addressSnapshot: "new address" })).rejects.toBeInstanceOf(
      ForbiddenException,
    );
  });

  it("blocks any direct status change on a Receipted payment except through void", async () => {
    const { service } = buildService();
    const created = await service.createPayment(ORG_A, "user-1", qrCreateDto());
    const receipted = await service.confirmMatch(ORG_A, created.id, "treasurer-1");
    expect(receipted.status).toBe(PaymentStatus.RECEIPTED);

    await expect(service.confirmMatch(ORG_A, created.id, "treasurer-1")).rejects.toBeInstanceOf(ConflictException);

    const voided = await service.void(ORG_A, created.id, "senior-1", "Duplicate bank entry, matched twice");
    expect(voided.status).toBe(PaymentStatus.VOIDED);
    expect(voided.voidReason).toBe("Duplicate bank entry, matched twice");
  });
});

describe("PaymentsService - multi-tenant isolation", () => {
  it("Org A cannot retrieve Org B's payment, even by guessing the id", async () => {
    const { service } = buildService();
    const created = await service.createPayment(ORG_B, "user-1", qrCreateDto());

    await expect(service.getById(ORG_A, created.id)).rejects.toBeInstanceOf(NotFoundException);
  });

  it("Org A cannot confirm-match Org B's payment, even by guessing the id", async () => {
    const { service, receiptGeneration } = buildService();
    const created = await service.createPayment(ORG_B, "user-1", qrCreateDto());

    await expect(service.confirmMatch(ORG_A, created.id, "attacker")).rejects.toBeInstanceOf(NotFoundException);
    expect(receiptGeneration.generateReceipt).not.toHaveBeenCalled();
  });

  it("Org A's list never includes Org B's payments", async () => {
    const { service } = buildService();
    await service.createPayment(ORG_A, "user-1", qrCreateDto({ donorNameSnapshot: "A donor" }));
    await service.createPayment(ORG_B, "user-1", qrCreateDto({ donorNameSnapshot: "B donor" }));

    const results = await service.list(ORG_A, {});

    expect(results).toHaveLength(1);
    expect(results[0].donorNameSnapshot).toBe("A donor");
  });
});

describe("PaymentsService - Razorpay Gateway & Reconciliation Engine", () => {
  it("creates Razorpay order and returns checkout parameters", async () => {
    const { service } = buildService();
    const res = await service.createRazorpayOrder(ORG_A, "user-1", { amountPaise: "50000", donorNameSnapshot: "Online Ramesh" });
    expect(res.razorpayOrderId).toBeDefined();
    expect(res.amountPaise).toBe("50000");
  });

  it("verifies payment signature and auto-generates receipt", async () => {
    const { service } = buildService();
    const order = await service.createRazorpayOrder(ORG_A, "user-1", { amountPaise: "50000" });

    const verified = await service.verifyPaymentSignature(ORG_A, {
      razorpayOrderId: order.razorpayOrderId,
      razorpayPaymentId: "pay_123456",
      razorpaySignature: "valid_signature_mock",
    });

    expect(verified.status).toBe(PaymentStatus.RECEIPTED);
    expect(verified.razorpayPaymentId).toBe("pay_123456");
  });

  it("calculates payment statistics and settlement reconciliation metrics", async () => {
    const { service } = buildService();
    await service.createPayment(ORG_A, "user-1", qrCreateDto({ amount: 500 }));

    const stats = await service.getPaymentStats(ORG_A);
    expect(stats.totalPaymentsCount).toBe(1);

    const recon = await service.getSettlementReconciliation(ORG_A);
    expect(recon.reconciliationStatus).toBe("BALANCED");
  });
});
