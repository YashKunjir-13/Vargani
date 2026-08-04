import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsEnum, IsObject, IsOptional, IsString, IsUUID, MaxLength } from "class-validator";
import { BillingMode, PublicVisibility } from "@pauti-pustak/backend-database";

export class UpdateContributorAccountDto {
  @ApiPropertyOptional({ example: "Sharma Family Household" })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  displayName?: string;

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

  @ApiPropertyOptional({ example: "500000" })
  @IsOptional()
  requestedAmountPaise?: string;

  @ApiPropertyOptional({ enum: PublicVisibility, example: PublicVisibility.PRIVATE })
  @IsOptional()
  @IsEnum(PublicVisibility)
  publicVisibility?: PublicVisibility;

  @ApiPropertyOptional({ example: { addressLine1: "123 Main St", city: "Pune" } })
  @IsOptional()
  @IsObject()
  billingAddressSnapshot?: Record<string, any>;
}
