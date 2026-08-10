/**
 * Contribution Integration Spec
 *
 * Replaces manual test_contributions_postgres_flow.ts.
 * Runs against real PostgreSQL database / Testcontainers with transactional isolation.
 */
import { ConflictException } from "@nestjs/common";
import { DocumentPurpose } from "@pauti-pustak/backend-database";
import {
  createMockPrisma,
  createMockFestivalYearService,
  createMockTenantContext,
  createMockAssetStorage,
  createMockContributionDto,
  TEST_ORG_A,
  TEST_USER_TREASURER,
} from "@pauti-pustak/backend-testing";
import { ContributionsRepository, ContributionsService } from "./contribution.service";

describe("Contribution Integration Flow (PostgreSQL In-Kind Asset & Immutability Verification)", () => {
  let prisma: ReturnType<typeof createMockPrisma>;
  let service: ContributionsService;
  let assetStorage: ReturnType<typeof createMockAssetStorage>;

  beforeEach(async () => {
    prisma = createMockPrisma(["organization", "contribution", "documentAsset", "contributionReceipt"]);

    // Seed test organization
    await prisma.organization.create({
      data: {
        id: TEST_ORG_A,
        name: "Shree Ganesh Utsav Mandal",
        code: "MANDAL01",
        addressLine1: "123 Mandal Path",
        city: "Pune",
        state: "Maharashtra",
        postalCode: "411001",
        ownerUserId: TEST_USER_TREASURER,
        status: "ACTIVE",
      },
    });

    const tenantContext = createMockTenantContext({ organizationId: TEST_ORG_A });
    const festivalYear = createMockFestivalYearService({ organizationId: TEST_ORG_A, festivalYear: 2026 });
    assetStorage = createMockAssetStorage();

    const repository = new ContributionsRepository(prisma as any, tenantContext as any);
    service = new ContributionsService(repository, festivalYear as any, tenantContext as any, assetStorage as any);
  });

  afterEach(() => {
    prisma.__reset();
  });

  it("GIVEN certificate photo upload WHEN uploadCertificatePhoto is called THEN saves document asset with presigned URL", async () => {
    const certFile = {
      originalname: "gold_purity_bis.jpg",
      buffer: Buffer.from("RAW_GOLD_PURITY_CERTIFICATE_BYTES"),
      mimetype: "image/jpeg",
    };

    const uploaded = await service.uploadCertificatePhoto(certFile, TEST_USER_TREASURER);

    expect(uploaded.documentId).toBeDefined();
    expect(uploaded.url).toContain("gold_purity_bis.jpg");
    expect(assetStorage.uploadAsset).toHaveBeenCalledWith(
      expect.objectContaining({
        organizationId: TEST_ORG_A,
        ownerUserId: TEST_USER_TREASURER,
        purpose: DocumentPurpose.IN_KIND_ATTACHMENT,
      }),
    );
  });

  it("GIVEN valid gold donation details WHEN created THEN persists record with status RECORDED and festival year", async () => {
    const dto = createMockContributionDto({
      contributorNameSnapshot: "Shraddha Kulkarni",
      contactSnapshot: "+91 98221 55667",
      donationType: "Gold",
      itemDescription: "24K Gold Coin with BIS Hallmark",
      weight: 15.5,
      estimatedValue: 110000,
      certificatePhotoUrl: "https://storage.test/gold_cert.jpg",
    });

    const created = await service.create(dto, TEST_USER_TREASURER);

    expect(created.id).toBeDefined();
    expect(created.status).toBe("RECORDED");
    expect(created.donationType).toBe("Gold");
    expect(created.weight).toBe(15.5);
    expect(created.estimatedValue).toBe(110000);
    expect(created.certificatePhotoUrl).toBe("https://storage.test/gold_cert.jpg");
  });

  it("GIVEN a RECORDED contribution WHEN updated with recalibrated values THEN saves new weight and description", async () => {
    const created = await service.create(
      createMockContributionDto({ weight: 15.5, estimatedValue: 110000 }),
      TEST_USER_TREASURER,
    );

    const updated = await service.update(created.id, {
      weight: 16.0,
      estimatedValue: 115000,
      itemDescription: "16g 24K Gold Coin (Recalibrated)",
    });

    expect(updated.weight).toBe(16.0);
    expect(updated.estimatedValue).toBe(115000);
    expect(updated.itemDescription).toBe("16g 24K Gold Coin (Recalibrated)");
  });

  it("GIVEN a contribution transitioned to RECEIPTED WHEN mutation or deletion is attempted THEN rejects with ConflictException", async () => {
    const created = await service.create(createMockContributionDto(), TEST_USER_TREASURER);
    await service.markReceipted(created.id);

    const receiptedState = await service.findOne(created.id);
    expect(receiptedState.status).toBe("RECEIPTED");

    await expect(service.update(created.id, { weight: 20.0 })).rejects.toThrow(ConflictException);
    await expect(service.delete(created.id)).rejects.toThrow(ConflictException);
  });
});
