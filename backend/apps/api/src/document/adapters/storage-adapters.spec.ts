import { MinioStorageAdapter } from "./minio-storage.adapter";
import { LocalStorageAdapter } from "./local-storage.adapter";

describe("Storage Adapters Unit Tests", () => {
  describe("MinioStorageAdapter", () => {
    let minio: MinioStorageAdapter;

    beforeEach(() => {
      minio = new MinioStorageAdapter();
    });

    it("generates MinIO upload URL containing minio bucket and port", async () => {
      const url = await minio.getUploadUrl("orgs/org-1/logo.png", "image/png", 900);
      expect(url).toContain("9000");
      expect(url).toContain("pauti-pustak-minio");
      expect(url).toContain("orgs/org-1/logo.png");
    });

    it("generates MinIO download URL", async () => {
      const url = await minio.getDownloadUrl("orgs/org-1/logo.png", 900);
      expect(url).toContain("http://localhost:9000/pauti-pustak-minio/orgs/org-1/logo.png");
    });
  });

  describe("LocalStorageAdapter", () => {
    let local: LocalStorageAdapter;

    beforeEach(() => {
      local = new LocalStorageAdapter();
    });

    it("generates local stream download URL", async () => {
      const url = await local.getDownloadUrl("orgs/org-1/receipt.pdf", 900);
      expect(url).toContain("/api/v1/documents/local-stream?key=");
      expect(url).toContain("orgs%2Forg-1%2Freceipt.pdf");
    });
  });
});
