import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsNotEmpty, IsOptional, IsString, Matches } from "class-validator";

export class CreatePaymentOrderDto {
  @ApiProperty({ example: "50000", description: "Amount in paise (e.g. 50000 = ₹500.00)" })
  @IsNotEmpty()
  @Matches(/^[1-9]\d*$/, { message: "amountPaise must be a positive integer string" })
  amountPaise!: string;

  @ApiPropertyOptional({ example: "INR", default: "INR" })
  @IsOptional()
  @IsString()
  currency?: string;

  @ApiPropertyOptional({ example: "c20054eb-7e3e-4b6d-a111-d0061e3ad811" })
  @IsOptional()
  @IsString()
  billId?: string;

  @ApiPropertyOptional({ example: "a10054eb-7e3e-4b6d-a111-d0061e3ad222" })
  @IsOptional()
  @IsString()
  contributorAccountId?: string;

  @ApiPropertyOptional({ example: "Ramesh Sharma" })
  @IsOptional()
  @IsString()
  donorNameSnapshot?: string;
}
