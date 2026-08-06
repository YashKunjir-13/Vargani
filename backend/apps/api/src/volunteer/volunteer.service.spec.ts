import { Test, TestingModule } from "@nestjs/testing";
import { PrismaService, VolunteerAssignmentStatus, VolunteerStatus, VolunteerType } from "@pauti-pustak/backend-database";
import { PanEncryptionService } from "@pauti-pustak/backend-security";
import { VolunteerService } from "./volunteer.service";

describe("VolunteerService (Phase 1 Unit Tests)", () => {
  let service: VolunteerService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      volunteer: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      volunteerAssignment: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        updateMany: jest.fn(),
      },
      event: {
        findFirst: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        VolunteerService,
        { provide: PrismaService, useValue: prisma },
        PanEncryptionService,
      ],
    }).compile();

    service = module.get<VolunteerService>(VolunteerService);
  });

  describe("Volunteer Registration & Suspension", () => {
    it("creates active volunteer record", async () => {
      prisma.volunteer.findFirst.mockResolvedValue(null);
      prisma.volunteer.findUnique.mockResolvedValue(null);
      prisma.volunteer.create.mockResolvedValue({
        id: "vol-1",
        organizationId: "org-1",
        volunteerCode: "VOL-1234",
        fullName: "Suresh Patil",
        type: VolunteerType.DONATION_COLLECTOR,
        status: VolunteerStatus.ACTIVE,
      });

      const res = await service.createVolunteer("org-1", "user-1", {
        fullName: "Suresh Patil",
        mobile: "+919876543210",
        type: VolunteerType.DONATION_COLLECTOR,
      });

      expect(res.id).toBe("vol-1");
      expect(res.status).toBe(VolunteerStatus.ACTIVE);
    });

    it("suspends volunteer and terminates active assignments", async () => {
      prisma.volunteer.findFirst.mockResolvedValue({ id: "vol-1", organizationId: "org-1" });
      prisma.volunteer.update.mockResolvedValue({ id: "vol-1", status: VolunteerStatus.SUSPENDED });
      prisma.volunteerAssignment.updateMany.mockResolvedValue({ count: 1 });

      const res = await service.suspendVolunteer("org-1", "vol-1", { reason: "Policy violation" });

      expect(res.status).toBe(VolunteerStatus.SUSPENDED);
      expect(prisma.volunteerAssignment.updateMany).toHaveBeenCalledWith({
        where: { volunteerId: "vol-1", status: VolunteerAssignmentStatus.ACTIVE },
        data: expect.objectContaining({ status: VolunteerAssignmentStatus.CANCELLED }),
      });
    });
  });

  describe("Event Scope Assignment & Authority", () => {
    it("creates active scope assignment for event", async () => {
      prisma.volunteer.findFirst.mockResolvedValue({ id: "vol-1", organizationId: "org-1", status: VolunteerStatus.ACTIVE });
      prisma.event.findFirst.mockResolvedValue({ id: "evt-1", organizationId: "org-1", status: "ACTIVE" });
      prisma.volunteerAssignment.create.mockResolvedValue({
        id: "asgn-1",
        organizationId: "org-1",
        eventId: "evt-1",
        volunteerId: "vol-1",
        roleCode: "DONATION_COLLECTOR",
        scopeType: "AREA",
        status: VolunteerAssignmentStatus.ACTIVE,
      });

      const res = await service.createAssignment("org-1", "evt-1", "user-1", {
        volunteerId: "vol-1",
        roleCode: "DONATION_COLLECTOR",
        scopeType: "AREA" as any,
        scopeReferenceId: "AREA_NORTH",
      });

      expect(res.id).toBe("asgn-1");
      expect(res.status).toBe(VolunteerAssignmentStatus.ACTIVE);
    });

    it("validates active collection assignment authority", async () => {
      prisma.volunteerAssignment.findFirst.mockResolvedValue({ id: "asgn-1" });
      const hasAuth = await service.hasActiveCollectionAssignment("org-1", "evt-1", "vol-1");
      expect(hasAuth).toBe(true);
    });
  });
});
