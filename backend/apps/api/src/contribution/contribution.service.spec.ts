import { ConflictException } from "@nestjs/common";
import { ContributionsRepository, ContributionsService } from "./contribution.service";

describe("ContributionsService", () => {
  let service: ContributionsService;
  let repository: jest.Mocked<ContributionsRepository>;
  let festivalYearService: any;
  let tenantContext: any;

  beforeEach(() => {
    repository = {
      create: jest.fn(),
      findMany: jest.fn(),
      findOwnedUnique: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    } as any;

    festivalYearService = {
      getActiveFestivalYear: jest.fn().mockResolvedValue({ festivalYear: 2026 }),
    };

    tenantContext = {
      organizationId: "org-1",
    };

    service = new ContributionsService(repository, festivalYearService, tenantContext);
  });

  it("should record a new contribution", async () => {
    const dto = {
      contributorNameSnapshot: "Ramesh Shinde",
      date: "2026-08-01",
      donationType: "Gold",
      weight: 10.5,
      estimatedValue: 75000,
    };

    repository.create.mockResolvedValue({ id: "contrib-1", ...dto, status: "RECORDED" } as any);

    const result = await service.create(dto, "user-1");

    expect(festivalYearService.getActiveFestivalYear).toHaveBeenCalledWith("org-1");
    expect(repository.create).toHaveBeenCalledWith(
      expect.objectContaining({
        contributorNameSnapshot: "Ramesh Shinde",
        donationType: "Gold",
        weight: 10.5,
        status: "RECORDED",
      }),
    );
    expect(result.id).toBe("contrib-1");
  });

  it("should edit a RECORDED contribution", async () => {
    repository.findOwnedUnique.mockResolvedValue({
      id: "contrib-1",
      status: "RECORDED",
    } as any);
    repository.update.mockResolvedValue({ id: "contrib-1", donationType: "Silver" } as any);

    const updated = await service.update("contrib-1", { donationType: "Silver" });
    expect(repository.update).toHaveBeenCalled();
    expect(updated.donationType).toBe("Silver");
  });

  it("should reject update if status is RECEIPTED", async () => {
    repository.findOwnedUnique.mockResolvedValue({
      id: "contrib-1",
      status: "RECEIPTED",
    } as any);

    await expect(service.update("contrib-1", { donationType: "Silver" })).rejects.toThrow(
      ConflictException,
    );
  });

  it("should delete a RECORDED contribution", async () => {
    repository.findOwnedUnique.mockResolvedValue({
      id: "contrib-1",
      status: "RECORDED",
    } as any);

    await service.delete("contrib-1");
    expect(repository.delete).toHaveBeenCalledWith({ id: "contrib-1" });
  });

  it("should reject delete if status is RECEIPTED", async () => {
    repository.findOwnedUnique.mockResolvedValue({
      id: "contrib-1",
      status: "RECEIPTED",
    } as any);

    await expect(service.delete("contrib-1")).rejects.toThrow(ConflictException);
  });
});
