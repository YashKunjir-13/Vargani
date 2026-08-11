import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsOptional, IsString } from "class-validator";

export enum MockPaymentOutcome {
  SUCCESS = "SUCCESS",
  FAILED = "FAILED",
  CANCELLED = "CANCELLED",
  PENDING = "PENDING",
}

export class ProcessMockPaymentDto {
  @ApiProperty({ example: "p10054eb-7e3e-4b6d-a111-d0061e3ad811" })
  @IsNotEmpty()
  @IsString()
  paymentId!: string;

  @ApiProperty({ enum: MockPaymentOutcome, example: MockPaymentOutcome.SUCCESS })
  @IsNotEmpty()
  @IsEnum(MockPaymentOutcome)
  outcome!: MockPaymentOutcome;

  @ApiPropertyOptional({ example: "IDEM-12345678" })
  @IsOptional()
  @IsString()
  idempotencyKey?: string;

  @ApiPropertyOptional({ example: "Simulated mock payment failure" })
  @IsOptional()
  @IsString()
  reason?: string;
}
