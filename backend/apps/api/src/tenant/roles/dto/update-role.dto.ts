import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsArray, IsBoolean, IsOptional, IsString, MaxLength } from "class-validator";

export class UpdateRoleDto {
  @ApiPropertyOptional({ example: "Senior Vice President" })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  name?: string;

  @ApiPropertyOptional({ example: "Updated description" })
  @IsOptional()
  @IsString()
  @MaxLength(250)
  description?: string;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiPropertyOptional({ example: ["donor.view", "event.view"] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  permissionCodes?: string[];
}
