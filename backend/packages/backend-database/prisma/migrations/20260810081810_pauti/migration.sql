-- CreateEnum
CREATE TYPE "ConfigurationScope" AS ENUM ('PLATFORM', 'ORGANIZATION', 'EVENT');

-- CreateEnum
CREATE TYPE "ConfigurationValueType" AS ENUM ('STRING', 'NUMBER', 'BOOLEAN', 'JSON');

-- CreateEnum
CREATE TYPE "DevicePlatform" AS ENUM ('ANDROID', 'IOS', 'WEB');

-- AlterEnum
ALTER TYPE "OtpPurpose" ADD VALUE 'MPIN_RESET';

-- AlterTable
ALTER TABLE "auth_identities" ADD COLUMN     "failedMpinCount" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "mpinHash" TEXT,
ADD COLUMN     "mpinLockedUntil" TIMESTAMP(3);

-- CreateTable
CREATE TABLE "organization_invitations" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "invitedByUserId" UUID NOT NULL,
    "targetMobile" VARCHAR(20),
    "targetEmail" VARCHAR(320),
    "roleId" UUID NOT NULL,
    "deliveryMethod" "InvitationDeliveryMethod" NOT NULL,
    "tokenHash" TEXT,
    "status" "MembershipStatus" NOT NULL DEFAULT 'INVITED',
    "expiresAt" TIMESTAMP(3),
    "acceptedByUserId" UUID,
    "acceptedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "organization_invitations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "organization_settings" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "defaultLanguage" "PreferredLanguage" NOT NULL DEFAULT 'EN',
    "enabledLanguages" "PreferredLanguage"[],
    "timezone" VARCHAR(60) NOT NULL DEFAULT 'Asia/Kolkata',
    "financialYearStartMonth" INTEGER NOT NULL DEFAULT 4,
    "financialYearStartDay" INTEGER NOT NULL DEFAULT 1,
    "invitationAcceptanceRequired" BOOLEAN NOT NULL DEFAULT false,
    "defaultDonorVisibility" "PublicVisibility" NOT NULL DEFAULT 'NAME_AND_AMOUNT',
    "inKindValueRequired" BOOLEAN NOT NULL DEFAULT false,
    "includeInKindInContributionTotal" BOOLEAN NOT NULL DEFAULT true,
    "collectorBoundReceiptBooks" BOOLEAN NOT NULL DEFAULT false,
    "receiptTemplateCode" VARCHAR(100) NOT NULL DEFAULT 'STANDARD_TRILINGUAL',
    "authorizedSignatureDocumentId" UUID,
    "whatsappEnabled" BOOLEAN NOT NULL DEFAULT true,
    "emailEnabled" BOOLEAN NOT NULL DEFAULT true,
    "inAppEnabled" BOOLEAN NOT NULL DEFAULT true,
    "updatedByUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "organization_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "organization_settings_history" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "snapshot" JSONB NOT NULL,
    "changedByUserId" UUID NOT NULL,
    "changeReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "organization_settings_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "platform_settings" (
    "id" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "supportedEventTypes" JSONB NOT NULL,
    "maxFileSizeBytes" BIGINT NOT NULL DEFAULT 10485760,
    "maxLogoSizeBytes" BIGINT NOT NULL DEFAULT 5242880,
    "maxAttachmentsPerEntity" INTEGER NOT NULL DEFAULT 5,
    "featureFlags" JSONB NOT NULL,
    "updatedByUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "platform_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "configuration_entries" (
    "id" UUID NOT NULL,
    "scope" "ConfigurationScope" NOT NULL,
    "scopeId" UUID,
    "key" VARCHAR(160) NOT NULL,
    "valueType" "ConfigurationValueType" NOT NULL,
    "valueJson" JSONB NOT NULL,
    "schemaVersion" INTEGER NOT NULL DEFAULT 1,
    "version" INTEGER NOT NULL DEFAULT 1,
    "isSensitive" BOOLEAN NOT NULL DEFAULT false,
    "effectiveFrom" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "effectiveTo" TIMESTAMP(3),
    "changedByUserId" UUID NOT NULL,
    "changeReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "configuration_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "feature_flags" (
    "id" UUID NOT NULL,
    "key" VARCHAR(160) NOT NULL,
    "description" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT false,
    "scopeRules" JSONB,
    "rolloutPercent" INTEGER NOT NULL DEFAULT 0,
    "ownerTeam" VARCHAR(100) NOT NULL,
    "expiresAt" TIMESTAMP(3),
    "changedByUserId" UUID NOT NULL,
    "changeReason" TEXT,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "feature_flags_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reference_data_values" (
    "id" UUID NOT NULL,
    "organizationId" UUID,
    "catalog" VARCHAR(100) NOT NULL,
    "code" VARCHAR(80) NOT NULL,
    "labels" JSONB NOT NULL,
    "metadata" JSONB,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "effectiveFrom" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "effectiveTo" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reference_data_values_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "device_tokens" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "deviceToken" VARCHAR(500) NOT NULL,
    "platform" "DevicePlatform" NOT NULL DEFAULT 'ANDROID',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "device_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_notifications" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "body" TEXT NOT NULL,
    "actionUrl" TEXT,
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "readAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification_templates" (
    "id" UUID NOT NULL,
    "organizationId" UUID,
    "code" VARCHAR(100) NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "channel" VARCHAR(50) NOT NULL,
    "subjectPattern" VARCHAR(250),
    "bodyPattern" TEXT NOT NULL,
    "languageCode" VARCHAR(10) NOT NULL DEFAULT 'en',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notification_templates_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "organization_invitations_tokenHash_key" ON "organization_invitations"("tokenHash");

-- CreateIndex
CREATE INDEX "organization_invitations_organizationId_status_idx" ON "organization_invitations"("organizationId", "status");

-- CreateIndex
CREATE INDEX "organization_invitations_targetMobile_idx" ON "organization_invitations"("targetMobile");

-- CreateIndex
CREATE INDEX "organization_invitations_targetEmail_idx" ON "organization_invitations"("targetEmail");

-- CreateIndex
CREATE UNIQUE INDEX "organization_settings_organizationId_key" ON "organization_settings"("organizationId");

-- CreateIndex
CREATE UNIQUE INDEX "organization_settings_history_organizationId_version_key" ON "organization_settings_history"("organizationId", "version");

-- CreateIndex
CREATE UNIQUE INDEX "platform_settings_version_key" ON "platform_settings"("version");

-- CreateIndex
CREATE INDEX "configuration_entries_scope_scopeId_key_effectiveFrom_idx" ON "configuration_entries"("scope", "scopeId", "key", "effectiveFrom");

-- CreateIndex
CREATE UNIQUE INDEX "configuration_entries_scope_scopeId_key_version_key" ON "configuration_entries"("scope", "scopeId", "key", "version");

-- CreateIndex
CREATE UNIQUE INDEX "feature_flags_key_key" ON "feature_flags"("key");

-- CreateIndex
CREATE INDEX "reference_data_values_catalog_isActive_idx" ON "reference_data_values"("catalog", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "reference_data_values_organizationId_catalog_code_effective_key" ON "reference_data_values"("organizationId", "catalog", "code", "effectiveFrom");

-- CreateIndex
CREATE UNIQUE INDEX "device_tokens_deviceToken_key" ON "device_tokens"("deviceToken");

-- CreateIndex
CREATE INDEX "device_tokens_userId_idx" ON "device_tokens"("userId");

-- CreateIndex
CREATE INDEX "user_notifications_organizationId_userId_isRead_idx" ON "user_notifications"("organizationId", "userId", "isRead");

-- CreateIndex
CREATE INDEX "user_notifications_userId_createdAt_idx" ON "user_notifications"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "notification_templates_code_key" ON "notification_templates"("code");

-- CreateIndex
CREATE INDEX "notification_templates_code_isActive_idx" ON "notification_templates"("code", "isActive");

-- AddForeignKey
ALTER TABLE "organization_memberships" ADD CONSTRAINT "organization_memberships_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "organization_invitations" ADD CONSTRAINT "organization_invitations_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "organization_settings" ADD CONSTRAINT "organization_settings_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "device_tokens" ADD CONSTRAINT "device_tokens_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_notifications" ADD CONSTRAINT "user_notifications_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
