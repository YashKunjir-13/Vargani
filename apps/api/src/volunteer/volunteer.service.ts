import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { PrismaService, VolunteerAssignmentStatus, VolunteerStatus } from "@pauti-pustak/backend-database";
import { PanEncryptionService } from "@pauti-pustak/backend-security";
import { createHash, randomInt } from "crypto";
import { CreateAssignmentDto } from "./dto/create-assignment.dto";
import { CreateVolunteerDto } from "./dto/create-volunteer.dto";
import { EndAssignmentDto } from "./dto/end-assignment.dto";
import { LinkUserDto } from "./dto/link-user.dto";
import { SuspendVolunteerDto } from "./dto/suspend-volunteer.dto";
import { UpdateAssignmentDto } from "./dto/update-assignment.dto";
import { UpdateVolunteerDto } from "./dto/update-volunteer.dto";

@Injectable()
export class VolunteerService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly panEncryptionService: PanEncryptionService,
  ) {}

  async listVolunteers(organizationId: string, filters?: { status?: VolunteerStatus; type?: any }) {
    return this.prisma.volunteer.findMany({
      where: {
        organizationId,
        ...(filters?.status ? { status: filters.status } : {}),
        ...(filters?.type ? { type: filters.type } : {}),
      },
      orderBy: { createdAt: "desc" },
    });
  }

  async getVolunteer(organizationId: string, volunteerId: string) {
    const volunteer = await this.prisma.volunteer.findFirst({
      where: { id: volunteerId, organizationId },
    });

    if (!volunteer) {
      throw new NotFoundException("Volunteer not found");
    }

    const assignments = await this.prisma.volunteerAssignment.findMany({
      where: { volunteerId, organizationId, status: VolunteerAssignmentStatus.ACTIVE },
    });

    return {
      ...volunteer,
      activeAssignments: assignments,
    };
  }

  async createVolunteer(organizationId: string, userId: string, dto: CreateVolunteerDto) {
    const mobileHash = this.hashMobile(dto.mobile);

    const existing = await this.prisma.volunteer.findFirst({
      where: { organizationId, mobileHash },
    });

    if (existing) {
      throw new ConflictException("Volunteer with this mobile number already exists in organization");
    }

    const volunteerCode = await this.generateVolunteerCode(organizationId);

    const volunteer = await this.prisma.volunteer.create({
      data: {
        organizationId,
        volunteerCode,
        fullName: dto.fullName,
        mobileEncrypted: this.panEncryptionService.encrypt(dto.mobile),
        mobileHash,
        emailEncrypted: dto.email ? this.panEncryptionService.encrypt(dto.email.toLowerCase().trim()) : null,
        emergencyContactEncrypted: dto.emergencyContact ? this.panEncryptionService.encrypt(dto.emergencyContact) : null,
        type: dto.type,
        customTypeLabel: dto.customTypeLabel,
        preferredLanguage: dto.preferredLanguage ?? "mr",
        addressSnapshot: dto.addressSnapshot ?? {},
        linkedUserId: dto.linkedUserId,
        status: VolunteerStatus.ACTIVE,
        createdByUserId: userId,
      },
    });

    return volunteer;
  }

  async updateVolunteer(organizationId: string, volunteerId: string, dto: UpdateVolunteerDto) {
    const volunteer = await this.prisma.volunteer.findFirst({ where: { id: volunteerId, organizationId } });
    if (!volunteer || volunteer.status === VolunteerStatus.INACTIVE) {
      throw new ForbiddenException("Inactive volunteer profile cannot be updated");
    }

    const updated = await this.prisma.volunteer.update({
      where: { id: volunteerId },
      data: {
        ...(dto.fullName ? { fullName: dto.fullName } : {}),
        ...(dto.type ? { type: dto.type } : {}),
        ...(dto.email ? { emailEncrypted: this.panEncryptionService.encrypt(dto.email.toLowerCase().trim()) } : {}),
        ...(dto.preferredLanguage ? { preferredLanguage: dto.preferredLanguage } : {}),
        ...(dto.addressSnapshot ? { addressSnapshot: dto.addressSnapshot } : {}),
      },
    });

    return updated;
  }

  async activateVolunteer(organizationId: string, volunteerId: string) {
    const volunteer = await this.prisma.volunteer.findFirst({ where: { id: volunteerId, organizationId } });
    if (!volunteer) {
      throw new NotFoundException("Volunteer not found");
    }

    const updated = await this.prisma.volunteer.update({
      where: { id: volunteerId },
      data: { status: VolunteerStatus.ACTIVE },
    });

    return updated;
  }

  async suspendVolunteer(organizationId: string, volunteerId: string, dto: SuspendVolunteerDto) {
    const volunteer = await this.prisma.volunteer.findFirst({ where: { id: volunteerId, organizationId } });
    if (!volunteer) {
      throw new NotFoundException("Volunteer not found");
    }

    const updated = await this.prisma.volunteer.update({
      where: { id: volunteerId },
      data: { status: VolunteerStatus.SUSPENDED },
    });

    // End active assignments
    await this.prisma.volunteerAssignment.updateMany({
      where: { volunteerId, status: VolunteerAssignmentStatus.ACTIVE },
      data: { status: VolunteerAssignmentStatus.CANCELLED, endReason: dto.reason },
    });

    return updated;
  }

  async linkUser(organizationId: string, volunteerId: string, dto: LinkUserDto) {
    const volunteer = await this.prisma.volunteer.findFirst({ where: { id: volunteerId, organizationId } });
    if (!volunteer) {
      throw new NotFoundException("Volunteer not found");
    }

    const updated = await this.prisma.volunteer.update({
      where: { id: volunteerId },
      data: { linkedUserId: dto.linkedUserId },
    });

    return updated;
  }

  async createAssignment(organizationId: string, eventId: string, userId: string, dto: CreateAssignmentDto) {
    const volunteer = await this.prisma.volunteer.findFirst({
      where: { id: dto.volunteerId, organizationId, status: VolunteerStatus.ACTIVE },
    });

    if (!volunteer) {
      throw new BadRequestException("Volunteer is inactive or not found");
    }

    const event = await this.prisma.event.findFirst({ where: { id: eventId, organizationId } });
    if (!event || event.status === "ARCHIVED") {
      throw new ForbiddenException("Event is inactive or archived");
    }

    const assignment = await this.prisma.volunteerAssignment.create({
      data: {
        organizationId,
        eventId,
        volunteerId: dto.volunteerId,
        roleCode: dto.roleCode,
        scopeType: dto.scopeType,
        scopeReferenceId: dto.scopeReferenceId,
        status: VolunteerAssignmentStatus.ACTIVE,
        startsAt: dto.startsAt ? new Date(dto.startsAt) : new Date(),
        endsAt: dto.endsAt ? new Date(dto.endsAt) : null,
        scopeSnapshot: dto.scopeSnapshot ?? {},
        assignedByUserId: userId,
      },
    });

    return assignment;
  }

  async updateAssignment(organizationId: string, assignmentId: string, dto: UpdateAssignmentDto) {
    const assignment = await this.prisma.volunteerAssignment.findFirst({ where: { id: assignmentId, organizationId } });
    if (!assignment) {
      throw new NotFoundException("Assignment not found");
    }

    const updated = await this.prisma.volunteerAssignment.update({
      where: { id: assignmentId },
      data: {
        ...(dto.endsAt ? { endsAt: new Date(dto.endsAt) } : {}),
      },
    });

    return updated;
  }

  async endAssignment(organizationId: string, assignmentId: string, userId: string, dto: EndAssignmentDto) {
    const assignment = await this.prisma.volunteerAssignment.findFirst({ where: { id: assignmentId, organizationId } });
    if (!assignment) {
      throw new NotFoundException("Assignment not found");
    }

    const updated = await this.prisma.volunteerAssignment.update({
      where: { id: assignmentId },
      data: {
        status: VolunteerAssignmentStatus.COMPLETED,
        endedByUserId: userId,
        endReason: dto.reason,
      },
    });

    return updated;
  }

  async hasActiveCollectionAssignment(organizationId: string, eventId: string, volunteerId: string): Promise<boolean> {
    const active = await this.prisma.volunteerAssignment.findFirst({
      where: {
        organizationId,
        eventId,
        volunteerId,
        status: VolunteerAssignmentStatus.ACTIVE,
        roleCode: { in: ["DONATION_COLLECTOR", "COLLECTOR"] },
      },
    });
    return !!active;
  }

  private hashMobile(mobile: string): string {
    return createHash("sha256").update(mobile.trim()).digest("hex");
  }

  private async generateVolunteerCode(organizationId: string): Promise<string> {
    for (let attempt = 0; attempt < 5; attempt += 1) {
      const suffix = randomInt(1000, 9999).toString();
      const volunteerCode = `VOL-${suffix}`;
      const existing = await this.prisma.volunteer.findUnique({
        where: { organizationId_volunteerCode: { organizationId, volunteerCode } },
      });
      if (!existing) {
        return volunteerCode;
      }
    }
    throw new ConflictException("Could not generate unique volunteer code");
  }
}
