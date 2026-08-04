import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsEmail, IsOptional, IsPhoneNumber, IsString, MaxLength } from "class-validator";

export class UpdateDonorDto {
  @ApiPropertyOptional({ example: "Ramesh Sharma" })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  fullName?: string;

  @ApiPropertyOptional({ example: "+919876543210" })
  @IsOptional()
  @IsString()
  @IsPhoneNumber("IN")
  mobile?: string;

  @ApiPropertyOptional({ example: "ramesh@example.com" })
  @IsOptional()
  @IsString()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ example: "123 Temple Road" })
  @IsOptional()
  @IsString()
  @MaxLength(250)
  addressLine1?: string;

  @ApiPropertyOptional({ example: "Pune" })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  city?: string;

  @ApiPropertyOptional({ example: "411001" })
  @IsOptional()
  @IsString()
  @MaxLength(12)
  postalCode?: string;

  @ApiPropertyOptional({ example: "ABCDE1234F" })
  @IsOptional()
  @IsString()
  @MaxLength(10)
  panNumber?: string;
}
