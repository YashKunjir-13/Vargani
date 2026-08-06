import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength } from "class-validator";

export class CreateExpenseDto {
  @ApiProperty({ example: "v0000000-0000-0000-0000-000000000001", description: "Vendor ID" })
  @IsNotEmpty()
  @IsUUID()
  vendorId!: string;

  @ApiProperty({ example: "DECORATION", description: "Category code" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(80)
  categoryCode!: string;

  @ApiProperty({ example: "Main Mandap Stage Setup and Lighting" })
  @IsNotEmpty()
  @IsString()
  description!: string;

  @ApiProperty({ example: "2026-09-05T00:00:00.000Z" })
  @IsNotEmpty()
  expenseDate!: string;

  @ApiProperty({ example: "5000000", description: "Base amount in paise (50,000 INR = 5,000,000 paise)" })
  @IsNotEmpty()
  @IsString()
  baseAmountPaise!: string;

  @ApiPropertyOptional({ example: "900000", description: "Tax amount in paise" })
  @IsOptional()
  @IsString()
  taxAmountPaise?: string;
}
