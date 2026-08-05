import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsOptional, IsString, MaxLength } from "class-validator";

export class EndAssignmentDto {
  @ApiPropertyOptional({ example: "Collection drive ended early" })
  @IsOptional()
  @IsString()
  @MaxLength(250)
  reason?: string;
}
