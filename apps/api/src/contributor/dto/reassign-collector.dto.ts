import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsOptional, IsUUID } from "class-validator";

export class ReassignCollectorDto {
  @ApiPropertyOptional({ example: "b0000000-0000-0000-0000-000000000002", description: "Target volunteer ID (or null to unassign)" })
  @IsOptional()
  @IsUUID()
  assignedVolunteerId?: string;
}
