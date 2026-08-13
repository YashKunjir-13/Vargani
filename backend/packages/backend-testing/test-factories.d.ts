export declare const TEST_ORG_A = "00000000-0000-4000-a000-000000000001";
export declare const TEST_ORG_B = "00000000-0000-4000-a000-000000000002";
export declare const TEST_USER_OWNER = "11111111-1111-4111-a111-111111111111";
export declare const TEST_USER_TREASURER = "22222222-2222-4222-a222-222222222222";
export declare const TEST_USER_PRESIDENT = "33333333-3333-4333-a333-333333333333";
export declare const TEST_USER_COLLECTOR = "44444444-4444-4444-a444-444444444444";
export declare const TEST_USER_DONOR = "55555555-5555-4555-a555-555555555555";
export declare const TEST_USER_ATTACKER = "66666666-6666-4666-a666-666666666666";
export declare const TEST_EVENT_ID = "eeeeeeee-eeee-4eee-aeee-eeeeeeeeeeee";
export declare const TEST_FESTIVAL_YEAR = 2026;
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
export declare function createMockOrganization(overrides?: Partial<MockOrganization>): MockOrganization;
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
export declare function createMockUser(overrides?: Partial<MockUser>): MockUser;
export interface MockAuthContext {
    userId: string;
    organizationId: string;
    platformRole: string;
    sessionId: string;
    permissions: string[];
}
export declare function createMockAuthContext(overrides?: Partial<MockAuthContext>): MockAuthContext;
export interface MockTenantContext {
    organizationId: string;
}
export declare function createMockTenantContext(overrides?: Partial<MockTenantContext>): MockTenantContext;
export declare function createMockFestivalYearService(overrides?: {
    festivalYear?: number;
    organizationId?: string;
}): {
    getActiveFestivalYear: jest.Mock<Promise<{
        eventId: string;
        organizationId: string;
        festivalYear: number;
        financialYearLabel: string;
    }>, [], any>;
};
export declare function createMockSequenceCounter(): {
    getNextSequence: jest.Mock<Promise<bigint>, [organizationId: string, festivalYear: number, sequenceName: string], any>;
};
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
export declare function createMockBillDto(overrides?: Partial<MockCreateBillDto>): MockCreateBillDto;
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
export declare function createMockContributionDto(overrides?: Partial<MockCreateContributionDto>): MockCreateContributionDto;
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
export declare function createMockPaymentDto(overrides?: Partial<MockCreatePaymentDto>): MockCreatePaymentDto;
export interface MockCreateReceiptDto {
    paymentId: string;
    organizationId: string;
    donorNameSnapshot: string;
    amount: number;
    addressSnapshot?: string;
}
export declare function createMockReceiptDto(overrides?: Partial<MockCreateReceiptDto>): MockCreateReceiptDto;
export declare function createMockReceiptGeneration(): {
    generateReceipt: jest.Mock<Promise<void>, [], any>;
    voidReceiptForPayment: jest.Mock<Promise<void>, [], any>;
};
export declare function createMockRazorpayOrders(): {
    createOrder: jest.Mock<Promise<{
        id: string;
        amount: number;
        currency: string;
    }>, [{
        amountRupees: number;
    }], any>;
};
export declare function createMockLedger(): {
    recordBillPayment: jest.Mock<Promise<void>, [], any>;
    recordBillCancellation: jest.Mock<Promise<void>, [], any>;
};
export declare function createMockOcr(proposed?: Record<string, any>): {
    proposeFields: jest.Mock<Promise<Record<string, any>>, [], any>;
};
export declare function createMockAssetStorage(): {
    uploadAsset: jest.Mock<Promise<{
        documentId: string;
        objectKey: string;
        url: string;
    }>, [params: {
        filename: string;
        organizationId?: string;
        ownerUserId?: string;
        purpose?: any;
        body?: any;
        contentType?: string;
    }], any>;
    getPresignedUrl: jest.Mock<Promise<string>, [objectKey: string], any>;
};
export declare function createMockAuditService(): {
    log: jest.Mock<Promise<{
        id: string;
        createdAt: Date;
    }>, [], any>;
};
export declare function createMockWhatsAppService(): {
    sendTemplateMessage: jest.Mock<Promise<{
        messageId: string;
        status: string;
    }>, [], any>;
    getDeliveryStatus: jest.Mock<Promise<{
        status: string;
    }>, [], any>;
};
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
export declare function createMockOtpChallenge(overrides?: Partial<MockOtpChallenge>): MockOtpChallenge;
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
export declare function createMockAuthIdentity(overrides?: Partial<MockAuthIdentity>): MockAuthIdentity;
export interface MockRefreshSession {
    id: string;
    userId: string;
    tokenFamilyId: string;
    status: string;
    expiresAt: Date;
    revocationReason?: string | null;
}
export declare function createMockRefreshSession(overrides?: Partial<MockRefreshSession>): MockRefreshSession;
export declare function createMockWebhookPayload(orderId: string | null, paymentId?: string, event?: string): {
    event: string;
    payload: {
        payment: {
            entity: {
                id: string;
                order_id?: string | undefined;
            };
        };
    };
};
