import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsBoolean, IsInt, IsOptional, IsString, MaxLength, Min } from "class-validator";

export class UpdateEventDto {
  @ApiPropertyOptional({ example: "Ganesh Utsav 2026 Grand Celebration" })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  name?: string;

  @ApiPropertyOptional({ example: "Updated description" })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: "New Mandap Location" })
  @IsOptional()
  @IsString()
  @MaxLength(250)
  location?: string;

  @ApiPropertyOptional({ example: "2026-09-01T00:00:00.000Z" })
  @IsOptional()
  startDate?: string;

  @ApiPropertyOptional({ example: "2026-09-15T00:00:00.000Z" })
  @IsOptional()
  endDate?: string;

  @ApiPropertyOptional({ example: "60000000" })
  @IsOptional()
  targetAmountPaise?: string;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  publicEnabled?: boolean;
}
