import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsOptional, IsString, MaxLength } from "class-validator";

export class UpdateOrganizationDto {
  @ApiPropertyOptional({ example: "Shree Ganesh Mandal Trust" })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  name?: string;

  @ApiPropertyOptional({ example: "123 Main Street" })
  @IsOptional()
  @IsString()
  @MaxLength(250)
  addressLine1?: string;

  @ApiPropertyOptional({ example: "Near Temple Square" })
  @IsOptional()
  @IsString()
  @MaxLength(250)
  addressLine2?: string;

  @ApiPropertyOptional({ example: "Pune" })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  city?: string;

  @ApiPropertyOptional({ example: "Maharashtra" })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  state?: string;

  @ApiPropertyOptional({ example: "411001" })
  @IsOptional()
  @IsString()
  @MaxLength(12)
  postalCode?: string;

  @ApiPropertyOptional({ example: "REG-2026-99" })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  registrationNumber?: string;

  @ApiPropertyOptional({ example: "President Name" })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  presidentName?: string;
}
