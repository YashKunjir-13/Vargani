import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { ArrayNotEmpty, IsArray, IsNotEmpty, IsOptional, IsString, MaxLength } from "class-validator";

export class CreateRoleDto {
  @ApiProperty({ example: "Vice President" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(100)
  name!: string;

  @ApiPropertyOptional({ example: "Assists the President with event operations" })
  @IsOptional()
  @IsString()
  @MaxLength(250)
  description?: string;

  @ApiProperty({ example: ["donor.view", "event.view", "contribution.view"] })
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  permissionCodes!: string[];
}
