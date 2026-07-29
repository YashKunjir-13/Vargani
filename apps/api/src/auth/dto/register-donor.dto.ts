import { PreferredLanguage } from "@pauti-pustak/backend-database";
import { Transform } from "class-transformer";
import {
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from "class-validator";

export class RegisterDonorDto {
  @IsString()
  @MinLength(2)
  @MaxLength(150)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  fullName!: string;

  @IsOptional()
  @IsEmail()
  @MaxLength(320)
  @Transform(({ value }) => (typeof value === "string" ? value.trim().toLowerCase() : value))
  email?: string;

  @IsOptional()
  @Matches(/^[A-Z]{5}\d{4}[A-Z]$/, { message: "panNumber must be a valid PAN, e.g. AAAPD1234M" })
  @Transform(({ value }) => (typeof value === "string" ? value.trim().toUpperCase() : value))
  panNumber?: string;

  @IsOptional()
  @IsString()
  @MaxLength(250)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  addressLine1?: string;

  @IsString()
  @MinLength(2)
  @MaxLength(100)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  city!: string;

  @IsOptional()
  @Matches(/^\d{6}$/, { message: "postalCode must be a valid 6-digit PIN code" })
  postalCode?: string;

  @Matches(/^[6-9]\d{9}$/, { message: "phoneNumber must be a valid 10-digit mobile number" })
  phoneNumber!: string;

  @IsString()
  @MinLength(8)
  @MaxLength(72)
  password!: string;

  @IsEnum(PreferredLanguage)
  preferredLanguage!: PreferredLanguage;
}
