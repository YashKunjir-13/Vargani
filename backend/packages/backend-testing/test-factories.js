"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TEST_FESTIVAL_YEAR = exports.TEST_EVENT_ID = exports.TEST_USER_ATTACKER = exports.TEST_USER_DONOR = exports.TEST_USER_COLLECTOR = exports.TEST_USER_PRESIDENT = exports.TEST_USER_TREASURER = exports.TEST_USER_OWNER = exports.TEST_ORG_B = exports.TEST_ORG_A = void 0;
exports.createMockOrganization = createMockOrganization;
exports.createMockUser = createMockUser;
exports.createMockAuthContext = createMockAuthContext;
exports.createMockTenantContext = createMockTenantContext;
exports.createMockFestivalYearService = createMockFestivalYearService;
exports.createMockSequenceCounter = createMockSequenceCounter;
exports.createMockBillDto = createMockBillDto;
exports.createMockContributionDto = createMockContributionDto;
exports.createMockPaymentDto = createMockPaymentDto;
exports.createMockReceiptDto = createMockReceiptDto;
exports.createMockReceiptGeneration = createMockReceiptGeneration;
exports.createMockRazorpayOrders = createMockRazorpayOrders;
exports.createMockLedger = createMockLedger;
exports.createMockOcr = createMockOcr;
exports.createMockAssetStorage = createMockAssetStorage;
exports.createMockAuditService = createMockAuditService;
exports.createMockWhatsAppService = createMockWhatsAppService;
exports.createMockOtpChallenge = createMockOtpChallenge;
exports.createMockAuthIdentity = createMockAuthIdentity;
exports.createMockRefreshSession = createMockRefreshSession;
exports.createMockWebhookPayload = createMockWebhookPayload;
exports.TEST_ORG_A = "00000000-0000-4000-a000-000000000001";
exports.TEST_ORG_B = "00000000-0000-4000-a000-000000000002";
exports.TEST_USER_OWNER = "11111111-1111-4111-a111-111111111111";
exports.TEST_USER_TREASURER = "22222222-2222-4222-a222-222222222222";
exports.TEST_USER_PRESIDENT = "33333333-3333-4333-a333-333333333333";
exports.TEST_USER_COLLECTOR = "44444444-4444-4444-a444-444444444444";
exports.TEST_USER_DONOR = "55555555-5555-4555-a555-555555555555";
exports.TEST_USER_ATTACKER = "66666666-6666-4666-a666-666666666666";
exports.TEST_EVENT_ID = "eeeeeeee-eeee-4eee-aeee-eeeeeeeeeeee";
exports.TEST_FESTIVAL_YEAR = 2026;
function createMockOrganization(overrides = {}) {
    return {
        id: exports.TEST_ORG_A,
        name: "Shree Ganesh Utsav Mandal",
        code: "MANDAL01",
        addressLine1: "123 Mandal Path",
        city: "Pune",
        state: "Maharashtra",
        postalCode: "411001",
        ownerUserId: exports.TEST_USER_OWNER,
        status: "ACTIVE",
        createdAt: new Date("2026-01-01T00:00:00Z"),
        updatedAt: new Date("2026-01-01T00:00:00Z"),
        ...overrides,
    };
}
function createMockUser(overrides = {}) {
    return {
        id: exports.TEST_USER_TREASURER,
        displayName: "Ramesh Shinde",
        primaryMobile: "+919876543210",
        platformRole: "USER",
        status: "ACTIVE",
        tokenVersion: 1,
        createdAt: new Date("2026-01-01T00:00:00Z"),
        updatedAt: new Date("2026-01-01T00:00:00Z"),
        ...overrides,
    };
}
function createMockAuthContext(overrides = {}) {
    return {
        userId: exports.TEST_USER_TREASURER,
        organizationId: exports.TEST_ORG_A,
        platformRole: "USER",
        sessionId: "session-test-1",
        permissions: ["bill.create", "bill.view", "payment.create", "payment.view"],
        ...overrides,
    };
}
function createMockTenantContext(overrides = {}) {
    return {
        organizationId: exports.TEST_ORG_A,
        ...overrides,
    };
}
function createMockFestivalYearService(overrides = {}) {
    const festivalYear = overrides.festivalYear ?? exports.TEST_FESTIVAL_YEAR;
    const organizationId = overrides.organizationId ?? exports.TEST_ORG_A;
    return {
        getActiveFestivalYear: jest.fn(() => Promise.resolve({
            eventId: exports.TEST_EVENT_ID,
            organizationId,
            festivalYear,
            financialYearLabel: `${festivalYear - 1}-${String(festivalYear).slice(2)}`,
        })),
    };
}
function createMockSequenceCounter() {
    const counters = new Map();
    return {
        getNextSequence: jest.fn((organizationId, festivalYear, sequenceName) => {
            const key = `${organizationId}:${festivalYear}:${sequenceName}`;
            const next = (counters.get(key) ?? 0) + 1;
            counters.set(key, next);
            return Promise.resolve(BigInt(next));
        }),
    };
}
function createMockBillDto(overrides = {}) {
    return {
        receiverNameSnapshot: "Ganesh Decorators",
        amount: 15000,
        date: "2026-08-01",
        taskOrField: "Mandap Decoration",
        ...overrides,
    };
}
function createMockContributionDto(overrides = {}) {
    return {
        contributorNameSnapshot: "Ramesh Shinde",
        date: "2026-08-01",
        donationType: "Gold",
        itemDescription: "24K Gold Coin with BIS Hallmark",
        weight: 10.5,
        estimatedValue: 75000,
        ...overrides,
    };
}
function createMockPaymentDto(overrides = {}) {
    return {
        channel: "QR_CODE",
        donorNameSnapshot: "Ramesh Kulkarni",
        amount: 501,
        ...overrides,
    };
}
function createMockReceiptDto(overrides = {}) {
    return {
        paymentId: "payment-1",
        organizationId: exports.TEST_ORG_A,
        donorNameSnapshot: "Ramesh Kulkarni",
        amount: 501,
        ...overrides,
    };
}
function createMockReceiptGeneration() {
    return {
        generateReceipt: jest.fn(() => Promise.resolve()),
        voidReceiptForPayment: jest.fn(() => Promise.resolve()),
    };
}
function createMockRazorpayOrders() {
    let orderCounter = 0;
    return {
        createOrder: jest.fn(({ amountRupees }) => {
            orderCounter += 1;
            return Promise.resolve({
                id: `order_mock_${orderCounter}`,
                amount: Math.round(amountRupees * 100),
                currency: "INR",
            });
        }),
    };
}
function createMockLedger() {
    return {
        recordBillPayment: jest.fn(() => Promise.resolve()),
        recordBillCancellation: jest.fn(() => Promise.resolve()),
    };
}
function createMockOcr(proposed = {}) {
    return {
        proposeFields: jest.fn(() => Promise.resolve(proposed)),
    };
}
function createMockAssetStorage() {
    let docCounter = 0;
    return {
        uploadAsset: jest.fn((params) => {
            docCounter += 1;
            const filename = params.filename;
            return Promise.resolve({
                documentId: `doc-${docCounter}`,
                objectKey: `assets/${filename}`,
                url: `https://storage.test/${filename}`,
            });
        }),
        getPresignedUrl: jest.fn((objectKey) => Promise.resolve(`https://storage.test/presigned/${objectKey}`)),
    };
}
function createMockAuditService() {
    return {
        log: jest.fn(() => Promise.resolve({ id: "audit-1", createdAt: new Date() })),
    };
}
function createMockWhatsAppService() {
    return {
        sendTemplateMessage: jest.fn(() => Promise.resolve({ messageId: "wa-1", status: "QUEUED" })),
        getDeliveryStatus: jest.fn(() => Promise.resolve({ status: "DELIVERED" })),
    };
}
function createMockOtpChallenge(overrides = {}) {
    return {
        id: "otp-test-1",
        normalizedMobile: "+919876543210",
        purpose: "LOGIN",
        otpHash: "hashed_otp_placeholder",
        attemptCount: 0,
        maxAttempts: 5,
        expiresAt: new Date(Date.now() + 300_000),
        consumedAt: null,
        ...overrides,
    };
}
function createMockAuthIdentity(overrides = {}) {
    return {
        id: "ident-test-1",
        userId: exports.TEST_USER_TREASURER,
        passwordHash: null,
        mpinHash: null,
        failedLoginCount: 0,
        failedMpinCount: 0,
        lockedUntil: null,
        mpinLockedUntil: null,
        user: createMockUser(),
        ...overrides,
    };
}
function createMockRefreshSession(overrides = {}) {
    return {
        id: "sess-test-1",
        userId: exports.TEST_USER_TREASURER,
        tokenFamilyId: "family-test-1",
        status: "ACTIVE",
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        ...overrides,
    };
}
function createMockWebhookPayload(orderId, paymentId = "pay_test_123", event = "payment.captured") {
    return {
        event,
        payload: {
            payment: {
                entity: {
                    ...(orderId ? { order_id: orderId } : {}),
                    id: paymentId,
                },
            },
        },
    };
}
//# sourceMappingURL=test-factories.js.map