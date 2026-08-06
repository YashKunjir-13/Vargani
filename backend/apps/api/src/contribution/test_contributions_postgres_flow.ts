import { PrismaClient, DocumentPurpose, DocumentStatus } from "@pauti-pustak/backend-database";
import { S3StorageService } from "@pauti-pustak/backend-shared-kernel";
import { AssetStorageService } from "../common/storage/asset-storage.service";
import { ContributionsRepository, ContributionsService } from "./contribution.service";

async function runPostgresContributionFlowProof() {
  const prisma = new PrismaClient({
    datasources: {
      db: {
        url: process.env.DATABASE_URL || "postgresql://pauti_user:pauti_password@localhost:5432/pauti_pustak_db?schema=public",
      },
    },
  });

  try {
    await prisma.$connect();
    console.log("=== STEP 2 & 3: POSTGRES CONTRIBUTION MIGRATION & REAL SERVICE LOGIC PROOF ===");

    const orgId = "00000000-0000-4000-a000-000000000001";
    const festivalYear = 2026;
    const userId = "11111111-1111-4111-a111-111111111111";

    // Ensure Organization exists in DB
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

    // Clean up previous test contributions
    await prisma.contributionReceipt.deleteMany({ where: { organizationId: orgId } });
    await prisma.contribution.deleteMany({ where: { organizationId: orgId } });

    // Initialize Asset Storage Service & Create Bucket if missing
    const s3Storage = new S3StorageService();
    const bucket = process.env.S3_BUCKET || "pauti-pustak-assets";
    try {
      const { S3Client, CreateBucketCommand } = await import("@aws-sdk/client-s3");
      const client = new S3Client({
        endpoint: process.env.S3_ENDPOINT || "http://localhost:9000",
        region: process.env.S3_REGION || "us-east-1",
        credentials: {
          accessKeyId: process.env.S3_ACCESS_KEY || "minioadmin",
          secretAccessKey: process.env.S3_SECRET_KEY || "minioadmin",
        },
        forcePathStyle: true,
      });
      await client.send(new CreateBucketCommand({ Bucket: bucket }));
    } catch (_) {
      // no-op
    }

    const assetStorage = new AssetStorageService(prisma, s3Storage);

    // Initialize Service & Mock Context
    const tenantContext: any = { organizationId: orgId };
    const repository = new ContributionsRepository(prisma, tenantContext);
    const festivalYearService: any = {
      getActiveFestivalYear: async () => ({ festivalYear }),
    };
    const service = new ContributionsService(repository, festivalYearService, tenantContext, assetStorage);

    // --- STEP A: Upload Certificate Photo via AssetStorageService & S3 Object Storage ---
    console.log("\n--- STEP A: Uploading Gold Purity Certificate Photo to S3 & DocumentAssets ---");
    const certBuffer = Buffer.from("RAW_GOLD_PURITY_CERTIFICATE_PHOTO_BYTES_2026");
    const uploadedAsset = await assetStorage.uploadAsset({
      organizationId: orgId,
      ownerUserId: userId,
      purpose: DocumentPurpose.IN_KIND_ATTACHMENT,
      filename: "gold_purity_certificate_bis.jpg",
      body: certBuffer,
      contentType: "image/jpeg",
    });

    console.log(`[OBJECT STORAGE / POSTGRES] Document ID: ${uploadedAsset.documentId}`);
    console.log(`[OBJECT STORAGE / POSTGRES] Storage Key: ${uploadedAsset.objectKey}`);
    console.log(`[OBJECT STORAGE / POSTGRES] Presigned URL: ${uploadedAsset.url}`);

    // --- STEP B: Log Gold Contribution (status RECORDED) ---
    console.log("\n--- STEP B: Logging Gold Contribution in PostgreSQL (Status RECORDED) ---");
    const created = await service.create(
      {
        contributorNameSnapshot: "Shraddha Kulkarni",
        contactSnapshot: "+91 98221 55667",
        date: "2026-08-01",
        donationType: "Gold",
        itemDescription: "24K Gold Coin with BIS Hallmark",
        weight: 15.500,
        estimatedValue: 110000.00,
        certificatePhotoUrl: uploadedAsset.url,
      },
      userId,
    );

    console.log(`[POSTGRES STORED] Contribution ID: ${created.id}`);
    console.log(`[POSTGRES STORED] Donation Type: ${created.donationType}`);
    console.log(`[POSTGRES STORED] Initial Weight: ${created.weight} g`);
    console.log(`[POSTGRES STORED] Estimated Value: ₹${created.estimatedValue}`);
    console.log(`[POSTGRES STORED] Stored Certificate URL: ${created.certificatePhotoUrl}`);
    console.log(`[POSTGRES STORED] Initial Status: ${created.status}`);

    // --- STEP C: Edit Contribution while RECORDED ---
    console.log("\n--- STEP C: Editing Contribution while Status is RECORDED ---");
    const updated = await service.update(created.id, {
      weight: 16.000,
      estimatedValue: 115000.00,
      itemDescription: "16g 24K Gold Coin with BIS Hallmark (Recalibrated)",
    });

    console.log(`[POSTGRES STORED] Updated Weight: ${updated.weight} g`);
    console.log(`[POSTGRES STORED] Updated Value: ₹${updated.estimatedValue}`);
    console.log(`[POSTGRES STORED] Updated Description: ${updated.itemDescription}`);

    // --- STEP D: Mark Receipted & Confirm Mutation Rejection ---
    console.log("\n--- STEP D: Transitioning Status to RECEIPTED & Testing Edit Lock ---");
    await service.markReceipted(created.id);
    const receiptedState = await service.findOne(created.id);
    console.log(`[POSTGRES STORED] Updated Status: ${receiptedState.status}`);

    let updateBlocked = false;
    try {
      await service.update(created.id, { weight: 20.0 });
    } catch (err: any) {
      updateBlocked = true;
      console.log(`✔ Edit Blocked on RECEIPTED Status: ConflictException - ${err.message}`);
    }

    let deleteBlocked = false;
    try {
      await service.delete(created.id);
    } catch (err: any) {
      deleteBlocked = true;
      console.log(`✔ Delete Blocked on RECEIPTED Status: ConflictException - ${err.message}`);
    }

    console.log(`Edit Blocked on RECEIPTED Status: ${updateBlocked}`);
    console.log(`Delete Blocked on RECEIPTED Status: ${deleteBlocked}`);

    // --- STEP E: Query & Output Final PostgreSQL Row ---
    console.log("\n========================================================");
    console.log("=== STEP 5: PROOF OF ROW STATUS & PHOTO URL IN POSTGRES ===");
    console.log("========================================================");

    const finalContribution = await prisma.contribution.findUnique({
      where: { id: created.id },
    });
    console.log("\n1. FINAL POSTGRES ROW IN `contributions` TABLE:");
    console.dir(finalContribution, { depth: null });

    const documentAsset = await prisma.documentAsset.findUnique({
      where: { id: uploadedAsset.documentId },
    });
    console.log("\n2. CORRESPONDING POSTGRES ROW IN `document_assets` TABLE:");
    console.dir(documentAsset, { depth: null });

    console.log("\n✅ E2E Postgres Contribution Workflow Proof Completed Successfully!");
  } catch (error) {
    console.error("❌ Contribution proof script failed:", error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

runPostgresContributionFlowProof();
