import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength } from "class-validator";
import { PaymentMode } from "@pauti-pustak/backend-database";

export class PayExpenseDto {
  @ApiProperty({ example: "acc-0000-0000-0000-000000000001", description: "Source Financial Account ID" })
  @IsNotEmpty()
  @IsUUID()
  accountId!: string;

  @ApiProperty({ example: "5900000", description: "Payout amount in paise" })
  @IsNotEmpty()
  @IsString()
  amountPaise!: string;

  @ApiProperty({ enum: PaymentMode, example: PaymentMode.BANK_TRANSFER })
  @IsNotEmpty()
  @IsEnum(PaymentMode)
  paymentMode!: PaymentMode;

  @ApiPropertyOptional({ example: "UTR987654321" })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  transactionReference?: string;
}
