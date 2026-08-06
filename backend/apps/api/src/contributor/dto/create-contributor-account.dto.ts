import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsObject, IsOptional, IsString, IsUUID, MaxLength } from "class-validator";
import { BillingMode, ContributorAccountType, PublicVisibility } from "@pauti-pustak/backend-database";

export class CreateContributorAccountDto {
  @ApiProperty({ example: "a0000000-0000-0000-0000-000000000001", description: "Canonical Donor Profile ID" })
  @IsNotEmpty()
  @IsUUID()
  donorProfileId!: string;

  @ApiProperty({ enum: ContributorAccountType, example: ContributorAccountType.INDIVIDUAL })
  @IsNotEmpty()
  @IsEnum(ContributorAccountType)
  type!: ContributorAccountType;

  @ApiProperty({ example: "Sharma Family Household" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(200)
  displayName!: string;

  @ApiPropertyOptional({ example: "Ramesh Sharma" })
  @IsOptional()
  @IsString()
  @MaxLength(160)
  contactPerson?: string;

  @ApiPropertyOptional({ example: "AREA_NORTH" })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  areaCode?: string;

  @ApiPropertyOptional({ example: "ROUTE_1" })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  routeCode?: string;

  @ApiPropertyOptional({ example: "VIP_SPONSOR" })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  categoryCode?: string;

  @ApiPropertyOptional({ enum: BillingMode, example: BillingMode.SUGGESTED })
  @IsOptional()
  @IsEnum(BillingMode)
  billingMode?: BillingMode;

  @ApiPropertyOptional({ example: "500000", description: "Requested amount in paise (e.g. 5,000 INR = 500,000 paise)" })
  @IsOptional()
  requestedAmountPaise?: string;

  @ApiPropertyOptional({ example: "b0000000-0000-0000-0000-000000000002", description: "Assigned Volunteer ID" })
  @IsOptional()
  @IsUUID()
  assignedVolunteerId?: string;

  @ApiPropertyOptional({ example: "mr" })
  @IsOptional()
  @IsString()
  preferredLanguage?: string;

  @ApiPropertyOptional({ enum: PublicVisibility, example: PublicVisibility.NAME_AND_AMOUNT })
  @IsOptional()
  @IsEnum(PublicVisibility)
  publicVisibility?: PublicVisibility;

  @ApiPropertyOptional({ example: { addressLine1: "123 Main St", city: "Pune" } })
  @IsOptional()
  @IsObject()
  billingAddressSnapshot?: Record<string, any>;
}
