import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsOptional, IsString, IsUUID } from "class-validator";
import { CollectionMode } from "@pauti-pustak/backend-database";

export class CheckoutPaymentDto {
  @ApiProperty({ example: "00000000-0000-4000-a000-000000000001" })
  @IsNotEmpty()
  @IsUUID()
  organizationId!: string;

  @ApiProperty({ example: "00000000-0000-4000-a000-000000000002" })
  @IsNotEmpty()
  @IsUUID()
  eventId!: string;

  @ApiPropertyOptional({ example: "00000000-0000-4000-a000-000000000003", description: "Pending bill ID to pay" })
  @IsOptional()
  @IsUUID()
  billId?: string;

  @ApiPropertyOptional({ example: "00000000-0000-4000-a000-000000000004", description: "Contributor account ID" })
  @IsOptional()
  @IsUUID()
  contributorAccountId?: string;

  @ApiProperty({ example: "500000", description: "Payment amount in paise (e.g. 5,000 INR = 500,000 paise)" })
  @IsNotEmpty()
  @IsString()
  amountPaise!: string;

  @ApiProperty({ enum: CollectionMode, example: CollectionMode.UPI })
  @IsNotEmpty()
  @IsEnum(CollectionMode)
  mode!: CollectionMode;

  @ApiPropertyOptional({ example: "pay_1234567890" })
  @IsOptional()
  @IsString()
  paymentReference?: string;
}
