import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsOptional, IsString, MaxLength } from "class-validator";

export class UpdateAssignmentDto {
  @ApiPropertyOptional({ example: "2026-09-20T00:00:00.000Z" })
  @IsOptional()
  endsAt?: string;

  @ApiPropertyOptional({ example: "Extended collection period" })
  @IsOptional()
  @IsString()
  @MaxLength(250)
  notes?: string;
}
