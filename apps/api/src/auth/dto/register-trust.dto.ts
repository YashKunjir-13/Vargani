import { PreferredLanguage } from "@pauti-pustak/backend-database";
import { Transform } from "class-transformer";
import {
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Matches,
  Max,
  MaxLength,
  Min,
  MinLength,
} from "class-validator";

export class RegisterTrustDto {
  @IsString()
  @MinLength(2)
  @MaxLength(200)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  mandalTrustName!: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  registrationNumber?: string;

  @IsString()
  @MinLength(2)
  @MaxLength(150)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  presidentHeadName!: string;

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

  @IsString()
  @MinLength(2)
  @MaxLength(100)
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  state!: string;

  @Matches(/^\d{6}$/, { message: "postalCode must be a valid 6-digit PIN code" })
  postalCode!: string;

  @IsInt()
  @Min(2000)
  @Max(2100)
  festivalYear!: number;

  @Matches(/^[6-9]\d{9}$/, { message: "phoneNumber must be a valid 10-digit mobile number" })
  phoneNumber!: string;

  @IsString()
  @MinLength(8)
  @MaxLength(72)
  password!: string;

  @IsEnum(PreferredLanguage)
  preferredLanguage!: PreferredLanguage;
}
