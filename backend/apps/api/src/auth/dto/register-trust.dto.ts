import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { PreferredLanguage } from "@pauti-pustak/backend-database";
import { Transform } from "class-transformer";
import {
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  Max,
  MaxLength,
  Min,
  MinLength,
} from "class-validator";

export class RegisterTrustDto {
  @ApiProperty({ example: "Shree Ganesh Mandal Trust" })
  @IsNotEmpty()
  @IsString()
  @MinLength(2)
  @MaxLength(200)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  mandalTrustName!: string;

  @ApiPropertyOptional({ example: "REG-12345-MUM" })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  registrationNumber?: string;

  @ApiProperty({ example: "Sanjay Patil" })
  @IsNotEmpty()
  @IsString()
  @MinLength(2)
  @MaxLength(150)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  presidentHeadName!: string;

  @ApiPropertyOptional({ example: "MG Road, Dadar" })
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

  @ApiProperty({ example: "Maharashtra" })
  @IsNotEmpty()
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  state!: string;

  @ApiProperty({ example: "400014" })
  @IsNotEmpty()
  @Matches(/^\d{6}$/, { message: "postalCode must be a valid 6-digit PIN code" })
  postalCode!: string;

  @ApiProperty({ example: 2026 })
  @IsInt()
  @Min(2000)
  @Max(2100)
  festivalYear!: number;

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

