/**
 * PaymentsService — Unit Tests
 *
 * Structure: GIVEN-WHEN-THEN behavioral contracts.
 * Mock source: @pauti-pustak/backend-testing (no inline mock construction).
 */
import { ConflictException, ForbiddenException, NotFoundException } from "@nestjs/common";
import { PaymentChannel, PaymentStatus } from "@pauti-pustak/backend-database";
import {
  createMockFestivalYearService,
  createMockPaymentDto,
  createMockPrisma,
  createMockRazorpayOrders,
  createMockReceiptGeneration,
  createMockWebhookPayload,
  TEST_ORG_A,
  TEST_ORG_B,
  TEST_USER_TREASURER,
} from "@pauti-pustak/backend-testing";
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

  const paymentReceipt = {
    findUnique: jest.fn(({ where }: any) =>
      Promise.resolve({
        id: `rcpt-1`,
        receiptNumber: "RCPT-2026-000001",
        paymentId: where.paymentId,
        issuedDate: new Date(),
        status: "ACTIVE",
      }),
    ),
  };

  return { payment, paymentAuditEvent, paymentReceipt, __payments: payments, __auditEvents: auditEvents };
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
    receiptGeneration?: ReturnType<typeof createMockReceiptGeneration>;
    razorpayOrders?: ReturnType<typeof createMockRazorpayOrders>;
    gateway?: any;
  } = {},
) {
  const prisma = createMockPrisma(["payment", "paymentAuditEvent", "paymentReceipt"]);
  const festivalYear = createMockFestivalYearService({ organizationId: TEST_ORG_A, festivalYear: 2026 });
  const receiptGeneration = overrides.receiptGeneration ?? createMockReceiptGeneration();
  const razorpayOrders = overrides.razorpayOrders ?? createMockRazorpayOrders();
  const gateway = overrides.gateway;

  const service = new PaymentsService(
    prisma as any,
    festivalYear as any,
    receiptGeneration as any,
    razorpayOrders as any,
    gateway as any,
  );
  return { service, prisma, festivalYear, receiptGeneration, razorpayOrders };
}

describe("PaymentsService - create", () => {
  it("GIVEN payment details without optional address/contact WHEN created THEN saves with defaults and status PENDING_MATCH", async () => {
    const { service } = buildService();

    const created = await service.createPayment(TEST_ORG_A, TEST_USER_TREASURER, createMockPaymentDto());

    expect(created.addressSnapshot).toBeNull();
    expect(created.contactSnapshot).toBeNull();
    expect(created.donorNameSnapshot).toBe("Ramesh Kulkarni");
    expect(created.status).toBe(PaymentStatus.PENDING_MATCH);
  });

  it("GIVEN the domain model WHEN checking PaymentChannel THEN supports only IN_APP and QR_CODE", () => {
    expect(Object.values(PaymentChannel)).toEqual([PaymentChannel.IN_APP, PaymentChannel.QR_CODE]);
  });

  it("collects direct donation, persists payment as RECEIPTED, and generates receipt", async () => {
    const { service, receiptGeneration } = buildService();

    const result = await service.collectDonation(ORG_A, "user-1", {
      donorNameSnapshot: "Sunita Deshmukh",
      contactSnapshot: "9876543210",
      amount: 1008,
      paymentMethod: "Cash",
    });

    expect(result.payment.donorNameSnapshot).toBe("Sunita Deshmukh");
    expect(result.payment.contactSnapshot).toBe("9876543210");
    expect(result.payment.amount).toBe(1008);
    expect(result.payment.status).toBe(PaymentStatus.RECEIPTED);
    expect(receiptGeneration.generateReceipt).toHaveBeenCalledWith({
      organizationId: ORG_A,
      festivalYear: 2026,
      paymentId: result.payment.id,
      donorId: null,
      donorNameSnapshot: "Sunita Deshmukh",
      amount: 1008,
      contactSnapshot: "9876543210",
      createdByUserId: "user-1",
    });
  });
});

describe("PaymentsService - Razorpay webhook", () => {
  it("GIVEN an IN_APP payment WHEN webhook payment.captured arrives THEN auto-transitions to RECEIPTED and generates receipt", async () => {
    const { service, prisma, receiptGeneration } = buildService();
    const created = await service.createPayment(
      TEST_ORG_A,
      TEST_USER_TREASURER,
      createMockPaymentDto({ channel: PaymentChannel.IN_APP }),
    );
    expect(created.status).toBe(PaymentStatus.PENDING_MATCH);

    await service.handleRazorpayWebhook(createMockWebhookPayload(created.razorpayOrderId, "pay_999"));

    const reloaded = await prisma.payment.findUnique({ where: { id: created.id } });
    expect(reloaded.status).toBe(PaymentStatus.RECEIPTED);
    expect(reloaded.razorpayPaymentId).toBe("pay_999");
    expect(reloaded.matchedByUserId).toBeFalsy();
    expect(receiptGeneration.generateReceipt).toHaveBeenCalledWith(
      expect.objectContaining({ paymentId: created.id }),
    );
  });

  it("GIVEN an unmatched order ID in webhook WHEN received THEN logs audit event for investigation without creating payment", async () => {
    const { service, prisma } = buildService();

    await service.handleRazorpayWebhook(createMockWebhookPayload("order_does_not_exist"));

    expect(prisma.payment.create).not.toHaveBeenCalled();
    expect(prisma.paymentAuditEvent.__store.size).toBe(1);
    const auditEvent = [...prisma.paymentAuditEvent.__store.values()][0];
    expect(auditEvent.actionType).toBe("webhook_unmatched");
  });

  it("GIVEN an already confirmed payment WHEN duplicate webhook fires THEN logs audit event rather than duplicating receipt", async () => {
    const { service, prisma, receiptGeneration } = buildService();
    const created = await service.createPayment(
      TEST_ORG_A,
      TEST_USER_TREASURER,
      createMockPaymentDto({ channel: PaymentChannel.IN_APP }),
    );
    await service.handleRazorpayWebhook(createMockWebhookPayload(created.razorpayOrderId));
    expect(receiptGeneration.generateReceipt).toHaveBeenCalledTimes(1);

    prisma.paymentAuditEvent.__store.clear();

    await service.handleRazorpayWebhook(createMockWebhookPayload(created.razorpayOrderId));

    expect(prisma.paymentAuditEvent.__store.size).toBe(1);
    const auditEvent = [...prisma.paymentAuditEvent.__store.values()][0];
    expect(auditEvent.actionType).toBe("webhook_unmatched");
    expect(auditEvent.paymentId).toBe(created.id);
    expect(receiptGeneration.generateReceipt).toHaveBeenCalledTimes(1);
  });

  it("GIVEN a payment.failed webhook event WHEN received THEN ignores it without confirming payment or generating receipt", async () => {
    const { service, prisma, receiptGeneration } = buildService();
    const created = await service.createPayment(
      TEST_ORG_A,
      TEST_USER_TREASURER,
      createMockPaymentDto({ channel: PaymentChannel.IN_APP }),
    );

    await service.handleRazorpayWebhook(
      createMockWebhookPayload(created.razorpayOrderId, "pay_failed_1", "payment.failed"),
    );

    const reloaded = await prisma.payment.findUnique({ where: { id: created.id } });
    expect(reloaded.status).toBe(PaymentStatus.PENDING_MATCH);
    expect(receiptGeneration.generateReceipt).not.toHaveBeenCalled();
    expect(prisma.paymentAuditEvent.__store.size).toBe(0);
  });
});

describe("PaymentsService - InApp order creation", () => {
  it("GIVEN an IN_APP payment creation request WHEN called THEN creates a Razorpay order server-side for the exact amount", async () => {
    const { service, razorpayOrders } = buildService();

    const created = await service.createPayment(
      TEST_ORG_A,
      TEST_USER_TREASURER,
      createMockPaymentDto({ channel: PaymentChannel.IN_APP, amount: 750 }),
    );

    expect(razorpayOrders.createOrder).toHaveBeenCalledWith(
      expect.objectContaining({ amountRupees: 750, receipt: created.id }),
    );
    expect(created.razorpayOrderId).toMatch(/^order_mock_/);
  });

  it("GIVEN a QR_CODE payment creation request WHEN called THEN does not invoke Razorpay orders client", async () => {
    const { service, razorpayOrders } = buildService();

    await service.createPayment(TEST_ORG_A, TEST_USER_TREASURER, createMockPaymentDto());

    expect(razorpayOrders.createOrder).not.toHaveBeenCalled();
  });

  it("GIVEN a failure in Razorpay order creation WHEN creating payment THEN rolls back payment record and throws error", async () => {
    const razorpayOrders = createMockRazorpayOrders();
    razorpayOrders.createOrder.mockRejectedValueOnce(new Error("Razorpay API unreachable"));
    const { service, prisma } = buildService({ razorpayOrders });

    await expect(
      service.createPayment(
        TEST_ORG_A,
        TEST_USER_TREASURER,
        createMockPaymentDto({ channel: PaymentChannel.IN_APP }),
      ),
    ).rejects.toThrow("Unable to start the Razorpay payment. Please try again.");

    expect(prisma.payment.delete).toHaveBeenCalledTimes(1);
    expect(prisma.payment.__store.size).toBe(0);
  });
});

describe("PaymentsService - confirmMatch / Receipt Generation", () => {
  it("GIVEN a PENDING_MATCH QR entry WHEN confirmMatch is called THEN triggers receipt generation and moves to RECEIPTED", async () => {
    const { service, receiptGeneration } = buildService();
    const created = await service.createPayment(TEST_ORG_A, TEST_USER_TREASURER, createMockPaymentDto());

    const result = await service.confirmMatch(TEST_ORG_A, created.id, TEST_USER_TREASURER);

    expect(receiptGeneration.generateReceipt).toHaveBeenCalledTimes(1);
    expect(receiptGeneration.generateReceipt).toHaveBeenCalledWith(
      expect.objectContaining({ organizationId: TEST_ORG_A, paymentId: created.id, amount: 501 }),
    );
    expect(result.status).toBe(PaymentStatus.RECEIPTED);
    expect(result.matchedByUserId).toBe(TEST_USER_TREASURER);
  });

  it("GIVEN an unconfirmed (PENDING_MATCH) QR entry WHEN not yet matched THEN never auto-generates a receipt", async () => {
    const { service, receiptGeneration } = buildService();
    await service.createPayment(TEST_ORG_A, TEST_USER_TREASURER, createMockPaymentDto());

    expect(receiptGeneration.generateReceipt).not.toHaveBeenCalled();
  });

  it("GIVEN an already RECEIPTED payment WHEN confirmMatch is called again THEN throws ConflictException (idempotency guard)", async () => {
    const { service } = buildService();
    const created = await service.createPayment(TEST_ORG_A, TEST_USER_TREASURER, createMockPaymentDto());
    await service.confirmMatch(TEST_ORG_A, created.id, TEST_USER_TREASURER);

    await expect(
      service.confirmMatch(TEST_ORG_A, created.id, TEST_USER_TREASURER),
    ).rejects.toBeInstanceOf(ConflictException);
  });
});

describe("PaymentsService - editable fields & immutability", () => {
  it("GIVEN a PENDING_MATCH payment WHEN update is called on mutable fields THEN allows modification", async () => {
    const { service } = buildService();
    const created = await service.createPayment(TEST_ORG_A, TEST_USER_TREASURER, createMockPaymentDto());

    const updated = await service.update(TEST_ORG_A, created.id, { addressSnapshot: "12 MG Road" });

    expect(updated.addressSnapshot).toBe("12 MG Road");
  });

  it("GIVEN a confirmed/RECEIPTED payment WHEN update is attempted THEN throws ForbiddenException", async () => {
    const { service } = buildService();
    const created = await service.createPayment(TEST_ORG_A, TEST_USER_TREASURER, createMockPaymentDto());
    await service.confirmMatch(TEST_ORG_A, created.id, TEST_USER_TREASURER);

    await expect(
      service.update(TEST_ORG_A, created.id, { addressSnapshot: "new address" }),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });

  it("GIVEN a RECEIPTED payment WHEN void is called THEN transitions to VOIDED with mandatory reason", async () => {
    const { service } = buildService();
    const created = await service.createPayment(TEST_ORG_A, TEST_USER_TREASURER, createMockPaymentDto());
    await service.confirmMatch(TEST_ORG_A, created.id, TEST_USER_TREASURER);

    const voided = await service.void(TEST_ORG_A, created.id, TEST_USER_TREASURER, "Duplicate bank entry, matched twice");
    expect(voided.status).toBe(PaymentStatus.VOIDED);
    expect(voided.voidReason).toBe("Duplicate bank entry, matched twice");
  });

  it("GIVEN a VOIDED payment WHEN void is called again THEN throws ConflictException (idempotency guard)", async () => {
    const { service } = buildService();
    const created = await service.createPayment(TEST_ORG_A, TEST_USER_TREASURER, createMockPaymentDto());
    await service.confirmMatch(TEST_ORG_A, created.id, TEST_USER_TREASURER);
    await service.void(TEST_ORG_A, created.id, TEST_USER_TREASURER, "First void");

    await expect(
      service.void(TEST_ORG_A, created.id, TEST_USER_TREASURER, "Second void"),
    ).rejects.toBeInstanceOf(ConflictException);
  });
});

describe("PaymentsService - multi-tenant isolation", () => {
  it("GIVEN Org B's payment WHEN Org A attempts to getById THEN throws NotFoundException", async () => {
    const { service } = buildService();
    const created = await service.createPayment(TEST_ORG_B, TEST_USER_TREASURER, createMockPaymentDto());

    await expect(service.getById(TEST_ORG_A, created.id)).rejects.toBeInstanceOf(NotFoundException);
  });

  it("GIVEN Org B's payment WHEN Org A attempts to confirmMatch THEN throws NotFoundException and generates no receipt", async () => {
    const { service, receiptGeneration } = buildService();
    const created = await service.createPayment(TEST_ORG_B, TEST_USER_TREASURER, createMockPaymentDto());

    await expect(
      service.confirmMatch(TEST_ORG_A, created.id, TEST_USER_TREASURER),
    ).rejects.toBeInstanceOf(NotFoundException);
    expect(receiptGeneration.generateReceipt).not.toHaveBeenCalled();
  });

  it("GIVEN payments across Org A and Org B WHEN Org A lists payments THEN returns only Org A's records", async () => {
    const { service } = buildService();
    await service.createPayment(TEST_ORG_A, TEST_USER_TREASURER, createMockPaymentDto({ donorNameSnapshot: "A donor" }));
    await service.createPayment(TEST_ORG_B, TEST_USER_TREASURER, createMockPaymentDto({ donorNameSnapshot: "B donor" }));

    const results = await service.list(TEST_ORG_A, {});

    expect(results).toHaveLength(1);
    expect(results[0].donorNameSnapshot).toBe("A donor");
  });
});

describe("PaymentsService - Razorpay Gateway & Reconciliation Engine", () => {
  it("GIVEN valid amountPaise WHEN createRazorpayOrder is called THEN creates order and returns checkout params", async () => {
    const { service } = buildService();
    const res = await service.createRazorpayOrder(TEST_ORG_A, TEST_USER_TREASURER, {
      amountPaise: "50000",
      donorNameSnapshot: "Online Ramesh",
    });
    expect(res.razorpayOrderId).toBeDefined();
    expect(res.amountPaise).toBe("50000");
  });

  it("GIVEN valid signature WHEN verifyPaymentSignature is called THEN transitions payment to RECEIPTED", async () => {
    const { service } = buildService();
    const order = await service.createRazorpayOrder(TEST_ORG_A, TEST_USER_TREASURER, { amountPaise: "50000" });

    const verified = await service.verifyPaymentSignature(TEST_ORG_A, {
      razorpayOrderId: order.razorpayOrderId,
      razorpayPaymentId: "pay_123456",
      razorpaySignature: "valid_signature_mock",
    });

    expect(verified.status).toBe(PaymentStatus.RECEIPTED);
    expect(verified.razorpayPaymentId).toBe("pay_123456");
  });

  it("GIVEN recorded payments WHEN getPaymentStats and getSettlementReconciliation are called THEN returns aggregate metrics", async () => {
    const { service } = buildService();
    await service.createPayment(TEST_ORG_A, TEST_USER_TREASURER, createMockPaymentDto({ amount: 500 }));

    const stats = await service.getPaymentStats(TEST_ORG_A);
    expect(stats.totalPaymentsCount).toBe(1);

    const recon = await service.getSettlementReconciliation(TEST_ORG_A);
    expect(recon.reconciliationStatus).toBe("BALANCED");
  });
});
