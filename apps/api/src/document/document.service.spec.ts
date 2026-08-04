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

  describe("Presigned Upload & Download URLs", () => {
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
});
