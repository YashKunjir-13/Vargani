/**
 * @module test-factories
 * @description Centralized factory utilities for creating type-safe mock objects
 * with sensible defaults and override support.
 *
 * Replaces the pattern of each spec file building its own inline mocks.
 * Every factory returns a valid domain object with all required fields populated;
 * callers override only the fields relevant to their test scenario.
 *
 * Naming follows GIVEN-style readability:
 *   const dto = createMockBillDto({ amount: 5000 });
 *   // → "GIVEN a bill with amount 5000"
 *
 * All ID fields use deterministic UUIDs so tests are reproducible.
 */

// ─── Deterministic IDs ───────────────────────────────────────────────────────

/** Well-known test Organization IDs. */
export const TEST_ORG_A = "00000000-0000-4000-a000-000000000001";
export const TEST_ORG_B = "00000000-0000-4000-a000-000000000002";

/** Well-known test User IDs (role-suggestive names for readability). */
export const TEST_USER_OWNER     = "11111111-1111-4111-a111-111111111111";
export const TEST_USER_TREASURER = "22222222-2222-4222-a222-222222222222";
export const TEST_USER_PRESIDENT = "33333333-3333-4333-a333-333333333333";
export const TEST_USER_COLLECTOR = "44444444-4444-4444-a444-444444444444";
export const TEST_USER_DONOR     = "55555555-5555-4555-a555-555555555555";
export const TEST_USER_ATTACKER  = "66666666-6666-4666-a666-666666666666";

/** Well-known test Event/Festival ID. */
export const TEST_EVENT_ID = "eeeeeeee-eeee-4eee-aeee-eeeeeeeeeeee";
export const TEST_FESTIVAL_YEAR = 2026;

// ─── Organization ────────────────────────────────────────────────────────────

export interface MockOrganization {
  id: string;
  name: string;
  code: string;
  addressLine1: string;
  city: string;
  state: string;
  postalCode: string;
  ownerUserId: string;
  status: string;
  createdAt: Date;
  updatedAt: Date;
}

export function createMockOrganization(overrides: Partial<MockOrganization> = {}): MockOrganization {
  return {
    id: TEST_ORG_A,
    name: "Shree Ganesh Utsav Mandal",
    code: "MANDAL01",
    addressLine1: "123 Mandal Path",
    city: "Pune",
    state: "Maharashtra",
    postalCode: "411001",
    ownerUserId: TEST_USER_OWNER,
    status: "ACTIVE",
    createdAt: new Date("2026-01-01T00:00:00Z"),
    updatedAt: new Date("2026-01-01T00:00:00Z"),
    ...overrides,
  };
}

// ─── User ────────────────────────────────────────────────────────────────────

export interface MockUser {
  id: string;
  displayName: string;
  primaryMobile: string;
  platformRole: string;
  status: string;
  tokenVersion: number;
  createdAt: Date;
  updatedAt: Date;
}

export function createMockUser(overrides: Partial<MockUser> = {}): MockUser {
  return {
    id: TEST_USER_TREASURER,
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

// ─── Auth Context ────────────────────────────────────────────────────────────

export interface MockAuthContext {
  userId: string;
  organizationId: string;
  platformRole: string;
  sessionId: string;
  permissions: string[];
}

export function createMockAuthContext(overrides: Partial<MockAuthContext> = {}): MockAuthContext {
  return {
    userId: TEST_USER_TREASURER,
    organizationId: TEST_ORG_A,
    platformRole: "USER",
    sessionId: "session-test-1",
    permissions: ["bill.create", "bill.view", "payment.create", "payment.view"],
    ...overrides,
  };
}

// ─── Tenant Context ──────────────────────────────────────────────────────────

export interface MockTenantContext {
  organizationId: string;
}

export function createMockTenantContext(overrides: Partial<MockTenantContext> = {}): MockTenantContext {
  return {
    organizationId: TEST_ORG_A,
    ...overrides,
  };
}

// ─── Festival Year Service Mock ──────────────────────────────────────────────

export function createMockFestivalYearService(overrides: { festivalYear?: number; organizationId?: string } = {}) {
  const festivalYear = overrides.festivalYear ?? TEST_FESTIVAL_YEAR;
  const organizationId = overrides.organizationId ?? TEST_ORG_A;
  return {
    getActiveFestivalYear: jest.fn(() =>
      Promise.resolve({
        eventId: TEST_EVENT_ID,
        organizationId,
        festivalYear,
        financialYearLabel: `${festivalYear - 1}-${String(festivalYear).slice(2)}`,
      }),
    ),
  };
}

// ─── Sequence Counter Mock ───────────────────────────────────────────────────

export function createMockSequenceCounter() {
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

// ─── Bill DTOs ───────────────────────────────────────────────────────────────

export interface MockCreateBillDto {
  receiverNameSnapshot: string;
  amount: number;
  date: string;
  taskOrField: string;
  vendorId?: string;
  contactSnapshot?: string;
  milestoneId?: string;
  billPhotoUrl?: string;
}

export function createMockBillDto(overrides: Partial<MockCreateBillDto> = {}): MockCreateBillDto {
  return {
    receiverNameSnapshot: "Ganesh Decorators",
    amount: 15000,
    date: "2026-08-01",
    taskOrField: "Mandap Decoration",
    ...overrides,
  };
}

// ─── Contribution DTOs ───────────────────────────────────────────────────────

export interface MockCreateContributionDto {
  contributorNameSnapshot: string;
  contactSnapshot?: string;
  date: string;
  donationType: string;
  itemDescription?: string;
  weight?: number;
  estimatedValue?: number;
  certificatePhotoUrl?: string;
  contributorId?: string;
}

export function createMockContributionDto(
  overrides: Partial<MockCreateContributionDto> = {},
): MockCreateContributionDto {
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

// ─── Payment DTOs ────────────────────────────────────────────────────────────

export interface MockCreatePaymentDto {
  channel: any;
  donorNameSnapshot: string;
  amount: number;
  donorId?: string;
  addressSnapshot?: string;
  contactSnapshot?: string;
  paymentDateTime?: string;
  collectedByUserId?: string;
}

export function createMockPaymentDto(overrides: Partial<MockCreatePaymentDto> = {}): MockCreatePaymentDto {
  return {
    channel: "QR_CODE",
    donorNameSnapshot: "Ramesh Kulkarni",
    amount: 501,
    ...overrides,
  };
}

// ─── Receipt DTOs ────────────────────────────────────────────────────────────

export interface MockCreateReceiptDto {
  paymentId: string;
  organizationId: string;
  donorNameSnapshot: string;
  amount: number;
  addressSnapshot?: string;
}

export function createMockReceiptDto(overrides: Partial<MockCreateReceiptDto> = {}): MockCreateReceiptDto {
  return {
    paymentId: "payment-1",
    organizationId: TEST_ORG_A,
    donorNameSnapshot: "Ramesh Kulkarni",
    amount: 501,
    ...overrides,
  };
}

// ─── Service-Level Mock Builders ─────────────────────────────────────────────

/** Receipt Generation mock (used by PaymentsService). */
export function createMockReceiptGeneration() {
  return {
    generateReceipt: jest.fn(() => Promise.resolve()),
    voidReceiptForPayment: jest.fn(() => Promise.resolve()),
  };
}

/** Razorpay Orders mock (used by PaymentsService). */
export function createMockRazorpayOrders() {
  let orderCounter = 0;
  return {
    createOrder: jest.fn(({ amountRupees }: { amountRupees: number }) => {
      orderCounter += 1;
      return Promise.resolve({
        id: `order_mock_${orderCounter}`,
        amount: Math.round(amountRupees * 100),
        currency: "INR",
      });
    }),
  };
}

/** Ledger Port mock (used by BillsService). */
export function createMockLedger() {
  return {
    recordBillPayment: jest.fn(() => Promise.resolve()),
    recordBillCancellation: jest.fn(() => Promise.resolve()),
  };
}

/** OCR Port mock (used by BillsService). */
export function createMockOcr(proposed: Record<string, any> = {}) {
  return {
    proposeFields: jest.fn(() => Promise.resolve(proposed)),
  };
}

/** Asset Storage mock (used by ContributionsService). */
export function createMockAssetStorage() {
  let docCounter = 0;
  return {
    uploadAsset: jest.fn(
      (params: {
        filename: string;
        organizationId?: string;
        ownerUserId?: string;
        purpose?: any;
        body?: any;
        contentType?: string;
      }) => {
        docCounter += 1;
        const filename = params.filename;
        return Promise.resolve({
          documentId: `doc-${docCounter}`,
          objectKey: `assets/${filename}`,
          url: `https://storage.test/${filename}`,
        });
      },
    ),
    getPresignedUrl: jest.fn((objectKey: string) =>
      Promise.resolve(`https://storage.test/presigned/${objectKey}`),
    ),
  };
}

/** Audit Service mock. */
export function createMockAuditService() {
  return {
    log: jest.fn(() => Promise.resolve({ id: "audit-1", createdAt: new Date() })),
  };
}

/** WhatsApp Delivery Service mock. */
export function createMockWhatsAppService() {
  return {
    sendTemplateMessage: jest.fn(() => Promise.resolve({ messageId: "wa-1", status: "QUEUED" })),
    getDeliveryStatus: jest.fn(() => Promise.resolve({ status: "DELIVERED" })),
  };
}

// ─── OTP / Auth Mocks ────────────────────────────────────────────────────────

export interface MockOtpChallenge {
  id: string;
  normalizedMobile: string;
  purpose: string;
  otpHash: string;
  attemptCount: number;
  maxAttempts: number;
  expiresAt: Date;
  consumedAt: Date | null;
}

export function createMockOtpChallenge(overrides: Partial<MockOtpChallenge> = {}): MockOtpChallenge {
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

export interface MockAuthIdentity {
  id: string;
  userId: string;
  passwordHash: string | null;
  mpinHash: string | null;
  failedLoginCount: number;
  failedMpinCount: number;
  lockedUntil: Date | null;
  mpinLockedUntil: Date | null;
  user: MockUser;
}

export function createMockAuthIdentity(overrides: Partial<MockAuthIdentity> = {}): MockAuthIdentity {
  return {
    id: "ident-test-1",
    userId: TEST_USER_TREASURER,
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

export interface MockRefreshSession {
  id: string;
  userId: string;
  tokenFamilyId: string;
  status: string;
  expiresAt: Date;
  revocationReason?: string | null;
}

export function createMockRefreshSession(overrides: Partial<MockRefreshSession> = {}): MockRefreshSession {
  return {
    id: "sess-test-1",
    userId: TEST_USER_TREASURER,
    tokenFamilyId: "family-test-1",
    status: "ACTIVE",
    expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    ...overrides,
  };
}

// ─── Razorpay Webhook Payload ────────────────────────────────────────────────

export function createMockWebhookPayload(
  orderId: string | null,
  paymentId = "pay_test_123",
  event = "payment.captured",
) {
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
