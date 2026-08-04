import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { PreferredLanguage } from "@pauti-pustak/backend-database";
import { Transform } from "class-transformer";
import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from "class-validator";

export class RegisterDonorDto {
  @ApiProperty({ example: "Ramesh Sharma", description: "Full Name of Donor" })
  @IsNotEmpty()
  @IsString()
  @MinLength(2)
  @MaxLength(150)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  fullName!: string;

  @ApiPropertyOptional({ example: "ramesh@example.com" })
  @IsOptional()
  @IsEmail()
  @MaxLength(320)
  @Transform(({ value }) => (typeof value === "string" ? value.trim().toLowerCase() : value))
  email?: string;

  @ApiPropertyOptional({ example: "AAAPD1234M" })
  @IsOptional()
  @Matches(/^[A-Z]{5}\d{4}[A-Z]$/, { message: "panNumber must be a valid PAN, e.g. AAAPD1234M" })
  @Transform(({ value }) => (typeof value === "string" ? value.trim().toUpperCase() : value))
  panNumber?: string;

  @ApiPropertyOptional({ example: "123 Main St" })
  @IsOptional()
  @IsString()
  @MaxLength(250)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  addressLine1?: string;

  @ApiProperty({ example: "Mumbai" })
  @IsNotEmpty()
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  city!: string;

  @ApiPropertyOptional({ example: "400001" })
  @IsOptional()
  @Matches(/^\d{6}$/, { message: "postalCode must be a valid 6-digit PIN code" })
  postalCode?: string;

  @ApiProperty({ example: "9876543210" })
  @IsNotEmpty()
  @Matches(/^[6-9]\d{9}$/, { message: "phoneNumber must be a valid 10-digit mobile number" })
  phoneNumber!: string;

  @ApiProperty({ example: "StrongPass#123", minLength: 8 })
  @IsNotEmpty()
  @IsString()
  @MinLength(8)
  @MaxLength(72)
  password!: string;

  @ApiProperty({ enum: PreferredLanguage, example: PreferredLanguage.EN })
  @IsNotEmpty()
  @IsEnum(PreferredLanguage)
  preferredLanguage!: PreferredLanguage;
}

