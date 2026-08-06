import { ForbiddenException, NotFoundException } from "@nestjs/common";
import { TemplatesService } from "./templates.service";
import { FieldDetectionEngine } from "./field-detection.engine";

const ORG_ID = "org-1";
const OTHER_ORG_ID = "org-2";
const RECEIPT = "RECEIPT" as any;

function flushMicrotasks(): Promise<void> {
  return new Promise((resolve) => setImmediate(resolve));
}

function buildPrismaMock() {
  const templates = new Map<string, any>();
  const receipts: Array<{ organizationId: string; templateVersion: string }> = [];
  let idCounter = 0;

  const receiptTemplate = {
    create: jest.fn(({ data }: any) => {
      idCounter += 1;
      const row = { id: `template-${idCounter}`, createdAt: new Date(), updatedAt: new Date(), ...data };
      templates.set(row.id, row);
      return Promise.resolve({ ...row });
    }),
    findUnique: jest.fn(({ where }: any) => Promise.resolve(templates.get(where.id) ?? null)),
    findFirst: jest.fn(({ where }: any) =>
      Promise.resolve(
        [...templates.values()].find(
          (t) =>
            t.organizationId === where.organizationId &&
            t.templateType === where.templateType &&
            (where.isActive === undefined || t.isActive === where.isActive),
        ) ?? null,
      ),
    ),
    findMany: jest.fn(({ where }: any) =>
      Promise.resolve(
        [...templates.values()].filter(
          (t) => t.organizationId === where.organizationId && (!where.templateType || t.templateType === where.templateType),
        ),
      ),
    ),
    update: jest.fn(({ where, data }: any) => {
      const row = { ...templates.get(where.id), ...data };
      templates.set(where.id, row);
      return Promise.resolve(row);
    }),
    updateMany: jest.fn(({ where, data }: any) => {
      let count = 0;
      for (const row of templates.values()) {
        if (
          row.organizationId === where.organizationId &&
          row.templateType === where.templateType &&
          row.isActive === where.isActive
        ) {
          Object.assign(row, data);
          count += 1;
        }
      }
      return Promise.resolve({ count });
    }),
    delete: jest.fn(({ where }: any) => {
      templates.delete(where.id);
      return Promise.resolve(undefined);
    }),
  };

  const receipt = {
    count: jest.fn(({ where }: any) =>
      Promise.resolve(
        receipts.filter((r) => r.organizationId === where.organizationId && r.templateVersion === where.templateVersion)
          .length,
      ),
    ),
  };

  return {
    receiptTemplate,
    receipt,
    $transaction: jest.fn((ops: Promise<any>[]) => Promise.all(ops)),
    __receipts: receipts,
  };
}

function buildAssetStorageMock() {
  let counter = 0;
  return {
    uploadAsset: jest.fn(() => {
      counter += 1;
      return Promise.resolve({
        documentId: `doc-${counter}`,
        objectKey: `tenants/${ORG_ID}/design-${counter}.png`,
        url: `https://signed.example/design-${counter}.png`,
      });
    }),
  };
}

function buildSequenceCounterMock() {
  let counter = 0;
  return {
    getNextSequence: jest.fn(() => Promise.resolve(BigInt(++counter))),
  };
}

function alwaysSucceedsEngine(fields: any[]): FieldDetectionEngine {
  return { detect: jest.fn(() => Promise.resolve({ status: "AutoDetected", fields })) };
}

function neverResolvesEngine(): FieldDetectionEngine {
  return { detect: jest.fn(() => new Promise(() => {})) };
}

function uploadParams(overrides: Partial<Record<string, any>> = {}) {
  return {
    organizationId: ORG_ID,
    uploadedByUserId: "user-1",
    filename: "receipt-design.png",
    contentType: "image/png",
    body: Buffer.from("fake-image-bytes"),
    ...overrides,
  };
}

const DONOR_FIELD = { fieldKey: "donorName", page: 1, x: 0.2, y: 0.3, confidence: 0.92 };

function buildService(detectionEngine: FieldDetectionEngine = neverResolvesEngine()) {
  const prisma = buildPrismaMock();
  const assetStorage = buildAssetStorageMock();
  const sequenceCounter = buildSequenceCounterMock();
  const service = new TemplatesService(prisma as any, assetStorage as any, sequenceCounter as any, detectionEngine);
  return { service, prisma };
}

describe("TemplatesService - versioning & activation", () => {
  it("activating a version flips isActive:false on the prior active version of the same templateType", async () => {
    const { service } = buildService(alwaysSucceedsEngine([DONOR_FIELD]));

    const v1 = await service.uploadReceiptTemplate(uploadParams());
    await flushMicrotasks();
    await service.activate(ORG_ID, v1.id);

    const v2 = await service.uploadReceiptTemplate(uploadParams());
    await flushMicrotasks();
    await service.activate(ORG_ID, v2.id);

    const reloadedV1 = await service.getById(ORG_ID, v1.id);
    const reloadedV2 = await service.getById(ORG_ID, v2.id);

    expect(reloadedV1.isActive).toBe(false);
    expect(reloadedV2.isActive).toBe(true);
  });

  it("keeps only one active version per templateType even across three activations", async () => {
    const { service } = buildService(alwaysSucceedsEngine([DONOR_FIELD]));

    const v1 = await service.uploadReceiptTemplate(uploadParams());
    await flushMicrotasks();
    await service.activate(ORG_ID, v1.id);

    const v2 = await service.uploadReceiptTemplate(uploadParams());
    await flushMicrotasks();
    await service.activate(ORG_ID, v2.id);

    const v3 = await service.uploadReceiptTemplate(uploadParams());
    await flushMicrotasks();
    await service.activate(ORG_ID, v3.id);

    const all = await service.list(ORG_ID, RECEIPT);
    const activeOnes = all.filter((t: any) => t.isActive);
    expect(activeOnes).toHaveLength(1);
    expect(activeOnes[0].id).toBe(v3.id);
  });
});

describe("TemplatesService - detection lifecycle", () => {
  it("transitions Pending -> AutoDetected once the detection engine resolves with fields", async () => {
    const { service } = buildService(alwaysSucceedsEngine([DONOR_FIELD, { fieldKey: "amount", x: 0.7, y: 0.3, confidence: 0.4 }]));

    const created = await service.uploadReceiptTemplate(uploadParams());
    expect(created.detectionStatus).toBe("PENDING");

    await flushMicrotasks();

    const reloaded = await service.getById(ORG_ID, created.id);
    expect(reloaded.detectionStatus).toBe("AUTO_DETECTED");
    expect(reloaded.fieldMap).toEqual([
      { fieldKey: "donorName", page: 1, x: 0.2, y: 0.3, fontSize: 12, detectionConfidence: 0.92 },
      { fieldKey: "amount", page: 1, x: 0.7, y: 0.3, fontSize: 12, detectionConfidence: 0.4 },
    ]);
  });

  it("transitions to Failed when the detection engine reports an explicit failure", async () => {
    const engine: FieldDetectionEngine = { detect: jest.fn(() => Promise.resolve({ status: "Failed", fields: [] })) };
    const { service } = buildService(engine);

    const created = await service.uploadReceiptTemplate(uploadParams());
    await flushMicrotasks();

    const reloaded = await service.getById(ORG_ID, created.id);
    expect(reloaded.detectionStatus).toBe("FAILED");
  });

  it("transitions to Failed when the detection engine throws (corrupt/unreadable file)", async () => {
    const engine: FieldDetectionEngine = { detect: jest.fn(() => Promise.reject(new Error("corrupt file"))) };
    const { service } = buildService(engine);

    const created = await service.uploadReceiptTemplate(uploadParams());
    await flushMicrotasks();

    const reloaded = await service.getById(ORG_ID, created.id);
    expect(reloaded.detectionStatus).toBe("FAILED");
  });
});

describe("TemplatesService - activation gating", () => {
  it("rejects activation of a template with detectionStatus Failed", async () => {
    const { service } = buildService();
    const template = await service.uploadReceiptTemplate(uploadParams());
    await service.applyDetectionResult(template.id, { status: "Failed", fields: [] });

    await expect(service.activate(ORG_ID, template.id)).rejects.toBeInstanceOf(ForbiddenException);
  });

  it("rejects activation while detection is still Pending", async () => {
    const { service } = buildService();
    const template = await service.uploadReceiptTemplate(uploadParams());

    await expect(service.activate(ORG_ID, template.id)).rejects.toBeInstanceOf(ForbiddenException);
  });

  it("allows activation once a Failed template has been manually calibrated", async () => {
    const { service } = buildService();
    const template = await service.uploadReceiptTemplate(uploadParams());
    await service.applyDetectionResult(template.id, { status: "Failed", fields: [] });

    await service.calibrateFieldMap(ORG_ID, template.id, [{ fieldKey: "amount", x: 0.5, y: 0.5 }]);

    const activated = await service.activate(ORG_ID, template.id);
    expect(activated.isActive).toBe(true);
    expect(activated.detectionStatus).toBe("MANUALLY_CALIBRATED");
  });
});

describe("TemplatesService - Historic Rendering Lock", () => {
  it("issue against v1, activate v2, reload the original receipt reference and assert it still resolves to v1's fieldMap/sourceFileUrl", async () => {
    const { service } = buildService(alwaysSucceedsEngine([DONOR_FIELD]));

    const v1 = await service.uploadReceiptTemplate(uploadParams({ filename: "design-v1.png" }));
    await flushMicrotasks();
    await service.activate(ORG_ID, v1.id);
    const v1AfterActivation = await service.getById(ORG_ID, v1.id);

    // A receipt issued right now snapshots v1's id -- the actual Receipt
    // record lives in another module; this test only exercises the
    // snapshot lookup this module is responsible for.
    const issuedReceiptTemplateVersionId = v1AfterActivation.id;

    const v2 = await service.uploadReceiptTemplate(uploadParams({ filename: "design-v2.png" }));
    await flushMicrotasks();
    await service.activate(ORG_ID, v2.id);

    // v2 is now the org's active template...
    const active = await service.resolveActiveTemplate(ORG_ID, RECEIPT);
    expect(active).not.toBeNull();
    expect(active!.id).toBe(v2.id);
    expect(active!.id).not.toBe(v1.id);

    // ...but the previously issued receipt's pinned snapshot must still
    // resolve to v1, unaffected by v2's activation.
    const snapshot = await service.getSnapshotByVersionId(issuedReceiptTemplateVersionId);
    expect(snapshot.id).toBe(v1.id);
    expect(snapshot.sourceFileUrl).toBe(v1AfterActivation.sourceFileUrl);
    expect(snapshot.fieldMap).toEqual(v1AfterActivation.fieldMap);
    expect(snapshot.isActive).toBe(false);
  });
});

describe("TemplatesService - system default fallback", () => {
  it("resolves to null (system default, no error) when the organization has never activated a personalized template", async () => {
    const { service } = buildService();

    await expect(service.resolveActiveTemplate(OTHER_ORG_ID, RECEIPT)).resolves.toBeNull();
  });
});

describe("TemplatesService - delete guard", () => {
  it("refuses to delete a template version already used to issue a receipt", async () => {
    const { service, prisma } = buildService();
    const template = await service.uploadReceiptTemplate(uploadParams());
    prisma.__receipts.push({ organizationId: ORG_ID, templateVersion: template.id });

    await expect(service.delete(ORG_ID, template.id)).rejects.toBeInstanceOf(ForbiddenException);
  });

  it("allows deleting a template version never used by any receipt", async () => {
    const { service } = buildService();
    const template = await service.uploadReceiptTemplate(uploadParams());

    await service.delete(ORG_ID, template.id);

    await expect(service.getById(ORG_ID, template.id)).rejects.toBeInstanceOf(NotFoundException);
  });
});
