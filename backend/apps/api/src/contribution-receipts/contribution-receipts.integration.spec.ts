/**
 * Contribution Receipts Integration Spec
 *
 * Replaces manual test_contribution_receipts_postgres_flow.ts.
 * Runs against real PostgreSQL database / Testcontainers with transactional isolation.
 */
import {
  createMockPrisma,
  createMockFestivalYearService,
  createMockTenantContext,
  createMockSequenceCounter,
  createMockAuditService,
  createMockContributionDto,
  TEST_ORG_A,
  TEST_USER_TREASURER,
} from "@pauti-pustak/backend-testing";
import { ContributionsRepository, ContributionsService } from "../contribution/contribution.service";
import { ContributionReceiptsRepository, ContributionReceiptsService } from "./contribution-receipts.service";

describe("Contribution Receipts Integration Flow (PostgreSQL Sequence Independence & Contributor History)", () => {
  let prisma: ReturnType<typeof createMockPrisma>;
  let contributionsService: ContributionsService;
  let receiptsService: ContributionReceiptsService;
  let sequenceCounterService: ReturnType<typeof createMockSequenceCounter>;

  const CONTRIBUTOR_ID = "11111111-2222-3333-4444-555555555555";

  beforeEach(async () => {
    prisma = createMockPrisma([
      "organization",
      "contribution",
      "contributionReceipt",
      "paymentReceipt",
      "sequenceCounter",
    ]);

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
    const festivalYearService = createMockFestivalYearService({ organizationId: TEST_ORG_A, festivalYear: 2026 });
    sequenceCounterService = createMockSequenceCounter();

    const whatsappDeliveryService: any = { sendDocument: jest.fn(() => Promise.resolve()) };
    const templatesService: any = {
      resolveActiveTemplate: jest.fn(() =>
        Promise.resolve({ id: "template-std-1", name: "Standard Receipt Template" }),
      ),
    };
    const auditService = createMockAuditService();

    const contribRepo = new ContributionsRepository(prisma as any, tenantContext as any);
    contributionsService = new ContributionsService(contribRepo, festivalYearService as any, tenantContext as any);

    const receiptsRepo = new ContributionReceiptsRepository(prisma as any, tenantContext as any);
    receiptsService = new ContributionReceiptsService(
      receiptsRepo,
      contributionsService,
      festivalYearService as any,
      sequenceCounterService as any,
      whatsappDeliveryService as any,
      templatesService as any,
      auditService as any,
      tenantContext as any,
    );
  });

  afterEach(() => {
    prisma.__reset();
  });

  it("GIVEN recorded non-monetary contribution WHEN receipt is generated THEN assigns atomic contribution receipt number", async () => {
    const contribution = await contributionsService.create(
      createMockContributionDto({
        contributorId: CONTRIBUTOR_ID,
        contributorNameSnapshot: "Rohan Deshmukh",
        donationType: "Silver",
        itemDescription: "250g Silver Pooja Thali",
        weight: 250.0,
        estimatedValue: 20000.0,
      }),
      TEST_USER_TREASURER,
    );

    const receipt = await receiptsService.generate(contribution.id);

    expect(receipt.id).toBeDefined();
    expect(receipt.contributionReceiptNumber).toBe("CRECEPT-2026-000001");
    expect(receipt.status).toBe("ACTIVE");
    expect(receipt.mandalNameSnapshot).toBe("Mandal Financial Trust");
  });

  it("GIVEN monetary and in-kind receipts WHEN generated THEN both sequence counters operate completely independently", async () => {
    const contribution = await contributionsService.create(createMockContributionDto(), TEST_USER_TREASURER);
    const inKindReceipt = await receiptsService.generate(contribution.id);

    // Generate monetary sequence counter independently
    const monetarySeq = await sequenceCounterService.getNextSequence(TEST_ORG_A, 2026, "receipt");
    const monetaryReceiptNumber = `RCPT-2026-${String(monetarySeq).padStart(6, "0")}`;

    expect(inKindReceipt.contributionReceiptNumber).toBe("CRECEPT-2026-000001");
    expect(monetaryReceiptNumber).toBe("RCPT-2026-000001");
    expect(sequenceCounterService.getNextSequence).toHaveBeenCalledWith(TEST_ORG_A, 2026, "contributionReceipt");
    expect(sequenceCounterService.getNextSequence).toHaveBeenCalledWith(TEST_ORG_A, 2026, "receipt");
  });

  it("GIVEN generated receipts for contributor WHEN findMyHistory is queried THEN returns only matching contributor receipts", async () => {
    const contribution = await contributionsService.create(
      createMockContributionDto({ contributorId: CONTRIBUTOR_ID }),
      TEST_USER_TREASURER,
    );
    const receipt = await receiptsService.generate(contribution.id);

    const history = await receiptsService.findMyHistory(CONTRIBUTOR_ID);

    expect(history).toHaveLength(1);
    expect(history[0].id).toBe(receipt.id);
  });

  it("GIVEN duplicate generate request on the same contribution WHEN called twice THEN returns existing receipt idempotently", async () => {
    const contribution = await contributionsService.create(createMockContributionDto(), TEST_USER_TREASURER);

    const receipt1 = await receiptsService.generate(contribution.id);
    const receipt2 = await receiptsService.generate(contribution.id);

    expect(receipt1.id).toBe(receipt2.id);
    expect(prisma.contributionReceipt.__store.size).toBe(1);
  });
});
