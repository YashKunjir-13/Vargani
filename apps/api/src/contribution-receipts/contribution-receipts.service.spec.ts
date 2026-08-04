import { ConflictException } from "@nestjs/common";
import {
  ContributionReceiptsRepository,
  ContributionReceiptsService,
} from "./contribution-receipts.service";

describe("ContributionReceiptsService", () => {
  let service: ContributionReceiptsService;
  let repository: jest.Mocked<ContributionReceiptsRepository>;
  let contributionsService: any;
  let festivalYearService: any;
  let sequenceCounterService: any;
  let whatsappDeliveryService: any;
  let templatesService: any;
  let auditService: any;
  let tenantContext: any;

  beforeEach(() => {
    repository = {
      create: jest.fn(),
      findMany: jest.fn(),
      findOwnedUnique: jest.fn(),
      findFirst: jest.fn(),
      update: jest.fn(),
    } as any;

    contributionsService = {
      findOne: jest.fn(),
      markReceipted: jest.fn(),
    };

    festivalYearService = {
      getActiveFestivalYear: jest.fn().mockResolvedValue({ festivalYear: 2026 }),
    };

    sequenceCounterService = {
      getNextSequence: jest.fn().mockResolvedValue(BigInt(1)),
    };

    whatsappDeliveryService = {
      sendDocument: jest.fn().mockResolvedValue({ deliveryId: "del-1" }),
    };

    templatesService = {
      resolveActiveTemplate: jest.fn().mockResolvedValue({ id: "tpl-v1" }),
    };

    auditService = {
      log: jest.fn().mockResolvedValue(undefined),
    };

    tenantContext = {
      organizationId: "org-1",
    };

    service = new ContributionReceiptsService(
      repository,
      contributionsService,
      festivalYearService,
      sequenceCounterService,
      whatsappDeliveryService,
      templatesService,
      auditService,
      tenantContext,
    );
  });

  it("should auto-generate contribution receipt with independent sequence", async () => {
    contributionsService.findOne.mockResolvedValue({
      id: "contrib-1",
      organizationId: "org-1",
      contributorNameSnapshot: "Suresh Patil",
      contactSnapshot: "+919876543210",
      donationType: "Gold",
    });

    repository.findFirst.mockResolvedValue(null);
    repository.create.mockResolvedValue({
      id: "receipt-c1",
      contributionReceiptNumber: "CRECEPT-2026-000001",
      status: "ACTIVE",
    } as any);

    const receipt = await service.generate("contrib-1");

    expect(sequenceCounterService.getNextSequence).toHaveBeenCalledWith(
      "org-1",
      2026,
      "contributionReceipt",
    );
    expect(repository.create).toHaveBeenCalledWith(
      expect.objectContaining({
        contributionReceiptNumber: "CRECEPT-2026-000001",
        templateVersionId: "tpl-v1",
      }),
    );
    expect(contributionsService.markReceipted).toHaveBeenCalledWith("contrib-1");
    expect(receipt.id).toBe("receipt-c1");
  });

  it("should void a contribution receipt with audit log", async () => {
    repository.findOwnedUnique.mockResolvedValue({
      id: "receipt-c1",
      status: "ACTIVE",
    } as any);
    repository.update.mockResolvedValue({
      id: "receipt-c1",
      status: "VOIDED",
      voidReason: "Data entry error",
    } as any);

    const voided = await service.voidReceipt("receipt-c1", "Data entry error", "actor-1");

    expect(repository.update).toHaveBeenCalledWith(
      { id: "receipt-c1" },
      expect.objectContaining({
        status: "VOIDED",
        voidReason: "Data entry error",
      }),
    );
    expect(auditService.log).toHaveBeenCalledWith({
      actorId: "actor-1",
      action: "VOID_CONTRIBUTION_RECEIPT",
      targetTable: "contribution_receipts",
      targetId: "receipt-c1",
      reason: "Data entry error",
    });
    expect(voided.status).toBe("VOIDED");
  });

  it("should reject voiding an already voided receipt", async () => {
    repository.findOwnedUnique.mockResolvedValue({
      id: "receipt-c1",
      status: "VOIDED",
    } as any);

    await expect(
      service.voidReceipt("receipt-c1", "Duplicate attempt", "actor-1"),
    ).rejects.toThrow(ConflictException);
  });
});
