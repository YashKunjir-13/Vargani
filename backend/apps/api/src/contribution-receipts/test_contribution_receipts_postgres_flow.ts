import { PrismaClient } from "@pauti-pustak/backend-database";
import { SequenceCounterService } from "../common/sequence/sequence-counter.service";
import { ContributionsRepository, ContributionsService } from "../contribution/contribution.service";
import { ContributionReceiptsRepository, ContributionReceiptsService } from "./contribution-receipts.service";

async function runPostgresContributionReceiptFlowProof() {
  const prisma = new PrismaClient({
    datasources: {
      db: {
        url: process.env.DATABASE_URL || "postgresql://pauti_user:pauti_password@localhost:5432/pauti_pustak_db?schema=public",
      },
    },
  });

  try {
    await prisma.$connect();
    console.log("=== STEP 2 & 3: POSTGRES CONTRIBUTION RECEIPT GENERATION & SEQUENCE INDEPENDENCE PROOF ===");

    const orgId = "00000000-0000-4000-a000-000000000001";
    const festivalYear = 2026;
    const contributorId = "11111111-2222-3333-4444-555555555555";
    const userId = "11111111-1111-4111-a111-111111111111";

    // Ensure Organization exists
    await prisma.organization.upsert({
      where: { id: orgId },
      create: {
        id: orgId,
        name: "Shree Ganesh Utsav Mandal",
        code: "MANDAL01",
        addressLine1: "123 Mandal Path",
        city: "Pune",
        state: "Maharashtra",
        postalCode: "411001",
        ownerUserId: userId,
        status: "ACTIVE",
      },
      update: {},
    });

    // Clean up old test data
    await prisma.contributionReceipt.deleteMany({ where: { organizationId: orgId } });
    await prisma.contribution.deleteMany({ where: { organizationId: orgId } });
    await prisma.paymentReceipt.deleteMany({ where: { organizationId: orgId } });
    await prisma.sequenceCounter.deleteMany({ where: { organizationId: orgId, festivalYear } });

    // Services & Mock Context
    const tenantContext: any = { organizationId: orgId };
    const festivalYearService: any = {
      getActiveFestivalYear: async () => ({ festivalYear }),
    };
    const sequenceCounterService = new SequenceCounterService(prisma);
    const whatsappDeliveryService: any = {
      sendDocument: async () => {},
    };
    const templatesService: any = {
      resolveActiveTemplate: async () => ({ id: "00000000-0000-4000-a000-000000000002", name: "Standard Receipt Template" }),
    };
    const auditService: any = {
      log: async () => {},
    };

    const contributionsRepo = new ContributionsRepository(prisma, tenantContext);
    const contributionsService = new ContributionsService(contributionsRepo, festivalYearService, tenantContext);

    const receiptsRepo = new ContributionReceiptsRepository(prisma, tenantContext);
    const receiptsService = new ContributionReceiptsService(
      receiptsRepo,
      contributionsService,
      festivalYearService,
      sequenceCounterService,
      whatsappDeliveryService,
      templatesService,
      auditService,
      tenantContext,
    );

    // --- STEP A: Record a Real Non-Monetary Contribution ---
    console.log("\n--- STEP A: Creating Real Non-Monetary Contribution in PostgreSQL ---");
    const contribution = await contributionsService.create(
      {
        contributorId,
        contributorNameSnapshot: "Rohan Deshmukh",
        contactSnapshot: "+91 98900 12345",
        date: "2026-08-01",
        donationType: "Silver",
        itemDescription: "250g Silver Pooja Thali",
        weight: 250.0,
        estimatedValue: 20000.0,
      },
      userId,
    );

    console.log(`[POSTGRES STORED] Contribution ID: ${contribution.id}`);
    console.log(`[POSTGRES STORED] Contributor ID: ${contribution.contributorId}`);
    console.log(`[POSTGRES STORED] Contributor Name: ${contribution.contributorNameSnapshot}`);
    console.log(`[POSTGRES STORED] Donation Type: ${contribution.donationType}`);

    // --- STEP B: Auto-Generate Contribution Receipt ---
    console.log("\n--- STEP B: Auto-Generating Contribution Receipt ---");
    const receipt1 = await receiptsService.generate(contribution.id);

    console.log(`[POSTGRES STORED] Receipt ID: ${receipt1.id}`);
    console.log(`[POSTGRES STORED] Generated Contribution Receipt Number: ${receipt1.contributionReceiptNumber}`);
    console.log(`[POSTGRES STORED] WhatsApp Delivery Status: ${receipt1.whatsappDeliveryStatus}`);

    // --- STEP C: Generate Monetary Receipt & Prove Sequence Counter Independence ---
    console.log("\n--- STEP C: Proving Counter Independence Between Monetary & Contribution Receipts ---");
    const monetarySeq = await sequenceCounterService.getNextSequence(orgId, festivalYear, "receipt");
    const monetaryReceiptNumber = `RCPT-${festivalYear}-${String(monetarySeq).padStart(6, "0")}`;

    console.log(`[SEQUENCE COUNTER] Monetary Receipt Number: ${monetaryReceiptNumber}`);
    console.log(`[SEQUENCE COUNTER] Contribution Receipt Number: ${receipt1.contributionReceiptNumber}`);

    const countersInDb = await prisma.sequenceCounter.findMany({
      where: { organizationId: orgId, festivalYear },
    });
    console.log("\n[POSTGRES STORED] Sequence Counters Table Rows:");
    console.dir(countersInDb, { depth: null });

    const crcptSeqRow = countersInDb.find((c) => c.sequenceName === "contributionReceipt");
    const rcptSeqRow = countersInDb.find((c) => c.sequenceName === "receipt");

    if (crcptSeqRow && rcptSeqRow) {
      console.log(`✔ Proven Independent Counters: 'contributionReceipt' = ${crcptSeqRow.lastSequence}, 'receipt' = ${rcptSeqRow.lastSequence}`);
    } else {
      throw new Error("Failed to prove independent sequence counters in PostgreSQL");
    }

    // --- STEP D: Query Contributor's Own History ---
    console.log("\n--- STEP D: Querying Contributor History (/contribution-receipts/my-history) ---");
    const history = await receiptsService.findMyHistory(contributorId);
    console.log(`[POSTGRES STORED] History count for contributor ${contributorId}: ${history.length}`);
    console.log(`[POSTGRES STORED] History item 1 receipt number: ${history[0]?.contributionReceiptNumber}`);

    if (history.length !== 1 || history[0].id !== receipt1.id) {
      throw new Error("Contributor history query did not return exact generated contribution receipt");
    }
    console.log("✔ Contributor history query returned the exact generated contribution receipt from PostgreSQL!");

    // --- STEP E: Check Idempotency (Duplicate Generation Attempt) ---
    console.log("\n--- STEP E: Testing Idempotency of Receipt Generation ---");
    const receiptDuplicateAttempt = await receiptsService.generate(contribution.id);
    console.log(`Duplicate generation returned same receipt ID: ${receiptDuplicateAttempt.id === receipt1.id}`);

    const totalReceiptsCount = await prisma.contributionReceipt.count({
      where: { organizationId: orgId },
    });
    console.log(`[POSTGRES STORED] Total ContributionReceipt rows in DB: ${totalReceiptsCount}`);
    if (totalReceiptsCount !== 1) {
      throw new Error("Expected exactly 1 ContributionReceipt row in DB");
    }
    console.log("✔ Exactly 1 contribution receipt row exists in PostgreSQL!");

    // --- STEP F: Final PostgreSQL Output ---
    console.log("\n==================================================================");
    console.log("=== STEP 5: PROOF OF ROW & SEQUENCE INDEPENDENCE IN POSTGRES ===");
    console.log("==================================================================");

    const finalReceipt = await prisma.contributionReceipt.findUnique({
      where: { id: receipt1.id },
    });
    console.log("\n1. FINAL POSTGRES ROW IN `contribution_receipts` TABLE:");
    console.dir(finalReceipt, { depth: null });

    const finalContribution = await prisma.contribution.findUnique({
      where: { id: contribution.id },
    });
    console.log("\n2. FINAL POSTGRES ROW IN `contributions` TABLE:");
    console.dir(finalContribution, { depth: null });

    console.log("\n✅ E2E Postgres Contribution Receipt Generation Flow Proof Completed Successfully!");
  } catch (error) {
    console.error("❌ Contribution receipt proof script failed:", error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

runPostgresContributionReceiptFlowProof();
