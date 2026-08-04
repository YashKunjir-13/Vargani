import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { DonorProfileStatus, PrismaService } from "@pauti-pustak/backend-database";
import { PanEncryptionService } from "@pauti-pustak/backend-security";
import { CreateDonorDto } from "./dto/create-donor.dto";
import { MergeDonorsDto } from "./dto/merge-donors.dto";
import { UpdateDonorDto } from "./dto/update-donor.dto";

@Injectable()
export class DonorService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly panEncryptionService: PanEncryptionService,
  ) {}

  async createDonor(userId: string, orgId: string | undefined, dto: CreateDonorDto) {
    // FR18, FR20: Require full name plus mobile or email; anonymous prohibited
    if (!dto.fullName || (!dto.mobile && !dto.email)) {
      throw new BadRequestException("Full name and at least one contact (mobile or email) are required");
    }

    // FR21: Search normalized mobile and email for exact candidates to prevent duplicate profiles
    if (dto.mobile) {
      const existingMobile = await this.prisma.donorProfile.findFirst({
        where: { mobile: dto.mobile, status: { not: DonorProfileStatus.MERGED } },
      });
      if (existingMobile) {
        return existingMobile; // Return matched candidate
      }
    }

    if (dto.email) {
      const normalizedEmail = dto.email.toLowerCase().trim();
      const existingEmail = await this.prisma.donorProfile.findFirst({
        where: { email: normalizedEmail, status: { not: DonorProfileStatus.MERGED } },
      });
      if (existingEmail) {
        return existingEmail;
      }
    }

    const panEncrypted = dto.panNumber ? this.panEncryptionService.encrypt(dto.panNumber) : null;

    const donorProfile = await this.prisma.donorProfile.create({
      data: {
        userId,
        fullName: dto.fullName,
        mobile: dto.mobile,
        email: dto.email ? dto.email.toLowerCase().trim() : null,
        addressLine1: dto.addressLine1,
        city: dto.city,
        postalCode: dto.postalCode,
        panEncrypted,
        status: orgId ? DonorProfileStatus.UNCLAIMED : DonorProfileStatus.ACTIVE,
        createdByUserId: userId,
        createdByOrgId: orgId,
        ...(orgId ? {} : { claimedAt: new Date() }),
      },
    });

    return donorProfile;
  }

  async searchDonors(organizationId: string, query?: string) {
    const where: any = {
      status: { not: DonorProfileStatus.MERGED },
    };

    if (query) {
      where.OR = [
        { fullName: { contains: query, mode: "insensitive" } },
        { mobile: { contains: query } },
        { email: { contains: query, mode: "insensitive" } },
      ];
    }

    return this.prisma.donorProfile.findMany({
      where,
      orderBy: { createdAt: "desc" },
      take: 50,
    });
  }

  async getDonor(donorId: string) {
    const donor = await this.prisma.donorProfile.findUnique({
      where: { id: donorId },
      include: { aliases: true },
    });

    if (!donor) {
      throw new NotFoundException("Donor profile not found");
    }

    return donor;
  }

  async updateDonor(donorId: string, actorUserId: string, dto: UpdateDonorDto) {
    const donor = await this.prisma.donorProfile.findUnique({ where: { id: donorId } });
    if (!donor || donor.status === DonorProfileStatus.MERGED) {
      throw new ForbiddenException("Donor profile cannot be updated");
    }

    const updated = await this.prisma.donorProfile.update({
      where: { id: donorId },
      data: {
        ...(dto.fullName ? { fullName: dto.fullName } : {}),
        ...(dto.mobile ? { mobile: dto.mobile } : {}),
        ...(dto.email ? { email: dto.email.toLowerCase().trim() } : {}),
        ...(dto.addressLine1 !== undefined ? { addressLine1: dto.addressLine1 } : {}),
        ...(dto.city !== undefined ? { city: dto.city } : {}),
        ...(dto.postalCode !== undefined ? { postalCode: dto.postalCode } : {}),
      },
    });

    return updated;
  }

  async getOwnHistory(userId: string) {
    const donor = await this.prisma.donorProfile.findUnique({ where: { userId } });
    if (!donor) {
      return [];
    }

    const accounts = await this.prisma.contributorAccount.findMany({
      where: { donorProfileId: donor.id },
      select: { id: true, organizationId: true, eventId: true, displayName: true, accountCode: true },
    });

    const accountIds = accounts.map((a) => a.id);
    const collections = await this.prisma.collectionRecord.findMany({
      where: { contributorAccountId: { in: accountIds }, status: "CONFIRMED" },
      select: {
        id: true,
        organizationId: true,
        eventId: true,
        amountPaise: true,
        collectedAt: true,
        mode: true,
        receiptId: true,
      },
      orderBy: { collectedAt: "desc" },
    });

    return collections.map((c) => ({
      ...c,
      amountPaise: c.amountPaise.toString(),
    }));
  }

  async mergeDonors(actorUserId: string, dto: MergeDonorsDto) {
    if (dto.survivingDonorId === dto.mergedDonorId) {
      throw new BadRequestException("Surviving donor and merged donor cannot be identical");
    }

    const surviving = await this.prisma.donorProfile.findUnique({ where: { id: dto.survivingDonorId } });
    const merged = await this.prisma.donorProfile.findUnique({ where: { id: dto.mergedDonorId } });

    if (!surviving || !merged) {
      throw new NotFoundException("One or both donor profiles were not found");
    }

    if (surviving.status === DonorProfileStatus.MERGED || merged.status === DonorProfileStatus.MERGED) {
      throw new ConflictException("Cannot merge a donor profile that has already been merged");
    }

    // Perform merge transaction
    const result = await this.prisma.$transaction(async (tx) => {
      // Step 1: Re-point contributor accounts to survivor
      const updatedAccounts = await tx.contributorAccount.updateMany({
        where: { donorProfileId: merged.id },
        data: { donorProfileId: surviving.id },
      });

      // Step 2: Create merge log and alias record
      const mergeLog = await tx.donorMergeLog.create({
        data: {
          survivingDonorId: surviving.id,
          mergedDonorId: merged.id,
          performedByUserId: actorUserId,
          reason: dto.reason,
          referenceCounts: { contributorAccountsReassigned: updatedAccounts.count },
          preMergeSnapshot: merged as any,
        },
      });

      await tx.donorAlias.create({
        data: {
          survivingDonorId: surviving.id,
          mergedDonorId: merged.id,
          previousMobile: merged.mobile,
          previousEmail: merged.email,
          mergeLogId: mergeLog.id,
        },
      });

      // Step 3: Deactivate merged profile
      await tx.donorProfile.update({
        where: { id: merged.id },
        data: {
          status: DonorProfileStatus.MERGED,
          deactivatedAt: new Date(),
        },
      });

      return {
        survivingDonorId: surviving.id,
        mergedDonorId: merged.id,
        reassignedAccountsCount: updatedAccounts.count,
        mergeLogId: mergeLog.id,
      };
    });

    return result;
  }
}
