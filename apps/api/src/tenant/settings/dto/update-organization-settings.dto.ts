import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsArray, IsBoolean, IsEnum, IsInt, IsOptional, IsString, Max, Min } from "class-validator";
import { PreferredLanguage, PublicVisibility } from "@pauti-pustak/backend-database";

export class UpdateOrganizationSettingsDto {
  @ApiPropertyOptional({ enum: PreferredLanguage, example: PreferredLanguage.EN })
  @IsOptional()
  @IsEnum(PreferredLanguage)
  defaultLanguage?: PreferredLanguage;

  @ApiPropertyOptional({ enum: PreferredLanguage, isArray: true, example: [PreferredLanguage.EN, PreferredLanguage.MR, PreferredLanguage.HI] })
  @IsOptional()
  @IsArray()
  @IsEnum(PreferredLanguage, { each: true })
  enabledLanguages?: PreferredLanguage[];

  @ApiPropertyOptional({ example: "Asia/Kolkata" })
  @IsOptional()
  @IsString()
  timezone?: string;

  @ApiPropertyOptional({ example: 4, description: "Month 1-12 (April=4)" })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(12)
  financialYearStartMonth?: number;

  @ApiPropertyOptional({ example: 1, description: "Day 1-31" })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(31)
  financialYearStartDay?: number;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  invitationAcceptanceRequired?: boolean;

  @ApiPropertyOptional({ enum: PublicVisibility, example: PublicVisibility.NAME_AND_AMOUNT })
  @IsOptional()
  @IsEnum(PublicVisibility)
  defaultDonorVisibility?: PublicVisibility;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  inKindValueRequired?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  includeInKindInContributionTotal?: boolean;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  collectorBoundReceiptBooks?: boolean;

  @ApiPropertyOptional({ example: "STANDARD_TRILINGUAL" })
  @IsOptional()
  @IsString()
  receiptTemplateCode?: string;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  whatsappEnabled?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  emailEnabled?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  inAppEnabled?: boolean;

  @ApiPropertyOptional({ example: "Updated financial year and template settings" })
  @IsOptional()
  @IsString()
  changeReason?: string;
}
