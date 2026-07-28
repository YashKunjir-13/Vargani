-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'DEACTIVATED', 'LOCKED', 'MERGED');

-- CreateEnum
CREATE TYPE "PreferredLanguage" AS ENUM ('EN', 'MR', 'HI');

-- CreateEnum
CREATE TYPE "PlatformRole" AS ENUM ('USER', 'SUPER_ADMIN');

-- CreateEnum
CREATE TYPE "AuthProvider" AS ENUM ('MOBILE_OTP', 'MOBILE_PASSWORD', 'EMAIL_PASSWORD');

-- CreateEnum
CREATE TYPE "AuthSessionStatus" AS ENUM ('ACTIVE', 'REVOKED', 'EXPIRED', 'COMPROMISED');

-- CreateEnum
CREATE TYPE "OtpPurpose" AS ENUM ('LOGIN', 'VERIFY_MOBILE', 'PASSWORD_RESET', 'INVITATION_ACCEPTANCE');

-- CreateEnum
CREATE TYPE "DonorProfileStatus" AS ENUM ('UNCLAIMED', 'ACTIVE', 'DEACTIVATED', 'MERGED');

-- CreateEnum
CREATE TYPE "OrganizationStatus" AS ENUM ('ACTIVE', 'CORRECTION_REQUIRED', 'SUSPENDED', 'REJECTED', 'CLOSED');

-- CreateEnum
CREATE TYPE "MembershipStatus" AS ENUM ('INVITED', 'ACTIVE', 'INACTIVE', 'REMOVED', 'EXPIRED', 'REVOKED');

-- CreateEnum
CREATE TYPE "InvitationDeliveryMethod" AS ENUM ('MOBILE', 'EMAIL', 'DIRECT_CREATE');

-- CreateEnum
CREATE TYPE "EventStatus" AS ENUM ('DRAFT', 'ACTIVE', 'COMPLETED', 'FINANCIALLY_CLOSED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "VolunteerStatus" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'INACTIVE');

-- CreateEnum
CREATE TYPE "VolunteerType" AS ENUM ('GENERAL', 'DONATION_COLLECTOR', 'EVENT_COORDINATOR', 'FINANCE_VOLUNTEER', 'DECORATION', 'FOOD_DISTRIBUTION', 'CROWD_MANAGEMENT', 'CUSTOM');

-- CreateEnum
CREATE TYPE "VolunteerAssignmentStatus" AS ENUM ('PLANNED', 'ACTIVE', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "AssignmentScopeType" AS ENUM ('EVENT', 'AREA', 'ROUTE', 'SOCIETY', 'VILLAGE', 'WARD', 'CONTRIBUTOR_PORTFOLIO', 'RECEIPT_BOOK', 'CAMPAIGN');

-- CreateEnum
CREATE TYPE "ContributorAccountType" AS ENUM ('INDIVIDUAL', 'FAMILY_HOUSEHOLD', 'SHOP_BUSINESS', 'HOUSING_SOCIETY', 'INSTITUTION', 'SPONSOR', 'GOVERNMENT_BODY', 'OTHER');

-- CreateEnum
CREATE TYPE "BillingMode" AS ENUM ('FIXED', 'SUGGESTED', 'OPEN_AMOUNT', 'NO_BILL');

-- CreateEnum
CREATE TYPE "ContributorAccountStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'MERGED');

-- CreateEnum
CREATE TYPE "PublicVisibility" AS ENUM ('NAME_AND_AMOUNT', 'PRIVATE');

-- CreateEnum
CREATE TYPE "ReceiptBookStatus" AS ENUM ('OPEN', 'CLOSED');

-- CreateEnum
CREATE TYPE "ContributionBillStatus" AS ENUM ('DRAFT', 'GENERATED', 'ISSUED', 'PARTIALLY_PAID', 'PAID', 'OVERDUE', 'WAIVED', 'CANCELLED', 'RENDER_FAILED', 'REPLACED');

-- CreateEnum
CREATE TYPE "BillAmountMode" AS ENUM ('FIXED', 'OPEN_AMOUNT');

-- CreateEnum
CREATE TYPE "ContributionType" AS ENUM ('CONTRIBUTION', 'SPONSORSHIP', 'ADVERTISEMENT', 'MEMBERSHIP', 'GRANT', 'OTHER');

-- CreateEnum
CREATE TYPE "JobStatus" AS ENUM ('QUEUED', 'RUNNING', 'COMPLETED', 'FAILED');

-- CreateEnum
CREATE TYPE "CollectionStatus" AS ENUM ('RECORDED', 'PENDING_VERIFICATION', 'PENDING_CHEQUE_CLEARANCE', 'CONFIRMED', 'REJECTED', 'CANCELLED', 'CHEQUE_BOUNCED', 'PARTIALLY_REFUNDED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "CollectionMode" AS ENUM ('CASH', 'UPI', 'BANK_TRANSFER', 'CHEQUE', 'RAZORPAY', 'CARD', 'OTHER');

-- CreateEnum
CREATE TYPE "CollectionSource" AS ENUM ('ADMIN_WEB', 'COLLECTOR_WEB', 'COLLECTOR_MOBILE', 'PUBLIC_PAYMENT', 'IMPORT', 'API');

-- CreateEnum
CREATE TYPE "SettlementStatus" AS ENUM ('SUBMITTED', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "ContributionSourceType" AS ENUM ('BILL_COLLECTION', 'DIRECT', 'SPONSORSHIP', 'ADVERTISEMENT', 'MEMBERSHIP', 'GOVERNMENT_GRANT', 'INSTITUTIONAL_GRANT', 'IMPORTED_LEGACY');

-- CreateEnum
CREATE TYPE "ContributionStatus" AS ENUM ('DRAFT', 'PENDING', 'PARTIALLY_RECEIVED', 'CONFIRMED', 'RECEIPT_ISSUED', 'CANCELLED', 'PARTIALLY_REFUNDED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "ReceiptSourceType" AS ENUM ('CONTRIBUTION_COLLECTION', 'IN_KIND_CONTRIBUTION', 'LEGACY_DONATION_INSTALLMENT');

-- CreateEnum
CREATE TYPE "ReceiptStatus" AS ENUM ('GENERATING', 'ISSUED', 'CANCELLED', 'PARTIALLY_REFUNDED', 'REFUNDED', 'RENDER_FAILED', 'REPLACED');

-- CreateEnum
CREATE TYPE "VendorStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- CreateEnum
CREATE TYPE "ExpenseStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'UNDER_APPROVAL', 'APPROVED', 'PARTIALLY_PAID', 'PAID', 'REJECTED', 'CANCELLATION_PENDING', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ApprovalDecision" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "ExpensePaymentStatus" AS ENUM ('PENDING', 'CONFIRMED', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "PaymentMode" AS ENUM ('CASH', 'BANK_TRANSFER', 'UPI', 'CHEQUE', 'CARD', 'OTHER');

-- CreateEnum
CREATE TYPE "FinancialAccountType" AS ENUM ('CASH', 'BANK', 'UPI', 'CHEQUE_CLEARING', 'RAZORPAY_SETTLEMENT', 'CARD_SETTLEMENT');

-- CreateEnum
CREATE TYPE "FinancialAccountStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- CreateEnum
CREATE TYPE "TransferStatus" AS ENUM ('PENDING', 'POSTED', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "LedgerTransactionType" AS ENUM ('OPENING_BALANCE', 'DONATION_RECEIPT', 'EXPENSE_PAYMENT', 'GATEWAY_FEE', 'REFUND', 'INTERNAL_TRANSFER', 'COMPENSATING_ADJUSTMENT');

-- CreateEnum
CREATE TYPE "LedgerTransactionStatus" AS ENUM ('PENDING', 'POSTED', 'FAILED');

-- CreateEnum
CREATE TYPE "LedgerEntrySide" AS ENUM ('DEBIT', 'CREDIT');

-- CreateEnum
CREATE TYPE "LedgerAccountClass" AS ENUM ('ASSET', 'INCOME', 'EXPENSE', 'LIABILITY', 'EQUITY');

-- CreateEnum
CREATE TYPE "PublicPageStatus" AS ENUM ('DISABLED', 'DRAFT', 'PUBLISHED');

-- CreateEnum
CREATE TYPE "AuditScope" AS ENUM ('PLATFORM', 'ORGANIZATION');

-- CreateEnum
CREATE TYPE "PlatformCaseType" AS ENUM ('ORGANIZATION_CORRECTION', 'ORGANIZATION_SUSPENSION', 'ORGANIZATION_REJECTION', 'ORGANIZATION_CLOSURE', 'DONOR_ACCOUNT_REVIEW');

-- CreateEnum
CREATE TYPE "PlatformCaseStatus" AS ENUM ('OPEN', 'AWAITING_RESPONSE', 'RESOLVED', 'CLOSED');

-- CreateEnum
CREATE TYPE "DocumentPurpose" AS ENUM ('ORGANIZATION_LOGO', 'REGISTRATION_CERTIFICATE', 'RECEIPT_PDF', 'EXPENSE_VOUCHER', 'IN_KIND_ATTACHMENT', 'REPORT_EXPORT', 'PUBLIC_REDACTED_VOUCHER', 'AUTHORIZED_SIGNATURE');

-- CreateEnum
CREATE TYPE "DocumentStatus" AS ENUM ('UPLOAD_PENDING', 'SCANNING', 'AVAILABLE', 'QUARANTINED', 'REJECTED', 'DELETED');

-- CreateTable
CREATE TABLE "health_check_records" (
    "id" UUID NOT NULL,
    "status" VARCHAR(50) NOT NULL,
    "details" JSONB,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "health_check_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "idempotency_records" (
    "id" UUID NOT NULL,
    "idempotency_key" VARCHAR(255) NOT NULL,
    "tenant_id" UUID,
    "request_path" VARCHAR(500) NOT NULL,
    "request_hash" VARCHAR(64) NOT NULL,
    "response_status" INTEGER NOT NULL,
    "response_body" JSONB NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMPTZ(6),

    CONSTRAINT "idempotency_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outbox_events" (
    "id" UUID NOT NULL,
    "tenant_id" UUID,
    "aggregate_type" VARCHAR(100) NOT NULL,
    "aggregate_id" VARCHAR(255) NOT NULL,
    "event_type" VARCHAR(100) NOT NULL,
    "payload" JSONB NOT NULL,
    "amount_paise" BIGINT,
    "status" VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    "retry_count" INTEGER NOT NULL DEFAULT 0,
    "last_error" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processed_at" TIMESTAMPTZ(6),

    CONSTRAINT "outbox_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inbox_messages" (
    "id" UUID NOT NULL,
    "message_id" VARCHAR(255) NOT NULL,
    "tenant_id" UUID,
    "source_topic" VARCHAR(100) NOT NULL,
    "payload" JSONB NOT NULL,
    "status" VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processed_at" TIMESTAMPTZ(6),

    CONSTRAINT "inbox_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "displayName" VARCHAR(150) NOT NULL,
    "preferredLanguage" "PreferredLanguage" NOT NULL DEFAULT 'EN',
    "platformRole" "PlatformRole" NOT NULL DEFAULT 'USER',
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "primaryMobile" VARCHAR(20),
    "primaryEmail" VARCHAR(320),
    "avatarDocumentId" UUID,
    "mobileVerifiedAt" TIMESTAMP(3),
    "emailVerifiedAt" TIMESTAMP(3),
    "tokenVersion" INTEGER NOT NULL DEFAULT 1,
    "deactivatedAt" TIMESTAMP(3),
    "deactivationReason" TEXT,
    "mergedIntoUserId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_identities" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "provider" "AuthProvider" NOT NULL,
    "normalizedValue" VARCHAR(320) NOT NULL,
    "isVerified" BOOLEAN NOT NULL DEFAULT false,
    "passwordHash" TEXT,
    "failedLoginCount" INTEGER NOT NULL DEFAULT 0,
    "lockedUntil" TIMESTAMP(3),
    "lastAuthenticatedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "auth_identities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "otp_challenges" (
    "id" UUID NOT NULL,
    "userId" UUID,
    "normalizedMobile" VARCHAR(20) NOT NULL,
    "purpose" "OtpPurpose" NOT NULL,
    "otpHash" TEXT NOT NULL,
    "attemptCount" INTEGER NOT NULL DEFAULT 0,
    "maxAttempts" INTEGER NOT NULL DEFAULT 5,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "consumedAt" TIMESTAMP(3),
    "requestIpHash" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "otp_challenges_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refresh_sessions" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "tokenFamilyId" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "status" "AuthSessionStatus" NOT NULL DEFAULT 'ACTIVE',
    "tokenVersion" INTEGER NOT NULL DEFAULT 1,
    "userAgentHash" TEXT,
    "ipAddressHash" TEXT,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "rotatedAt" TIMESTAMP(3),
    "revokedAt" TIMESTAMP(3),
    "revocationReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "refresh_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "donor_profiles" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "fullName" VARCHAR(150) NOT NULL,
    "mobile" VARCHAR(20),
    "email" VARCHAR(320),
    "status" "DonorProfileStatus" NOT NULL DEFAULT 'UNCLAIMED',
    "addressLine1" VARCHAR(250),
    "city" VARCHAR(100),
    "postalCode" VARCHAR(12),
    "panEncrypted" TEXT,
    "createdByUserId" UUID,
    "createdByOrgId" UUID,
    "claimedAt" TIMESTAMP(3),
    "deactivatedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "donor_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "donor_aliases" (
    "id" UUID NOT NULL,
    "survivingDonorId" UUID NOT NULL,
    "mergedDonorId" UUID NOT NULL,
    "previousMobile" TEXT,
    "previousEmail" TEXT,
    "mergeLogId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "donor_aliases_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "donor_merge_logs" (
    "id" UUID NOT NULL,
    "survivingDonorId" UUID NOT NULL,
    "mergedDonorId" UUID NOT NULL,
    "performedByUserId" UUID NOT NULL,
    "reason" TEXT NOT NULL,
    "referenceCounts" JSONB NOT NULL,
    "preMergeSnapshot" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "donor_merge_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "organizations" (
    "id" UUID NOT NULL,
    "code" VARCHAR(20) NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "addressLine1" VARCHAR(250) NOT NULL,
    "addressLine2" VARCHAR(250),
    "city" VARCHAR(100) NOT NULL,
    "state" VARCHAR(100) NOT NULL,
    "postalCode" VARCHAR(12) NOT NULL,
    "countryCode" CHAR(2) NOT NULL DEFAULT 'IN',
    "status" "OrganizationStatus" NOT NULL DEFAULT 'ACTIVE',
    "ownerUserId" UUID NOT NULL,
    "logoDocumentId" UUID,
    "registrationNumber" VARCHAR(100),
    "presidentName" VARCHAR(150),
    "festivalYear" INTEGER,
    "panEncrypted" TEXT,
    "registrationDocumentId" UUID,
    "primaryMobile" VARCHAR(20),
    "primaryEmail" VARCHAR(320),
    "bankAccountConfigured" BOOLEAN NOT NULL DEFAULT false,
    "upiConfigured" BOOLEAN NOT NULL DEFAULT false,
    "correctionNotes" TEXT,
    "statusReason" TEXT,
    "activatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "suspendedAt" TIMESTAMP(3),
    "closedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "organizations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "organization_memberships" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "roleId" UUID NOT NULL,
    "status" "MembershipStatus" NOT NULL DEFAULT 'ACTIVE',
    "isOwner" BOOLEAN NOT NULL DEFAULT false,
    "invitedByUserId" UUID,
    "deliveryMethod" "InvitationDeliveryMethod",
    "invitedAt" TIMESTAMP(3),
    "acceptedAt" TIMESTAMP(3),
    "removedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "organization_memberships_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "permissions" (
    "id" UUID NOT NULL,
    "code" VARCHAR(100) NOT NULL,
    "module" VARCHAR(50) NOT NULL,
    "action" VARCHAR(50) NOT NULL,
    "description" VARCHAR(250) NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "organization_roles" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" VARCHAR(250),
    "isSystem" BOOLEAN NOT NULL DEFAULT false,
    "isOwnerRole" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdByUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "organization_roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "role_permissions" (
    "roleId" UUID NOT NULL,
    "permissionId" UUID NOT NULL,
    "grantedByUserId" UUID NOT NULL,
    "grantedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("roleId","permissionId")
);

-- CreateTable
CREATE TABLE "events" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventTypeCode" VARCHAR(50) NOT NULL,
    "code" VARCHAR(20) NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "status" "EventStatus" NOT NULL DEFAULT 'DRAFT',
    "startDate" TIMESTAMP(3),
    "endDate" TIMESTAMP(3),
    "location" VARCHAR(250),
    "financialYear" VARCHAR(20),
    "targetAmountPaise" BIGINT,
    "activatedByUserId" UUID,
    "activatedAt" TIMESTAMP(3),
    "completedByUserId" UUID,
    "completedAt" TIMESTAMP(3),
    "closedByUserId" UUID,
    "closedAt" TIMESTAMP(3),
    "reopenedReason" TEXT,
    "archivedByUserId" UUID,
    "archivedAt" TIMESTAMP(3),
    "createdByUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "volunteers" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "linkedUserId" UUID,
    "volunteerCode" VARCHAR(30) NOT NULL,
    "type" "VolunteerType" NOT NULL,
    "customTypeLabel" VARCHAR(100),
    "status" "VolunteerStatus" NOT NULL DEFAULT 'DRAFT',
    "fullName" VARCHAR(160) NOT NULL,
    "mobileEncrypted" TEXT NOT NULL,
    "mobileHash" VARCHAR(128) NOT NULL,
    "emailEncrypted" TEXT,
    "preferredLanguage" VARCHAR(10) NOT NULL DEFAULT 'mr',
    "addressSnapshot" JSONB,
    "emergencyContactEncrypted" TEXT,
    "joinedOn" TIMESTAMP(3),
    "profileDocumentId" UUID,
    "createdByUserId" UUID NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "volunteers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "volunteer_assignments" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "volunteerId" UUID NOT NULL,
    "roleCode" VARCHAR(80) NOT NULL,
    "scopeType" "AssignmentScopeType" NOT NULL,
    "scopeReferenceId" VARCHAR(120),
    "scopeSnapshot" JSONB NOT NULL,
    "startsAt" TIMESTAMP(3) NOT NULL,
    "endsAt" TIMESTAMP(3),
    "status" "VolunteerAssignmentStatus" NOT NULL DEFAULT 'PLANNED',
    "assignedByUserId" UUID NOT NULL,
    "endedByUserId" UUID,
    "endReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "volunteer_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contributor_accounts" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "donorProfileId" UUID NOT NULL,
    "accountCode" VARCHAR(40) NOT NULL,
    "type" "ContributorAccountType" NOT NULL,
    "status" "ContributorAccountStatus" NOT NULL DEFAULT 'ACTIVE',
    "displayName" VARCHAR(200) NOT NULL,
    "contactPerson" VARCHAR(160),
    "contactSnapshot" JSONB NOT NULL,
    "billingAddressSnapshot" JSONB NOT NULL,
    "areaCode" VARCHAR(80),
    "routeCode" VARCHAR(80),
    "categoryCode" VARCHAR(80),
    "billingMode" "BillingMode" NOT NULL DEFAULT 'SUGGESTED',
    "requestedAmountPaise" BIGINT,
    "assignedVolunteerId" UUID,
    "preferredLanguage" VARCHAR(10) NOT NULL DEFAULT 'mr',
    "publicVisibility" "PublicVisibility" NOT NULL DEFAULT 'NAME_AND_AMOUNT',
    "createdByUserId" UUID NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "contributor_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receipt_books" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "code" VARCHAR(20) NOT NULL,
    "displayName" VARCHAR(100) NOT NULL,
    "assignedCollectorId" UUID,
    "status" "ReceiptBookStatus" NOT NULL DEFAULT 'OPEN',
    "openedByUserId" UUID NOT NULL,
    "openedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "closedByUserId" UUID,
    "closedAt" TIMESTAMP(3),
    "closeReason" TEXT,

    CONSTRAINT "receipt_books_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receipt_counters" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "calendarYear" INTEGER NOT NULL,
    "lastSequence" BIGINT NOT NULL DEFAULT 0,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "receipt_counters_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receipt_number_reservations" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "receiptBookId" UUID NOT NULL,
    "calendarYear" INTEGER NOT NULL,
    "sequence" BIGINT NOT NULL,
    "receiptNumber" VARCHAR(80) NOT NULL,
    "receiptId" UUID NOT NULL,
    "allocatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "receipt_number_reservations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contribution_bills" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "contributorAccountId" UUID NOT NULL,
    "assignedVolunteerId" UUID,
    "billNumber" VARCHAR(90),
    "sequence" BIGINT,
    "calendarYear" INTEGER,
    "status" "ContributionBillStatus" NOT NULL DEFAULT 'DRAFT',
    "amountMode" "BillAmountMode" NOT NULL DEFAULT 'FIXED',
    "requestedAmountPaise" BIGINT,
    "waiverAmountPaise" BIGINT NOT NULL DEFAULT 0,
    "payableAmountPaise" BIGINT,
    "confirmedCollectionPaise" BIGINT NOT NULL DEFAULT 0,
    "outstandingAmountPaise" BIGINT,
    "issueDate" TIMESTAMP(3),
    "dueDate" TIMESTAMP(3),
    "personalizedMessage" TEXT,
    "languageCode" VARCHAR(10) NOT NULL DEFAULT 'mr',
    "snapshot" JSONB,
    "paymentTokenHash" TEXT,
    "pdfDocumentId" UUID,
    "templateVersion" VARCHAR(60),
    "issuedByUserId" UUID,
    "cancelledByUserId" UUID,
    "cancellationReason" TEXT,
    "replacesBillId" UUID,
    "replacedByBillId" UUID,
    "idempotencyKey" VARCHAR(120) NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "contribution_bills_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contribution_bill_lines" (
    "id" UUID NOT NULL,
    "billId" UUID NOT NULL,
    "lineNo" INTEGER NOT NULL,
    "contributionType" "ContributionType" NOT NULL,
    "description" VARCHAR(250) NOT NULL,
    "amountPaise" BIGINT,
    "metadata" JSONB,

    CONSTRAINT "contribution_bill_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bill_generation_jobs" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "requestedByUserId" UUID NOT NULL,
    "filters" JSONB NOT NULL,
    "templateVersion" VARCHAR(60) NOT NULL,
    "idempotencyKey" VARCHAR(120) NOT NULL,
    "status" "JobStatus" NOT NULL DEFAULT 'QUEUED',
    "totalCount" INTEGER NOT NULL DEFAULT 0,
    "generatedCount" INTEGER NOT NULL DEFAULT 0,
    "skippedCount" INTEGER NOT NULL DEFAULT 0,
    "failedCount" INTEGER NOT NULL DEFAULT 0,
    "manifestDocumentId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "bill_generation_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "collection_records" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "contributorAccountId" UUID NOT NULL,
    "billId" UUID,
    "contributionId" UUID,
    "collectorVolunteerId" UUID,
    "status" "CollectionStatus" NOT NULL DEFAULT 'RECORDED',
    "mode" "CollectionMode" NOT NULL,
    "source" "CollectionSource" NOT NULL,
    "amountPaise" BIGINT NOT NULL,
    "currency" CHAR(3) NOT NULL DEFAULT 'INR',
    "collectedAt" TIMESTAMP(3) NOT NULL,
    "paymentReference" VARCHAR(160),
    "providerPaymentId" VARCHAR(160),
    "chequeSnapshot" JSONB,
    "locationSnapshot" JSONB,
    "evidenceDocumentId" UUID,
    "contributorSnapshot" JSONB,
    "collectorSnapshot" JSONB,
    "verifiedByUserId" UUID,
    "verifiedAt" TIMESTAMP(3),
    "rejectionReason" TEXT,
    "receiptId" UUID,
    "idempotencyKey" VARCHAR(120) NOT NULL,
    "createdByUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "collection_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "collection_allocations" (
    "id" UUID NOT NULL,
    "collectionRecordId" UUID NOT NULL,
    "billId" UUID,
    "contributionId" UUID NOT NULL,
    "amountPaise" BIGINT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "collection_allocations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "collector_settlements" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "collectorVolunteerId" UUID NOT NULL,
    "settlementDate" TIMESTAMP(3) NOT NULL,
    "expectedCashPaise" BIGINT NOT NULL,
    "handedOverCashPaise" BIGINT NOT NULL,
    "variancePaise" BIGINT NOT NULL,
    "status" "SettlementStatus" NOT NULL DEFAULT 'SUBMITTED',
    "reason" TEXT,
    "submittedByUserId" UUID NOT NULL,
    "approvedByUserId" UUID,
    "idempotencyKey" VARCHAR(120) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "collector_settlements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contribution_records" (
    "id" UUID NOT NULL,
    "legacyDonationId" UUID,
    "organizationId" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "contributorAccountId" UUID NOT NULL,
    "sourceType" "ContributionSourceType" NOT NULL,
    "status" "ContributionStatus" NOT NULL DEFAULT 'DRAFT',
    "billId" UUID,
    "pledgedAmountPaise" BIGINT,
    "confirmedAmountPaise" BIGINT NOT NULL DEFAULT 0,
    "refundedAmountPaise" BIGINT NOT NULL DEFAULT 0,
    "purpose" VARCHAR(250),
    "publicVisibility" "PublicVisibility" NOT NULL DEFAULT 'NAME_AND_AMOUNT',
    "snapshot" JSONB,
    "idempotencyKey" VARCHAR(120) NOT NULL,
    "createdByUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "contribution_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receipts" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "receiptBookId" UUID NOT NULL,
    "sourceType" "ReceiptSourceType" NOT NULL,
    "contributionId" UUID,
    "collectionRecordId" UUID,
    "billId" UUID,
    "contributorAccountId" UUID NOT NULL,
    "collectorVolunteerId" UUID,
    "receiptNumber" VARCHAR(90) NOT NULL,
    "sequence" BIGINT NOT NULL,
    "calendarYear" INTEGER NOT NULL,
    "status" "ReceiptStatus" NOT NULL DEFAULT 'GENERATING',
    "amountPaise" BIGINT,
    "cumulativeConfirmedPaise" BIGINT,
    "remainingBillBalancePaise" BIGINT,
    "verificationTokenHash" TEXT NOT NULL,
    "snapshot" JSONB NOT NULL,
    "snapshotChecksum" VARCHAR(128) NOT NULL,
    "pdfDocumentId" UUID,
    "templateVersion" VARCHAR(60) NOT NULL,
    "issuedByUserId" UUID NOT NULL,
    "issuedAt" TIMESTAMP(3),
    "replacesReceiptId" UUID,
    "replacedByReceiptId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "receipts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendors" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "contactPerson" VARCHAR(150),
    "mobile" VARCHAR(20),
    "email" VARCHAR(320),
    "address" TEXT,
    "gstinEncrypted" TEXT,
    "panEncrypted" TEXT,
    "bankAccountEncrypted" TEXT,
    "bankIfscEncrypted" TEXT,
    "status" "VendorStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdByUserId" UUID NOT NULL,
    "deactivatedByUserId" UUID,
    "deactivatedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "vendors_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expense_approval_policies" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT false,
    "effectiveFrom" TIMESTAMP(3) NOT NULL,
    "effectiveTo" TIMESTAMP(3),
    "createdByUserId" UUID NOT NULL,
    "activatedByUserId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "expense_approval_policies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expense_approval_policy_bands" (
    "id" UUID NOT NULL,
    "policyId" UUID NOT NULL,
    "minAmountPaise" BIGINT NOT NULL,
    "maxAmountPaise" BIGINT,
    "requiredApprovals" INTEGER NOT NULL,
    "requiredRoleNames" JSONB NOT NULL,
    "requireOwnerOrTreasurer" BOOLEAN NOT NULL DEFAULT false,
    "sequenceDefinition" JSONB NOT NULL,

    CONSTRAINT "expense_approval_policy_bands_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expense_approval_policy_snapshots" (
    "id" UUID NOT NULL,
    "expenseId" UUID NOT NULL,
    "sourcePolicyId" UUID NOT NULL,
    "sourcePolicyVersion" INTEGER NOT NULL,
    "evaluatedAmountPaise" BIGINT NOT NULL,
    "requiredApprovals" INTEGER NOT NULL,
    "steps" JSONB NOT NULL,
    "snapshot" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "expense_approval_policy_snapshots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expenses" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "vendorId" UUID NOT NULL,
    "status" "ExpenseStatus" NOT NULL DEFAULT 'DRAFT',
    "categoryCode" VARCHAR(80) NOT NULL,
    "description" TEXT NOT NULL,
    "expenseDate" TIMESTAMP(3) NOT NULL,
    "baseAmountPaise" BIGINT NOT NULL,
    "taxAmountPaise" BIGINT NOT NULL DEFAULT 0,
    "requestedAmountPaise" BIGINT NOT NULL,
    "approvedAmountPaise" BIGINT,
    "paidAmountPaise" BIGINT NOT NULL DEFAULT 0,
    "outstandingAmountPaise" BIGINT,
    "vendorSnapshot" JSONB,
    "policySnapshotId" UUID,
    "submittedByUserId" UUID,
    "submittedAt" TIMESTAMP(3),
    "rejectedByUserId" UUID,
    "rejectionReason" TEXT,
    "rejectedAt" TIMESTAMP(3),
    "cancellationRequestedByUserId" UUID,
    "cancellationApprovedByUserId" UUID,
    "cancellationReason" TEXT,
    "cancelledAt" TIMESTAMP(3),
    "createdByUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "expenses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expense_approvals" (
    "id" UUID NOT NULL,
    "expenseId" UUID NOT NULL,
    "stepNumber" INTEGER NOT NULL,
    "requiredRoleNames" JSONB NOT NULL,
    "decision" "ApprovalDecision" NOT NULL DEFAULT 'PENDING',
    "decidedByUserId" UUID,
    "reason" TEXT,
    "decidedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "expense_approvals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expense_payments" (
    "id" UUID NOT NULL,
    "expenseId" UUID NOT NULL,
    "accountId" UUID NOT NULL,
    "amountPaise" BIGINT NOT NULL,
    "paymentMode" "PaymentMode" NOT NULL,
    "transactionReference" VARCHAR(150),
    "status" "ExpensePaymentStatus" NOT NULL DEFAULT 'PENDING',
    "paidByUserId" UUID NOT NULL,
    "confirmedAt" TIMESTAMP(3),
    "ledgerTransactionId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "expense_payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expense_attachments" (
    "expenseId" UUID NOT NULL,
    "documentId" UUID NOT NULL,
    "isVoucher" BOOLEAN NOT NULL DEFAULT true,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "expense_attachments_pkey" PRIMARY KEY ("expenseId","documentId")
);

-- CreateTable
CREATE TABLE "financial_accounts" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "type" "FinancialAccountType" NOT NULL,
    "displayName" VARCHAR(120) NOT NULL,
    "status" "FinancialAccountStatus" NOT NULL DEFAULT 'ACTIVE',
    "maskedIdentifier" VARCHAR(100),
    "encryptedConfiguration" TEXT,
    "openingBalancePaise" BIGINT NOT NULL DEFAULT 0,
    "openingLedgerTransactionId" UUID,
    "createdByUserId" UUID NOT NULL,
    "deactivatedByUserId" UUID,
    "deactivatedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "financial_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "internal_transfers" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID,
    "sourceAccountId" UUID NOT NULL,
    "destinationAccountId" UUID NOT NULL,
    "amountPaise" BIGINT NOT NULL,
    "status" "TransferStatus" NOT NULL DEFAULT 'PENDING',
    "reference" VARCHAR(150),
    "description" VARCHAR(250),
    "initiatedByUserId" UUID NOT NULL,
    "ledgerTransactionId" UUID,
    "postedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "internal_transfers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ledger_transactions" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID,
    "type" "LedgerTransactionType" NOT NULL,
    "status" "LedgerTransactionStatus" NOT NULL DEFAULT 'PENDING',
    "sourceType" VARCHAR(80) NOT NULL,
    "sourceId" UUID NOT NULL,
    "idempotencyKey" VARCHAR(120) NOT NULL,
    "description" VARCHAR(250),
    "postedByUserId" UUID,
    "postedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ledger_transactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ledger_entries" (
    "id" UUID NOT NULL,
    "ledgerTransactionId" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID,
    "financialAccountId" UUID,
    "accountCode" VARCHAR(80) NOT NULL,
    "accountClass" "LedgerAccountClass" NOT NULL,
    "side" "LedgerEntrySide" NOT NULL,
    "amountPaise" BIGINT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ledger_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public_event_pages" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "eventId" UUID NOT NULL,
    "publicSlug" VARCHAR(120) NOT NULL,
    "status" "PublicPageStatus" NOT NULL DEFAULT 'DRAFT',
    "showLiveTotals" BOOLEAN NOT NULL DEFAULT true,
    "showDonorList" BOOLEAN NOT NULL DEFAULT true,
    "showExpenseSummary" BOOLEAN NOT NULL DEFAULT true,
    "showRedactedBills" BOOLEAN NOT NULL DEFAULT true,
    "approvedByUserId" UUID,
    "publishedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "public_event_pages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public_financial_snapshots" (
    "id" UUID NOT NULL,
    "publicEventPageId" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "confirmedDonationPaise" BIGINT NOT NULL,
    "verifiedInKindValuePaise" BIGINT NOT NULL,
    "paidExpensePaise" BIGINT NOT NULL,
    "outstandingApprovedPaise" BIGINT NOT NULL,
    "availableBalancePaise" BIGINT NOT NULL,
    "projectedBalancePaise" BIGINT NOT NULL,
    "categorySummary" JSONB NOT NULL,
    "donorPublicationSnapshot" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "public_financial_snapshots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL,
    "scope" "AuditScope" NOT NULL,
    "organizationId" UUID,
    "eventId" UUID,
    "actionType" VARCHAR(120) NOT NULL,
    "performedByUserId" UUID NOT NULL,
    "approvedByUserId" UUID,
    "reason" TEXT,
    "targetType" VARCHAR(80) NOT NULL,
    "targetId" UUID NOT NULL,
    "beforeSnapshot" JSONB,
    "afterSnapshot" JSONB,
    "requestId" VARCHAR(100) NOT NULL,
    "ipAddressHash" VARCHAR(128),
    "userAgent" VARCHAR(500),
    "previousHash" CHAR(64),
    "recordHash" CHAR(64) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "platform_admin_cases" (
    "id" UUID NOT NULL,
    "caseType" "PlatformCaseType" NOT NULL,
    "status" "PlatformCaseStatus" NOT NULL DEFAULT 'OPEN',
    "organizationId" UUID,
    "donorProfileId" UUID,
    "openedByUserId" UUID NOT NULL,
    "assignedToUserId" UUID,
    "reason" TEXT NOT NULL,
    "requestedActions" JSONB,
    "resolutionNotes" TEXT,
    "openedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolvedAt" TIMESTAMP(3),

    CONSTRAINT "platform_admin_cases_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "document_assets" (
    "id" UUID NOT NULL,
    "organizationId" UUID,
    "ownerUserId" UUID NOT NULL,
    "purpose" "DocumentPurpose" NOT NULL,
    "status" "DocumentStatus" NOT NULL DEFAULT 'UPLOAD_PENDING',
    "objectKey" VARCHAR(500) NOT NULL,
    "originalFileName" VARCHAR(255) NOT NULL,
    "mimeType" VARCHAR(100) NOT NULL,
    "fileSizeBytes" BIGINT NOT NULL,
    "sha256" CHAR(64) NOT NULL,
    "malwareScanResult" VARCHAR(80),
    "isImmutable" BOOLEAN NOT NULL DEFAULT false,
    "immutableAt" TIMESTAMP(3),
    "retentionUntil" TIMESTAMP(3),
    "uploadedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "document_assets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "redacted_documents" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "sourceDocumentId" UUID NOT NULL,
    "redactedDocumentId" UUID NOT NULL,
    "redactionProfile" VARCHAR(100) NOT NULL,
    "redactionSummary" JSONB NOT NULL,
    "generatedByUserId" UUID NOT NULL,
    "approvedByUserId" UUID,
    "generatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "approvedAt" TIMESTAMP(3),
    "publishedAt" TIMESTAMP(3),

    CONSTRAINT "redacted_documents_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "health_check_records_created_at_idx" ON "health_check_records"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "idempotency_records_idempotency_key_key" ON "idempotency_records"("idempotency_key");

-- CreateIndex
CREATE INDEX "idempotency_records_idempotency_key_idx" ON "idempotency_records"("idempotency_key");

-- CreateIndex
CREATE INDEX "idempotency_records_tenant_id_idempotency_key_idx" ON "idempotency_records"("tenant_id", "idempotency_key");

-- CreateIndex
CREATE INDEX "idempotency_records_expires_at_idx" ON "idempotency_records"("expires_at");

-- CreateIndex
CREATE INDEX "outbox_events_status_created_at_idx" ON "outbox_events"("status", "created_at");

-- CreateIndex
CREATE INDEX "outbox_events_tenant_id_aggregate_type_idx" ON "outbox_events"("tenant_id", "aggregate_type");

-- CreateIndex
CREATE UNIQUE INDEX "inbox_messages_message_id_key" ON "inbox_messages"("message_id");

-- CreateIndex
CREATE INDEX "inbox_messages_message_id_idx" ON "inbox_messages"("message_id");

-- CreateIndex
CREATE INDEX "inbox_messages_status_created_at_idx" ON "inbox_messages"("status", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "users_primaryMobile_key" ON "users"("primaryMobile");

-- CreateIndex
CREATE UNIQUE INDEX "users_primaryEmail_key" ON "users"("primaryEmail");

-- CreateIndex
CREATE INDEX "users_status_createdAt_idx" ON "users"("status", "createdAt");

-- CreateIndex
CREATE INDEX "users_platformRole_status_idx" ON "users"("platformRole", "status");

-- CreateIndex
CREATE INDEX "auth_identities_userId_isVerified_idx" ON "auth_identities"("userId", "isVerified");

-- CreateIndex
CREATE UNIQUE INDEX "auth_identities_provider_normalizedValue_key" ON "auth_identities"("provider", "normalizedValue");

-- CreateIndex
CREATE INDEX "otp_challenges_normalizedMobile_purpose_expiresAt_idx" ON "otp_challenges"("normalizedMobile", "purpose", "expiresAt");

-- CreateIndex
CREATE INDEX "refresh_sessions_userId_status_idx" ON "refresh_sessions"("userId", "status");

-- CreateIndex
CREATE INDEX "refresh_sessions_tokenFamilyId_idx" ON "refresh_sessions"("tokenFamilyId");

-- CreateIndex
CREATE INDEX "refresh_sessions_expiresAt_idx" ON "refresh_sessions"("expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "donor_profiles_userId_key" ON "donor_profiles"("userId");

-- CreateIndex
CREATE INDEX "donor_profiles_mobile_idx" ON "donor_profiles"("mobile");

-- CreateIndex
CREATE INDEX "donor_profiles_email_idx" ON "donor_profiles"("email");

-- CreateIndex
CREATE INDEX "donor_profiles_createdByOrgId_createdAt_idx" ON "donor_profiles"("createdByOrgId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "donor_aliases_mergedDonorId_key" ON "donor_aliases"("mergedDonorId");

-- CreateIndex
CREATE INDEX "donor_aliases_survivingDonorId_idx" ON "donor_aliases"("survivingDonorId");

-- CreateIndex
CREATE UNIQUE INDEX "donor_merge_logs_survivingDonorId_mergedDonorId_key" ON "donor_merge_logs"("survivingDonorId", "mergedDonorId");

-- CreateIndex
CREATE UNIQUE INDEX "organizations_code_key" ON "organizations"("code");

-- CreateIndex
CREATE INDEX "organizations_status_createdAt_idx" ON "organizations"("status", "createdAt");

-- CreateIndex
CREATE INDEX "organizations_ownerUserId_idx" ON "organizations"("ownerUserId");

-- CreateIndex
CREATE INDEX "organizations_name_idx" ON "organizations"("name");

-- CreateIndex
CREATE INDEX "organization_memberships_organizationId_status_idx" ON "organization_memberships"("organizationId", "status");

-- CreateIndex
CREATE INDEX "organization_memberships_userId_status_idx" ON "organization_memberships"("userId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "organization_memberships_organizationId_userId_key" ON "organization_memberships"("organizationId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "permissions_code_key" ON "permissions"("code");

-- CreateIndex
CREATE INDEX "organization_roles_organizationId_isActive_idx" ON "organization_roles"("organizationId", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "organization_roles_organizationId_name_key" ON "organization_roles"("organizationId", "name");

-- CreateIndex
CREATE INDEX "role_permissions_permissionId_idx" ON "role_permissions"("permissionId");

-- CreateIndex
CREATE INDEX "events_organizationId_status_idx" ON "events"("organizationId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "events_organizationId_code_key" ON "events"("organizationId", "code");

-- CreateIndex
CREATE UNIQUE INDEX "volunteers_linkedUserId_key" ON "volunteers"("linkedUserId");

-- CreateIndex
CREATE INDEX "volunteers_organizationId_status_type_idx" ON "volunteers"("organizationId", "status", "type");

-- CreateIndex
CREATE INDEX "volunteers_organizationId_mobileHash_idx" ON "volunteers"("organizationId", "mobileHash");

-- CreateIndex
CREATE UNIQUE INDEX "volunteers_organizationId_volunteerCode_key" ON "volunteers"("organizationId", "volunteerCode");

-- CreateIndex
CREATE INDEX "volunteer_assignments_organizationId_eventId_volunteerId_st_idx" ON "volunteer_assignments"("organizationId", "eventId", "volunteerId", "status");

-- CreateIndex
CREATE INDEX "volunteer_assignments_organizationId_eventId_scopeType_scop_idx" ON "volunteer_assignments"("organizationId", "eventId", "scopeType", "scopeReferenceId");

-- CreateIndex
CREATE INDEX "contributor_accounts_organizationId_eventId_status_areaCode_idx" ON "contributor_accounts"("organizationId", "eventId", "status", "areaCode");

-- CreateIndex
CREATE INDEX "contributor_accounts_organizationId_eventId_assignedVolunte_idx" ON "contributor_accounts"("organizationId", "eventId", "assignedVolunteerId");

-- CreateIndex
CREATE UNIQUE INDEX "contributor_accounts_organizationId_eventId_accountCode_key" ON "contributor_accounts"("organizationId", "eventId", "accountCode");

-- CreateIndex
CREATE INDEX "receipt_books_organizationId_eventId_status_idx" ON "receipt_books"("organizationId", "eventId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "receipt_books_organizationId_eventId_code_key" ON "receipt_books"("organizationId", "eventId", "code");

-- CreateIndex
CREATE UNIQUE INDEX "receipt_counters_organizationId_eventId_calendarYear_key" ON "receipt_counters"("organizationId", "eventId", "calendarYear");

-- CreateIndex
CREATE UNIQUE INDEX "receipt_number_reservations_receiptNumber_key" ON "receipt_number_reservations"("receiptNumber");

-- CreateIndex
CREATE UNIQUE INDEX "receipt_number_reservations_receiptId_key" ON "receipt_number_reservations"("receiptId");

-- CreateIndex
CREATE INDEX "receipt_number_reservations_receiptBookId_allocatedAt_idx" ON "receipt_number_reservations"("receiptBookId", "allocatedAt");

-- CreateIndex
CREATE UNIQUE INDEX "receipt_number_reservations_organizationId_eventId_calendar_key" ON "receipt_number_reservations"("organizationId", "eventId", "calendarYear", "sequence");

-- CreateIndex
CREATE UNIQUE INDEX "contribution_bills_billNumber_key" ON "contribution_bills"("billNumber");

-- CreateIndex
CREATE UNIQUE INDEX "contribution_bills_paymentTokenHash_key" ON "contribution_bills"("paymentTokenHash");

-- CreateIndex
CREATE UNIQUE INDEX "contribution_bills_pdfDocumentId_key" ON "contribution_bills"("pdfDocumentId");

-- CreateIndex
CREATE UNIQUE INDEX "contribution_bills_replacesBillId_key" ON "contribution_bills"("replacesBillId");

-- CreateIndex
CREATE UNIQUE INDEX "contribution_bills_replacedByBillId_key" ON "contribution_bills"("replacedByBillId");

-- CreateIndex
CREATE UNIQUE INDEX "contribution_bills_idempotencyKey_key" ON "contribution_bills"("idempotencyKey");

-- CreateIndex
CREATE INDEX "contribution_bills_organizationId_eventId_status_issueDate_idx" ON "contribution_bills"("organizationId", "eventId", "status", "issueDate");

-- CreateIndex
CREATE INDEX "contribution_bills_organizationId_eventId_assignedVolunteer_idx" ON "contribution_bills"("organizationId", "eventId", "assignedVolunteerId");

-- CreateIndex
CREATE INDEX "contribution_bills_contributorAccountId_createdAt_idx" ON "contribution_bills"("contributorAccountId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "contribution_bill_lines_billId_lineNo_key" ON "contribution_bill_lines"("billId", "lineNo");

-- CreateIndex
CREATE UNIQUE INDEX "bill_generation_jobs_idempotencyKey_key" ON "bill_generation_jobs"("idempotencyKey");

-- CreateIndex
CREATE UNIQUE INDEX "collection_records_providerPaymentId_key" ON "collection_records"("providerPaymentId");

-- CreateIndex
CREATE UNIQUE INDEX "collection_records_receiptId_key" ON "collection_records"("receiptId");

-- CreateIndex
CREATE UNIQUE INDEX "collection_records_idempotencyKey_key" ON "collection_records"("idempotencyKey");

-- CreateIndex
CREATE INDEX "collection_records_organizationId_eventId_status_collectedA_idx" ON "collection_records"("organizationId", "eventId", "status", "collectedAt");

-- CreateIndex
CREATE INDEX "collection_records_organizationId_eventId_collectorVoluntee_idx" ON "collection_records"("organizationId", "eventId", "collectorVolunteerId");

-- CreateIndex
CREATE INDEX "collection_records_billId_status_idx" ON "collection_records"("billId", "status");

-- CreateIndex
CREATE INDEX "collection_allocations_billId_createdAt_idx" ON "collection_allocations"("billId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "collection_allocations_collectionRecordId_contributionId_bi_key" ON "collection_allocations"("collectionRecordId", "contributionId", "billId");

-- CreateIndex
CREATE UNIQUE INDEX "collector_settlements_idempotencyKey_key" ON "collector_settlements"("idempotencyKey");

-- CreateIndex
CREATE UNIQUE INDEX "collector_settlements_organizationId_eventId_collectorVolun_key" ON "collector_settlements"("organizationId", "eventId", "collectorVolunteerId", "settlementDate");

-- CreateIndex
CREATE UNIQUE INDEX "contribution_records_legacyDonationId_key" ON "contribution_records"("legacyDonationId");

-- CreateIndex
CREATE UNIQUE INDEX "contribution_records_idempotencyKey_key" ON "contribution_records"("idempotencyKey");

-- CreateIndex
CREATE INDEX "contribution_records_organizationId_eventId_status_createdA_idx" ON "contribution_records"("organizationId", "eventId", "status", "createdAt");

-- CreateIndex
CREATE INDEX "contribution_records_contributorAccountId_createdAt_idx" ON "contribution_records"("contributorAccountId", "createdAt");

-- CreateIndex
CREATE INDEX "contribution_records_billId_idx" ON "contribution_records"("billId");

-- CreateIndex
CREATE UNIQUE INDEX "receipts_collectionRecordId_key" ON "receipts"("collectionRecordId");

-- CreateIndex
CREATE UNIQUE INDEX "receipts_receiptNumber_key" ON "receipts"("receiptNumber");

-- CreateIndex
CREATE UNIQUE INDEX "receipts_verificationTokenHash_key" ON "receipts"("verificationTokenHash");

-- CreateIndex
CREATE UNIQUE INDEX "receipts_pdfDocumentId_key" ON "receipts"("pdfDocumentId");

-- CreateIndex
CREATE UNIQUE INDEX "receipts_replacesReceiptId_key" ON "receipts"("replacesReceiptId");

-- CreateIndex
CREATE UNIQUE INDEX "receipts_replacedByReceiptId_key" ON "receipts"("replacedByReceiptId");

-- CreateIndex
CREATE INDEX "receipts_organizationId_eventId_issuedAt_idx" ON "receipts"("organizationId", "eventId", "issuedAt");

-- CreateIndex
CREATE INDEX "receipts_billId_issuedAt_idx" ON "receipts"("billId", "issuedAt");

-- CreateIndex
CREATE INDEX "receipts_collectorVolunteerId_issuedAt_idx" ON "receipts"("collectorVolunteerId", "issuedAt");

-- CreateIndex
CREATE INDEX "vendors_organizationId_status_idx" ON "vendors"("organizationId", "status");

-- CreateIndex
CREATE INDEX "vendors_organizationId_mobile_idx" ON "vendors"("organizationId", "mobile");

-- CreateIndex
CREATE UNIQUE INDEX "vendors_organizationId_name_key" ON "vendors"("organizationId", "name");

-- CreateIndex
CREATE INDEX "expense_approval_policies_organizationId_isActive_effective_idx" ON "expense_approval_policies"("organizationId", "isActive", "effectiveFrom");

-- CreateIndex
CREATE UNIQUE INDEX "expense_approval_policies_organizationId_version_key" ON "expense_approval_policies"("organizationId", "version");

-- CreateIndex
CREATE INDEX "expense_approval_policy_bands_policyId_minAmountPaise_idx" ON "expense_approval_policy_bands"("policyId", "minAmountPaise");

-- CreateIndex
CREATE UNIQUE INDEX "expense_approval_policy_snapshots_expenseId_key" ON "expense_approval_policy_snapshots"("expenseId");

-- CreateIndex
CREATE INDEX "expense_approval_policy_snapshots_sourcePolicyId_sourcePoli_idx" ON "expense_approval_policy_snapshots"("sourcePolicyId", "sourcePolicyVersion");

-- CreateIndex
CREATE UNIQUE INDEX "expenses_policySnapshotId_key" ON "expenses"("policySnapshotId");

-- CreateIndex
CREATE INDEX "expenses_organizationId_eventId_status_idx" ON "expenses"("organizationId", "eventId", "status");

-- CreateIndex
CREATE INDEX "expenses_vendorId_expenseDate_idx" ON "expenses"("vendorId", "expenseDate");

-- CreateIndex
CREATE INDEX "expense_approvals_decision_createdAt_idx" ON "expense_approvals"("decision", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "expense_approvals_expenseId_stepNumber_key" ON "expense_approvals"("expenseId", "stepNumber");

-- CreateIndex
CREATE UNIQUE INDEX "expense_payments_ledgerTransactionId_key" ON "expense_payments"("ledgerTransactionId");

-- CreateIndex
CREATE INDEX "expense_payments_expenseId_status_idx" ON "expense_payments"("expenseId", "status");

-- CreateIndex
CREATE INDEX "expense_payments_accountId_confirmedAt_idx" ON "expense_payments"("accountId", "confirmedAt");

-- CreateIndex
CREATE UNIQUE INDEX "financial_accounts_openingLedgerTransactionId_key" ON "financial_accounts"("openingLedgerTransactionId");

-- CreateIndex
CREATE INDEX "financial_accounts_organizationId_status_idx" ON "financial_accounts"("organizationId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "financial_accounts_organizationId_type_key" ON "financial_accounts"("organizationId", "type");

-- CreateIndex
CREATE UNIQUE INDEX "internal_transfers_ledgerTransactionId_key" ON "internal_transfers"("ledgerTransactionId");

-- CreateIndex
CREATE INDEX "internal_transfers_organizationId_createdAt_idx" ON "internal_transfers"("organizationId", "createdAt");

-- CreateIndex
CREATE INDEX "internal_transfers_sourceAccountId_status_idx" ON "internal_transfers"("sourceAccountId", "status");

-- CreateIndex
CREATE INDEX "internal_transfers_destinationAccountId_status_idx" ON "internal_transfers"("destinationAccountId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "ledger_transactions_idempotencyKey_key" ON "ledger_transactions"("idempotencyKey");

-- CreateIndex
CREATE INDEX "ledger_transactions_organizationId_eventId_postedAt_idx" ON "ledger_transactions"("organizationId", "eventId", "postedAt");

-- CreateIndex
CREATE INDEX "ledger_transactions_status_createdAt_idx" ON "ledger_transactions"("status", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "ledger_transactions_organizationId_sourceType_sourceId_type_key" ON "ledger_transactions"("organizationId", "sourceType", "sourceId", "type");

-- CreateIndex
CREATE INDEX "ledger_entries_organizationId_eventId_createdAt_idx" ON "ledger_entries"("organizationId", "eventId", "createdAt");

-- CreateIndex
CREATE INDEX "ledger_entries_financialAccountId_createdAt_idx" ON "ledger_entries"("financialAccountId", "createdAt");

-- CreateIndex
CREATE INDEX "ledger_entries_accountCode_createdAt_idx" ON "ledger_entries"("accountCode", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "public_event_pages_eventId_key" ON "public_event_pages"("eventId");

-- CreateIndex
CREATE UNIQUE INDEX "public_event_pages_publicSlug_key" ON "public_event_pages"("publicSlug");

-- CreateIndex
CREATE INDEX "public_event_pages_organizationId_status_idx" ON "public_event_pages"("organizationId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "public_financial_snapshots_publicEventPageId_version_key" ON "public_financial_snapshots"("publicEventPageId", "version");

-- CreateIndex
CREATE UNIQUE INDEX "audit_logs_recordHash_key" ON "audit_logs"("recordHash");

-- CreateIndex
CREATE INDEX "audit_logs_scope_organizationId_createdAt_idx" ON "audit_logs"("scope", "organizationId", "createdAt");

-- CreateIndex
CREATE INDEX "audit_logs_eventId_createdAt_idx" ON "audit_logs"("eventId", "createdAt");

-- CreateIndex
CREATE INDEX "audit_logs_targetType_targetId_idx" ON "audit_logs"("targetType", "targetId");

-- CreateIndex
CREATE INDEX "audit_logs_performedByUserId_createdAt_idx" ON "audit_logs"("performedByUserId", "createdAt");

-- CreateIndex
CREATE INDEX "platform_admin_cases_status_caseType_openedAt_idx" ON "platform_admin_cases"("status", "caseType", "openedAt");

-- CreateIndex
CREATE INDEX "platform_admin_cases_organizationId_idx" ON "platform_admin_cases"("organizationId");

-- CreateIndex
CREATE INDEX "platform_admin_cases_donorProfileId_idx" ON "platform_admin_cases"("donorProfileId");

-- CreateIndex
CREATE UNIQUE INDEX "document_assets_objectKey_key" ON "document_assets"("objectKey");

-- CreateIndex
CREATE INDEX "document_assets_organizationId_purpose_status_idx" ON "document_assets"("organizationId", "purpose", "status");

-- CreateIndex
CREATE INDEX "document_assets_ownerUserId_createdAt_idx" ON "document_assets"("ownerUserId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "redacted_documents_redactedDocumentId_key" ON "redacted_documents"("redactedDocumentId");

-- CreateIndex
CREATE INDEX "redacted_documents_organizationId_approvedAt_idx" ON "redacted_documents"("organizationId", "approvedAt");

-- CreateIndex
CREATE UNIQUE INDEX "redacted_documents_sourceDocumentId_redactedDocumentId_key" ON "redacted_documents"("sourceDocumentId", "redactedDocumentId");

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_mergedIntoUserId_fkey" FOREIGN KEY ("mergedIntoUserId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth_identities" ADD CONSTRAINT "auth_identities_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "otp_challenges" ADD CONSTRAINT "otp_challenges_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "refresh_sessions" ADD CONSTRAINT "refresh_sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "donor_aliases" ADD CONSTRAINT "donor_aliases_survivingDonorId_fkey" FOREIGN KEY ("survivingDonorId") REFERENCES "donor_profiles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "organization_memberships" ADD CONSTRAINT "organization_memberships_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "organization_roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "organization_roles" ADD CONSTRAINT "organization_roles_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "organization_roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "permissions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contribution_bill_lines" ADD CONSTRAINT "contribution_bill_lines_billId_fkey" FOREIGN KEY ("billId") REFERENCES "contribution_bills"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "collection_allocations" ADD CONSTRAINT "collection_allocations_collectionRecordId_fkey" FOREIGN KEY ("collectionRecordId") REFERENCES "collection_records"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expense_approval_policy_bands" ADD CONSTRAINT "expense_approval_policy_bands_policyId_fkey" FOREIGN KEY ("policyId") REFERENCES "expense_approval_policies"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_vendorId_fkey" FOREIGN KEY ("vendorId") REFERENCES "vendors"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expense_approvals" ADD CONSTRAINT "expense_approvals_expenseId_fkey" FOREIGN KEY ("expenseId") REFERENCES "expenses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expense_payments" ADD CONSTRAINT "expense_payments_expenseId_fkey" FOREIGN KEY ("expenseId") REFERENCES "expenses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expense_attachments" ADD CONSTRAINT "expense_attachments_expenseId_fkey" FOREIGN KEY ("expenseId") REFERENCES "expenses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_entries" ADD CONSTRAINT "ledger_entries_ledgerTransactionId_fkey" FOREIGN KEY ("ledgerTransactionId") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public_financial_snapshots" ADD CONSTRAINT "public_financial_snapshots_publicEventPageId_fkey" FOREIGN KEY ("publicEventPageId") REFERENCES "public_event_pages"("id") ON DELETE CASCADE ON UPDATE CASCADE;
