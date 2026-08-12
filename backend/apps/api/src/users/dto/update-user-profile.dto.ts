import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsEnum, IsOptional, IsString, IsUUID, MaxLength } from "class-validator";
import { PreferredLanguage } from "@pauti-pustak/backend-database";

export class UpdateUserProfileDto {
  @ApiPropertyOptional({ example: "Kuldeep Lakhera" })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  displayName?: string;

  @ApiPropertyOptional({ example: "9876543210" })
  @IsOptional()
  @IsString()
  primaryMobile?: string;

  @ApiPropertyOptional({ example: "kuldeep@example.com" })
  @IsOptional()
  @IsString()
  primaryEmail?: string;

  @ApiPropertyOptional({ enum: PreferredLanguage, example: PreferredLanguage.EN })
  @IsOptional()
  @IsEnum(PreferredLanguage)
  preferredLanguage?: PreferredLanguage;

  @ApiPropertyOptional({ example: "123e4567-e89b-42d3-a456-426614174000" })
  @IsOptional()
  @IsUUID("all")
  avatarDocumentId?: string;
}

