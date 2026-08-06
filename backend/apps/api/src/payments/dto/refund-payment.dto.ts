import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsNotEmpty, IsOptional, IsString, Matches, MaxLength } from "class-validator";

export class RefundPaymentDto {
  @ApiProperty({ example: "Duplicate donation by user error" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(500)
  reason!: string;

  @ApiPropertyOptional({ example: "50000", description: "Optional partial refund amount in paise" })
  @IsOptional()
  @Matches(/^[1-9]\d*$/, { message: "amountPaise must be a positive integer string" })
  amountPaise?: string;
}
