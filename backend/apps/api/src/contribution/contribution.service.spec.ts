/**
 * ContributionsService — Unit Tests
 *
 * Structure: GIVEN-WHEN-THEN behavioral contracts.
 * Mock source: @pauti-pustak/backend-testing (no inline mock construction).
 */
import { ConflictException, NotFoundException } from "@nestjs/common";
import {
  createMockContributionDto,
  createMockFestivalYearService,
  createMockTenantContext,
  createMockAssetStorage,
  TEST_ORG_A,
  TEST_USER_TREASURER,
} from "@pauti-pustak/backend-testing";
import { ContributionsRepository, ContributionsService } from "./contribution.service";

describe("ContributionsService", () => {
  let service: ContributionsService;
  let repository: jest.Mocked<ContributionsRepository>;
  let festivalYearService: ReturnType<typeof createMockFestivalYearService>;
  let tenantContext: ReturnType<typeof createMockTenantContext>;
  let assetStorage: ReturnType<typeof createMockAssetStorage>;

  beforeEach(() => {
    repository = {
      create: jest.fn(),
      findMany: jest.fn(),
      findOwnedUnique: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    } as any;

    festivalYearService = createMockFestivalYearService({ organizationId: TEST_ORG_A, festivalYear: 2026 });
    tenantContext = createMockTenantContext({ organizationId: TEST_ORG_A });
    assetStorage = createMockAssetStorage();

    service = new ContributionsService(
      repository,
      festivalYearService as any,
      tenantContext as any,
      assetStorage as any,
    );
  });

  describe("Record Contribution", () => {
    it("GIVEN valid contribution data WHEN create is called THEN records the contribution with status RECORDED and festival year", async () => {
      const dto = createMockContributionDto({
        contributorNameSnapshot: "Ramesh Shinde",
        donationType: "Gold",
        weight: 10.5,
        estimatedValue: 75000,
      });

      repository.create.mockResolvedValue({ id: "contrib-1", ...dto, status: "RECORDED", festivalYear: 2026 } as any);

      const result = await service.create(dto, TEST_USER_TREASURER);

      expect(festivalYearService.getActiveFestivalYear).toHaveBeenCalledWith(TEST_ORG_A);
      expect(repository.create).toHaveBeenCalledWith(
        expect.objectContaining({
          contributorNameSnapshot: "Ramesh Shinde",
          donationType: "Gold",
          weight: 10.5,
          estimatedValue: 75000,
          status: "RECORDED",
          festivalYear: 2026,
          recordedBy: TEST_USER_TREASURER,
        }),
      );
      expect(result.id).toBe("contrib-1");
    });
  });

  describe("Read Operations", () => {
    it("GIVEN existing contributions WHEN findAll is called THEN returns list ordered by createdAt desc", async () => {
      const mockList = [
        { id: "contrib-1", status: "RECORDED" },
        { id: "contrib-2", status: "RECEIPTED" },
      ];
      repository.findMany.mockResolvedValue(mockList as any);

      const results = await service.findAll();

      expect(repository.findMany).toHaveBeenCalledWith({ orderBy: { createdAt: "desc" } });
      expect(results).toHaveLength(2);
    });

    it("GIVEN a valid contribution ID WHEN findOne is called THEN returns the single record", async () => {
      repository.findOwnedUnique.mockResolvedValue({ id: "contrib-1", status: "RECORDED" } as any);

      const result = await service.findOne("contrib-1");

      expect(repository.findOwnedUnique).toHaveBeenCalledWith({ id: "contrib-1" });
      expect(result.id).toBe("contrib-1");
    });

    it("GIVEN a non-existent contribution ID WHEN findOne is called THEN throws NotFoundException", async () => {
      repository.findOwnedUnique.mockResolvedValue(null);

      await expect(service.findOne("non-existent-id")).rejects.toThrow(NotFoundException);
    });
  });

  describe("Update & Edit Lock", () => {
    it("GIVEN a RECORDED contribution WHEN update is called THEN updates mutable fields successfully", async () => {
      repository.findOwnedUnique.mockResolvedValue({
        id: "contrib-1",
        status: "RECORDED",
      } as any);
      repository.update.mockResolvedValue({ id: "contrib-1", donationType: "Silver" } as any);

      const updated = await service.update("contrib-1", { donationType: "Silver" });

      expect(repository.update).toHaveBeenCalledWith(
        { id: "contrib-1" },
        expect.objectContaining({ donationType: "Silver" }),
      );
      expect(updated.donationType).toBe("Silver");
    });

    it("GIVEN a RECEIPTED contribution WHEN update is attempted THEN throws ConflictException", async () => {
      repository.findOwnedUnique.mockResolvedValue({
        id: "contrib-1",
        status: "RECEIPTED",
      } as any);

      await expect(service.update("contrib-1", { donationType: "Silver" })).rejects.toThrow(
        ConflictException,
      );
      expect(repository.update).not.toHaveBeenCalled();
    });
  });

  describe("Delete & Immutability", () => {
    it("GIVEN a RECORDED contribution WHEN delete is called THEN removes the record", async () => {
      repository.findOwnedUnique.mockResolvedValue({
        id: "contrib-1",
        status: "RECORDED",
      } as any);
      repository.delete.mockResolvedValue({ id: "contrib-1" } as any);

      await service.delete("contrib-1");

      expect(repository.delete).toHaveBeenCalledWith({ id: "contrib-1" });
    });

    it("GIVEN a RECEIPTED contribution WHEN delete is attempted THEN throws ConflictException", async () => {
      repository.findOwnedUnique.mockResolvedValue({
        id: "contrib-1",
        status: "RECEIPTED",
      } as any);

      await expect(service.delete("contrib-1")).rejects.toThrow(ConflictException);
      expect(repository.delete).not.toHaveBeenCalled();
    });
  });

  describe("Status Transitions & Certificate Upload", () => {
    it("GIVEN a RECORDED contribution WHEN markReceipted is called THEN updates status to RECEIPTED", async () => {
      repository.update.mockResolvedValue({ id: "contrib-1", status: "RECEIPTED" } as any);

      await service.markReceipted("contrib-1");

      expect(repository.update).toHaveBeenCalledWith({ id: "contrib-1" }, { status: "RECEIPTED" });
    });

    it("GIVEN a valid file buffer WHEN uploadCertificatePhoto is called THEN uploads to asset storage", async () => {
      const mockFile = {
        originalname: "gold_cert.jpg",
        buffer: Buffer.from("test_photo_bytes"),
        mimetype: "image/jpeg",
      };

      const result = await service.uploadCertificatePhoto(mockFile, TEST_USER_TREASURER);

      expect(assetStorage.uploadAsset).toHaveBeenCalledWith(
        expect.objectContaining({
          organizationId: TEST_ORG_A,
          ownerUserId: TEST_USER_TREASURER,
          filename: "gold_cert.jpg",
        }),
      );
      expect(result.url).toBeDefined();
    });

    it("GIVEN unconfigured asset storage WHEN uploadCertificatePhoto is called THEN throws an error", async () => {
      const unconfiguredService = new ContributionsService(
        repository,
        festivalYearService as any,
        tenantContext as any,
        undefined,
      );

      const mockFile = {
        originalname: "gold_cert.jpg",
        buffer: Buffer.from("test_photo_bytes"),
        mimetype: "image/jpeg",
      };

      await expect(
        unconfiguredService.uploadCertificatePhoto(mockFile, TEST_USER_TREASURER),
      ).rejects.toThrow("AssetStorageService is not configured");
    });
  });
});
