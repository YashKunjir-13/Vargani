import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsOptional, IsString } from "class-validator";

export class CancelPaymentDto {
  @ApiPropertyOptional({ example: "User cancelled on checkout screen" })
  @IsOptional()
  @IsString()
  reason?: string;
}
