import { PrismaClient, TemplateType, TemplateDetectionStatus } from "../../../packages/backend-database/src/generated/client";

async function main() {
  const prisma = new PrismaClient();
  try {
    console.log("=== Step 5 Proof: Postgres-backed Receipt Templates Flow ===");

    const orgId = "10000000-0000-0000-0000-000000000001";
    const userId = "20000000-0000-0000-0000-000000000001";

    // Clear prior test templates for clean evidence run
    await prisma.receiptTemplate.deleteMany({
      where: { organizationId: orgId },
    });

    console.log("\n[1/4] Creating Template v1 (Initial Active Version)...");
    const tmplV1 = await prisma.receiptTemplate.create({
      data: {
        organizationId: orgId,
        templateType: TemplateType.RECEIPT,
        version: 1,
        sourceFileUrl: "https://storage.pautipustak.org/tenants/org-1/receipt_v1.png",
        detectionStatus: TemplateDetectionStatus.AUTO_DETECTED,
        isActive: true,
        fieldMap: [
          { fieldKey: "donor_name", x: 0.2, y: 0.3, page: 1, fontSize: 12 },
          { fieldKey: "amount", x: 0.7, y: 0.4, page: 1, fontSize: 12 },
        ],
        uploadedByUserId: userId,
      },
    });
    console.log("Created Template v1:", {
      id: tmplV1.id,
      version: tmplV1.version,
      isActive: tmplV1.isActive,
      detectionStatus: tmplV1.detectionStatus,
    });

    console.log("\n[2/4] Uploading Template v2 (Pending Calibration)...");
    const tmplV2 = await prisma.receiptTemplate.create({
      data: {
        organizationId: orgId,
        templateType: TemplateType.RECEIPT,
        version: 2,
        sourceFileUrl: "https://storage.pautipustak.org/tenants/org-1/receipt_v2.png",
        detectionStatus: TemplateDetectionStatus.AUTO_DETECTED,
        isActive: false,
        fieldMap: [
          { fieldKey: "donor_name", x: 0.22, y: 0.32, page: 1, fontSize: 14 },
          { fieldKey: "amount", x: 0.75, y: 0.45, page: 1, fontSize: 14 },
          { fieldKey: "receipt_no", x: 0.75, y: 0.2, page: 1, fontSize: 12 },
        ],
        uploadedByUserId: userId,
      },
    });
    console.log("Created Template v2:", {
      id: tmplV2.id,
      version: tmplV2.version,
      isActive: tmplV2.isActive,
      detectionStatus: tmplV2.detectionStatus,
    });

    console.log("\n[3/4] Activating Template v2 via Atomic Transaction...");
    await prisma.$transaction([
      prisma.receiptTemplate.updateMany({
        where: {
          organizationId: orgId,
          templateType: TemplateType.RECEIPT,
          isActive: true,
        },
        data: { isActive: false },
      }),
      prisma.receiptTemplate.update({
        where: { id: tmplV2.id },
        data: { isActive: true },
      }),
    ]);
    console.log("Template v2 successfully activated, prior active version (v1) deactivated.");

    console.log("\n[4/4] Calibrating FieldMap Coordinates for Template v2...");
    const updatedV2 = await prisma.receiptTemplate.update({
      where: { id: tmplV2.id },
      data: {
        detectionStatus: TemplateDetectionStatus.MANUALLY_CALIBRATED,
        fieldMap: [
          { fieldKey: "donor_name", x: 0.25, y: 0.35, page: 1, fontSize: 14 },
          { fieldKey: "amount", x: 0.72, y: 0.48, page: 1, fontSize: 14 },
          { fieldKey: "receipt_no", x: 0.72, y: 0.18, page: 1, fontSize: 12 },
          { fieldKey: "signature", x: 0.65, y: 0.8, page: 1, fontSize: 10 },
        ],
      },
    });
    console.log("Updated FieldMap for Template v2:", JSON.stringify(updatedV2.fieldMap));

    console.log("\n=== Complete Real Postgres Database State ===");
    const rows = await prisma.receiptTemplate.findMany({
      where: { organizationId: orgId },
      orderBy: { version: "asc" },
    });
    console.table(
      rows.map((r) => ({
        id: r.id,
        version: r.version,
        templateType: r.templateType,
        isActive: r.isActive,
        detectionStatus: r.detectionStatus,
        sourceFileUrl: r.sourceFileUrl,
        fieldMap: JSON.stringify(r.fieldMap),
      })),
    );
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((err) => {
  console.error("Proof script failed:", err);
  process.exit(1);
});
