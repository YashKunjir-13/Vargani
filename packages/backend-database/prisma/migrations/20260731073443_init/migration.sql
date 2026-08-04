-- CreateEnum
CREATE TYPE "WhatsAppDeliveryStatus" AS ENUM ('PENDING', 'SENT', 'FAILED');

-- CreateEnum
CREATE TYPE "TemplateType" AS ENUM ('RECEIPT', 'BILL');

-- CreateEnum
CREATE TYPE "TemplateDetectionStatus" AS ENUM ('PENDING', 'AUTO_DETECTED', 'MANUALLY_CALIBRATED', 'FAILED');

-- CreateEnum
CREATE TYPE "PaymentChannel" AS ENUM ('IN_APP', 'QR_CODE');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING_MATCH', 'CONFIRMED', 'RECEIPTED', 'VOIDED');

-- CreateEnum
CREATE TYPE "PaymentReceiptStatus" AS ENUM ('ACTIVE', 'VOIDED');

-- CreateEnum
CREATE TYPE "BillStatus" AS ENUM ('DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'PAID', 'CANCELLED');

-- CreateEnum
CREATE TYPE "FestivalContributionStatus" AS ENUM ('RECORDED', 'RECEIPTED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ContributionReceiptStatus" AS ENUM ('ACTIVE', 'VOIDED');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "DocumentPurpose" ADD VALUE 'RECEIPT_TEMPLATE';
ALTER TYPE "DocumentPurpose" ADD VALUE 'ORGANIZATION_STAMP';

-- CreateTable
CREATE TABLE "sequence_counters" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "festivalYear" INTEGER NOT NULL,
    "sequenceName" VARCHAR(60) NOT NULL,
    "lastSequence" BIGINT NOT NULL DEFAULT 0,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "sequence_counters_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "whatsapp_delivery_records" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "recipientPhone" VARCHAR(20) NOT NULL,
    "mediaUrl" TEXT NOT NULL,
    "status" "WhatsAppDeliveryStatus" NOT NULL DEFAULT 'PENDING',
    "retryCount" INTEGER NOT NULL DEFAULT 0,
    "lastError" TEXT,
    "providerMessageId" VARCHAR(200),
    "relatedEntityType" VARCHAR(50),
    "relatedEntityId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "whatsapp_delivery_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receipt_templates" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "templateType" "TemplateType" NOT NULL,
    "version" INTEGER NOT NULL,
    "sourceFileUrl" VARCHAR(500),
    "fieldMap" JSONB NOT NULL DEFAULT '[]',
    "detectionStatus" "TemplateDetectionStatus" NOT NULL DEFAULT 'PENDING',
    "isActive" BOOLEAN NOT NULL DEFAULT false,
    "uploadedByUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "receipt_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "festivalYear" INTEGER NOT NULL,
    "donorId" UUID,
    "donorNameSnapshot" VARCHAR(200) NOT NULL,
    "addressSnapshot" TEXT,
    "contactSnapshot" VARCHAR(50),
    "amount" DECIMAL(12,2) NOT NULL,
    "paymentDateTime" TIMESTAMP(3) NOT NULL,
    "channel" "PaymentChannel" NOT NULL,
    "razorpayOrderId" VARCHAR(100),
    "razorpayPaymentId" VARCHAR(100),
    "collectedByUserId" UUID,
    "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING_MATCH',
    "matchedByUserId" UUID,
    "matchedAt" TIMESTAMP(3),
    "voidReason" TEXT,
    "createdByUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_audit_events" (
    "id" UUID NOT NULL,
    "organizationId" UUID,
    "paymentId" UUID,
    "actionType" VARCHAR(60) NOT NULL,
    "performedByUserId" UUID,
    "reason" TEXT,
    "detail" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payment_audit_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_receipts" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "festivalYear" INTEGER NOT NULL,
    "paymentId" UUID NOT NULL,
    "donorId" UUID,
    "donorNameSnapshot" VARCHAR(200) NOT NULL,
    "amountSnapshot" DECIMAL(12,2) NOT NULL,
    "receiptNumber" VARCHAR(40) NOT NULL,
    "issuedDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "mandalNameSnapshot" VARCHAR(200) NOT NULL,
    "stampAssetUrl" TEXT,
    "signatureAssetUrl" TEXT,
    "templateVersionId" UUID,
    "pdfUrl" TEXT NOT NULL,
    "whatsappDeliveryStatus" "WhatsAppDeliveryStatus" NOT NULL DEFAULT 'PENDING',
    "whatsappRetryCount" INTEGER NOT NULL DEFAULT 0,
    "status" "PaymentReceiptStatus" NOT NULL DEFAULT 'ACTIVE',
    "voidedByUserId" UUID,
    "voidReason" TEXT,
    "voidedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "payment_receipts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_receipt_audit_events" (
    "id" UUID NOT NULL,
    "organizationId" UUID,
    "receiptId" UUID,
    "actionType" VARCHAR(60) NOT NULL,
    "performedByUserId" UUID,
    "reason" TEXT,
    "detail" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payment_receipt_audit_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bills" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "festivalYear" INTEGER NOT NULL,
    "billNumber" VARCHAR(40) NOT NULL,
    "vendorId" UUID,
    "receiverNameSnapshot" VARCHAR(200) NOT NULL,
    "contactSnapshot" VARCHAR(50),
    "amount" DECIMAL(12,2) NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "taskOrField" VARCHAR(200) NOT NULL,
    "milestoneId" UUID,
    "billPhotoUrl" TEXT,
    "status" "BillStatus" NOT NULL DEFAULT 'DRAFT',
    "createdByUserId" UUID NOT NULL,
    "submittedAt" TIMESTAMP(3),
    "approvedByUserId" UUID,
    "approvedAt" TIMESTAMP(3),
    "rejectionReason" TEXT,
    "paymentMode" "PaymentMode",
    "paidAt" TIMESTAMP(3),
    "cancelReason" TEXT,
    "cancelledByUserId" UUID,
    "cancelledAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "bills_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bill_audit_events" (
    "id" UUID NOT NULL,
    "organizationId" UUID,
    "billId" UUID,
    "actionType" VARCHAR(60) NOT NULL,
    "performedByUserId" UUID,
    "reason" TEXT,
    "detail" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "bill_audit_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contributions" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "festival_year" INTEGER NOT NULL,
    "contributor_id" UUID,
    "contributor_name_snapshot" VARCHAR(200) NOT NULL,
    "contact_snapshot" VARCHAR(50),
    "date" DATE NOT NULL,
    "donation_type" VARCHAR(100) NOT NULL,
    "item_description" TEXT,
    "weight" DECIMAL(10,3),
    "estimated_value" DECIMAL(12,2),
    "certificate_photo_url" TEXT,
    "recorded_by" UUID NOT NULL,
    "status" "FestivalContributionStatus" NOT NULL DEFAULT 'RECORDED',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "contributions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contribution_receipts" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "festival_year" INTEGER NOT NULL,
    "contribution_id" UUID NOT NULL,
    "contributor_id" UUID,
    "contributor_name_snapshot" VARCHAR(200) NOT NULL,
    "donation_type_snapshot" VARCHAR(100) NOT NULL,
    "contribution_receipt_number" VARCHAR(40) NOT NULL,
    "issued_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "mandal_name_snapshot" VARCHAR(200) NOT NULL,
    "stamp_asset_url" TEXT,
    "signature_asset_url" TEXT,
    "template_version_id" UUID,
    "pdf_url" TEXT NOT NULL,
    "whatsapp_delivery_status" "WhatsAppDeliveryStatus" NOT NULL DEFAULT 'PENDING',
    "whatsapp_retry_count" INTEGER NOT NULL DEFAULT 0,
    "status" "ContributionReceiptStatus" NOT NULL DEFAULT 'ACTIVE',
    "voided_by" UUID,
    "void_reason" TEXT,
    "voided_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "contribution_receipts_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "sequence_counters_organizationId_festivalYear_sequenceName_key" ON "sequence_counters"("organizationId", "festivalYear", "sequenceName");

-- CreateIndex
CREATE INDEX "whatsapp_delivery_records_organizationId_status_idx" ON "whatsapp_delivery_records"("organizationId", "status");

-- CreateIndex
CREATE INDEX "whatsapp_delivery_records_relatedEntityType_relatedEntityId_idx" ON "whatsapp_delivery_records"("relatedEntityType", "relatedEntityId");

-- CreateIndex
CREATE INDEX "receipt_templates_organizationId_templateType_isActive_idx" ON "receipt_templates"("organizationId", "templateType", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "receipt_templates_organizationId_templateType_version_key" ON "receipt_templates"("organizationId", "templateType", "version");

-- CreateIndex
CREATE UNIQUE INDEX "payments_razorpayOrderId_key" ON "payments"("razorpayOrderId");

-- CreateIndex
CREATE UNIQUE INDEX "payments_razorpayPaymentId_key" ON "payments"("razorpayPaymentId");

-- CreateIndex
CREATE INDEX "payments_organizationId_festivalYear_status_idx" ON "payments"("organizationId", "festivalYear", "status");

-- CreateIndex
CREATE INDEX "payments_organizationId_channel_idx" ON "payments"("organizationId", "channel");

-- CreateIndex
CREATE INDEX "payments_organizationId_donorId_idx" ON "payments"("organizationId", "donorId");

-- CreateIndex
CREATE INDEX "payments_collectedByUserId_idx" ON "payments"("collectedByUserId");

-- CreateIndex
CREATE INDEX "payment_audit_events_organizationId_createdAt_idx" ON "payment_audit_events"("organizationId", "createdAt");

-- CreateIndex
CREATE INDEX "payment_audit_events_paymentId_idx" ON "payment_audit_events"("paymentId");

-- CreateIndex
CREATE UNIQUE INDEX "payment_receipts_paymentId_key" ON "payment_receipts"("paymentId");

-- CreateIndex
CREATE INDEX "payment_receipts_organizationId_donorId_idx" ON "payment_receipts"("organizationId", "donorId");

-- CreateIndex
CREATE INDEX "payment_receipts_organizationId_status_idx" ON "payment_receipts"("organizationId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "payment_receipts_organizationId_festivalYear_receiptNumber_key" ON "payment_receipts"("organizationId", "festivalYear", "receiptNumber");

-- CreateIndex
CREATE INDEX "payment_receipt_audit_events_organizationId_createdAt_idx" ON "payment_receipt_audit_events"("organizationId", "createdAt");

-- CreateIndex
CREATE INDEX "payment_receipt_audit_events_receiptId_idx" ON "payment_receipt_audit_events"("receiptId");

-- CreateIndex
CREATE INDEX "bills_organizationId_festivalYear_status_idx" ON "bills"("organizationId", "festivalYear", "status");

-- CreateIndex
CREATE INDEX "bills_organizationId_vendorId_idx" ON "bills"("organizationId", "vendorId");

-- CreateIndex
CREATE UNIQUE INDEX "bills_organizationId_festivalYear_billNumber_key" ON "bills"("organizationId", "festivalYear", "billNumber");

-- CreateIndex
CREATE INDEX "bill_audit_events_organizationId_createdAt_idx" ON "bill_audit_events"("organizationId", "createdAt");

-- CreateIndex
CREATE INDEX "bill_audit_events_billId_idx" ON "bill_audit_events"("billId");

-- CreateIndex
CREATE INDEX "contributions_organization_id_festival_year_idx" ON "contributions"("organization_id", "festival_year");

-- CreateIndex
CREATE UNIQUE INDEX "contribution_receipts_contribution_id_key" ON "contribution_receipts"("contribution_id");

-- CreateIndex
CREATE INDEX "contribution_receipts_organization_id_contributor_id_idx" ON "contribution_receipts"("organization_id", "contributor_id");

-- CreateIndex
CREATE INDEX "contribution_receipts_organization_id_status_idx" ON "contribution_receipts"("organization_id", "status");

-- CreateIndex
CREATE UNIQUE INDEX "contribution_receipts_organization_id_festival_year_contrib_key" ON "contribution_receipts"("organization_id", "festival_year", "contribution_receipt_number");

-- AddForeignKey
ALTER TABLE "contribution_receipts" ADD CONSTRAINT "contribution_receipts_contribution_id_fkey" FOREIGN KEY ("contribution_id") REFERENCES "contributions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
