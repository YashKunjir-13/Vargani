import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsEmail, IsNotEmpty, IsOptional, IsPhoneNumber, IsString, MaxLength } from "class-validator";

export class CreateDonorDto {
  @ApiProperty({ example: "Ramesh Sharma" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(150)
  fullName!: string;

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
  @MaxLength(20)
  panNumber?: string;
}
