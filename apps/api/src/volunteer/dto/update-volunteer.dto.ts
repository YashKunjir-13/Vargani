import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsEnum, IsObject, IsOptional, IsPhoneNumber, IsString, MaxLength } from "class-validator";
import { VolunteerType } from "@pauti-pustak/backend-database";

export class UpdateVolunteerDto {
  @ApiPropertyOptional({ example: "Suresh Patil" })
  @IsOptional()
  @IsString()
  @MaxLength(160)
  fullName?: string;

  @ApiPropertyOptional({ enum: VolunteerType, example: VolunteerType.DONATION_COLLECTOR })
  @IsOptional()
  @IsEnum(VolunteerType)
  type?: VolunteerType;

  @ApiPropertyOptional({ example: "suresh@example.com" })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional({ example: "mr" })
  @IsOptional()
  @IsString()
  preferredLanguage?: string;

  @ApiPropertyOptional({ example: { addressLine1: "456 Park St", city: "Pune" } })
  @IsOptional()
  @IsObject()
  addressSnapshot?: Record<string, any>;
}
