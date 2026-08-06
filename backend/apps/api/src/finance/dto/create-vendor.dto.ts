import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsEmail, IsNotEmpty, IsOptional, IsPhoneNumber, IsString, MaxLength } from "class-validator";

export class CreateVendorDto {
  @ApiProperty({ example: "Shiv Mandap Decorators" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(200)
  name!: string;

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

  @ApiPropertyOptional({ example: "27ABCDE1234F1Z5" })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  gstin?: string;

  @ApiPropertyOptional({ example: "ABCDE1234F" })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  panNumber?: string;

  @ApiPropertyOptional({ example: "918273645019" })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  bankAccountNumber?: string;

  @ApiPropertyOptional({ example: "SBIN0001234" })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  bankIfsc?: string;
}
