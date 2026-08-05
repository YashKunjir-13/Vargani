import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsObject, IsOptional, IsString, IsUUID, MaxLength } from "class-validator";
import { AssignmentScopeType } from "@pauti-pustak/backend-database";

export class CreateAssignmentDto {
  @ApiProperty({ example: "vol-0000-0000-0000-000000000001" })
  @IsNotEmpty()
  @IsUUID()
  volunteerId!: string;

  @ApiProperty({ example: "DONATION_COLLECTOR" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(80)
  roleCode!: string;

  @ApiProperty({ enum: AssignmentScopeType, example: AssignmentScopeType.AREA })
  @IsNotEmpty()
  @IsEnum(AssignmentScopeType)
  scopeType!: AssignmentScopeType;

  @ApiPropertyOptional({ example: "AREA_NORTH" })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  scopeReferenceId?: string;

  @ApiPropertyOptional({ example: "2026-09-01T00:00:00.000Z" })
  @IsOptional()
  startsAt?: string;

  @ApiPropertyOptional({ example: "2026-09-15T00:00:00.000Z" })
  @IsOptional()
  endsAt?: string;

  @ApiPropertyOptional({ example: { areaName: "North Zone", maxCollections: 100 } })
  @IsOptional()
  @IsObject()
  scopeSnapshot?: Record<string, any>;
}
