import { Test, TestingModule } from "@nestjs/testing";
import { DocumentPurpose, DocumentStatus, PrismaService } from "@pauti-pustak/backend-database";
import { BadRequestException } from "@nestjs/common";
import { DocumentService } from "./document.service";

describe("DocumentService (Phase 5 Unit Tests)", () => {
  let service: DocumentService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      documentAsset: {
        create: jest.fn(),
        findFirst: jest.fn(),
        update: jest.fn(),
        findMany: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DocumentService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get<DocumentService>(DocumentService);
  });

  describe("Presigned Upload & Duplicate Detection", () => {
    it("generates S3 presigned upload URL for valid MIME type", async () => {
      prisma.documentAsset.create.mockResolvedValue({
        id: "doc-123",
        status: DocumentStatus.UPLOAD_PENDING,
      });

      const res = await service.createPresignedUpload("org-1", "user-1", {
        filename: "receipt.pdf",
        contentType: "application/pdf",
        purpose: DocumentPurpose.RECEIPT_PDF,
      });

      expect(res.documentId).toBe("doc-123");
      expect(res.uploadUrl).toContain("pauti-pustak-storage");
      expect(res.isDuplicate).toBe(false);
    });

    it("detects duplicate upload by sha256 checksum match", async () => {
      prisma.documentAsset.findFirst.mockResolvedValue({
        id: "doc-existing",
        objectKey: "orgs/org-1/receipt_pdf/doc-existing-receipt.pdf",
        status: DocumentStatus.AVAILABLE,
      });

      const res = await service.createPresignedUpload("org-1", "user-1", {
        filename: "receipt.pdf",
        contentType: "application/pdf",
        purpose: DocumentPurpose.RECEIPT_PDF,
        sha256: "checksum123",
      });

      expect(res.isDuplicate).toBe(true);
      expect(res.documentId).toBe("doc-existing");
    });

    it("rejects presigned upload request for unsupported MIME type", async () => {
      await expect(
        service.createPresignedUpload("org-1", "user-1", {
          filename: "malware.exe",
          contentType: "application/x-msdownload",
          purpose: DocumentPurpose.RECEIPT_PDF,
        }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe("Upload Confirmation & Lifecycle", () => {
    it("confirms document upload with actual file size and sha256", async () => {
      prisma.documentAsset.findFirst.mockResolvedValue({ id: "doc-1", organizationId: "org-1" });
      prisma.documentAsset.update.mockResolvedValue({
        id: "doc-1",
        status: DocumentStatus.AVAILABLE,
        fileSizeBytes: BigInt(50000),
        sha256: "hash123",
      });

      const res = await service.confirmUpload("org-1", "doc-1", { fileSizeBytes: "50000", sha256: "hash123" });
      expect(res.status).toBe(DocumentStatus.AVAILABLE);
      expect(res.fileSizeBytes).toBe("50000");
    });

    it("returns inline preview metadata for images and PDFs", async () => {
      prisma.documentAsset.findFirst.mockResolvedValue({
        id: "doc-1",
        organizationId: "org-1",
        mimeType: "image/png",
        originalFileName: "logo.png",
        fileSizeBytes: BigInt(1024),
        objectKey: "key-1",
        status: DocumentStatus.AVAILABLE,
      });

      const res = await service.previewDocument("org-1", "doc-1");
      expect(res.isImage).toBe(true);
      expect(res.isPdf).toBe(false);
      expect(res.previewUrl).toBeDefined();
    });

    it("replaces document asset and archives previous version", async () => {
      prisma.documentAsset.findFirst.mockResolvedValue({ id: "doc-1", organizationId: "org-1", purpose: DocumentPurpose.ORGANIZATION_STAMP });
      prisma.documentAsset.update.mockResolvedValue({});
      prisma.documentAsset.create.mockResolvedValue({ id: "doc-2" });

      const res = await service.replaceDocument("org-1", "doc-1", "user-1", {
        filename: "stamp_v2.png",
        contentType: "image/png",
        reason: "Updated mandal seal",
      });

      expect(res.previousDocumentId).toBe("doc-1");
      expect(res.newDocumentId).toBe("doc-2");
    });

    it("returns organization storage stats", async () => {
      prisma.documentAsset.findMany.mockResolvedValue([
        { purpose: "ORGANIZATION_STAMP", fileSizeBytes: BigInt(10000), status: "AVAILABLE" },
      ]);

      const stats = await service.getDocumentStats("org-1");
      expect(stats.availableDocumentsCount).toBe(1);
      expect(stats.totalStorageBytes).toBe("10000");
    });
  });
});
