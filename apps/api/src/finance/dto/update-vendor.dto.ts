import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsEmail, IsOptional, IsPhoneNumber, IsString, MaxLength } from "class-validator";

export class UpdateVendorDto {
  @ApiPropertyOptional({ example: "Shiv Mandap Decorators" })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  name?: string;

  @ApiPropertyOptional({ example: "Anand Shinde" })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  contactPerson?: string;

  @ApiPropertyOptional({ example: "+919876543210" })
  @IsOptional()
  @IsString()
  @IsPhoneNumber("IN")
  mobile?: string;

  @ApiPropertyOptional({ example: "vendor@example.com" })
  @IsOptional()
  @IsString()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ example: "78 Market Yard, Pune" })
  @IsOptional()
  @IsString()
  address?: string;
}
