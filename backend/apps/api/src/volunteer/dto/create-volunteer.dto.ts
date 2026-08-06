import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsObject, IsOptional, IsPhoneNumber, IsString, IsUUID, MaxLength } from "class-validator";
import { VolunteerType } from "@pauti-pustak/backend-database";

export class CreateVolunteerDto {
  @ApiProperty({ example: "Suresh Patil" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(160)
  fullName!: string;

  @ApiProperty({ example: "+919876543210" })
  @IsNotEmpty()
  @IsString()
  @IsPhoneNumber("IN")
  mobile!: string;

  @ApiProperty({ enum: VolunteerType, example: VolunteerType.DONATION_COLLECTOR })
  @IsNotEmpty()
  @IsEnum(VolunteerType)
  type!: VolunteerType;

  @ApiPropertyOptional({ example: "Area Coordinator" })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  customTypeLabel?: string;

  @ApiPropertyOptional({ example: "suresh@example.com" })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional({ example: "mr" })
  @IsOptional()
  @IsString()
  preferredLanguage?: string;

  @ApiPropertyOptional({ example: "+919876543211" })
  @IsOptional()
  @IsString()
  emergencyContact?: string;

  @ApiPropertyOptional({ example: { addressLine1: "456 Park St", city: "Pune" } })
  @IsOptional()
  @IsObject()
  addressSnapshot?: Record<string, any>;

  @ApiPropertyOptional({ example: "u0000000-0000-0000-0000-000000000001", description: "Optional identity user ID to link" })
  @IsOptional()
  @IsUUID()
  linkedUserId?: string;
}
