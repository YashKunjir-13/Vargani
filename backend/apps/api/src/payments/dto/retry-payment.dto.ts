import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsOptional, IsString } from "class-validator";

export class RetryPaymentDto {
  @ApiPropertyOptional({ example: "UPI" })
  @IsOptional()
  @IsString()
  newPaymentMethod?: string;

  @ApiPropertyOptional({ example: "IDEM-RETRY-123456" })
  @IsOptional()
  @IsString()
  idempotencyKey?: string;
}
