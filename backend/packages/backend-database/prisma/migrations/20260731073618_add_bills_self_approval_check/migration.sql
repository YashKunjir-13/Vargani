-- AlterTable: Add self-approval CHECK constraint to bills table
ALTER TABLE "bills" ADD CONSTRAINT "chk_bills_no_self_approval" CHECK ("approvedByUserId" IS NULL OR "approvedByUserId" <> "createdByUserId");
