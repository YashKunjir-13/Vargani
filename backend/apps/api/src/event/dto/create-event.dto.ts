import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsInt, IsNotEmpty, IsOptional, IsString, MaxLength, Min } from "class-validator";

export class CreateEventDto {
  @ApiProperty({ example: "GANPATI_2026", description: "Event type code from reference catalog" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(50)
  eventTypeCode!: string;

  @ApiProperty({ example: "Ganesh Utsav 2026" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(200)
  name!: string;

  @ApiPropertyOptional({ example: "Annual Ganesh Festival Celebration" })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: "Main Mandap, Pune" })
  @IsOptional()
  @IsString()
  @MaxLength(250)
  location?: string;

  @ApiProperty({ example: 2026 })
  @IsNotEmpty()
  @IsInt()
  @Min(2000)
  financialYearStart!: number;

  @ApiPropertyOptional({ example: "2026-09-01T00:00:00.000Z" })
  @IsOptional()
  startDate?: string;

  @ApiPropertyOptional({ example: "2026-09-15T00:00:00.000Z" })
  @IsOptional()
  endDate?: string;

  @ApiPropertyOptional({ example: "50000000", description: "Target collection in paise (e.g. 500,000 INR = 50,000,000 paise)" })
  @IsOptional()
  targetAmountPaise?: string;

  @ApiPropertyOptional({ example: "0", description: "Opening balance in paise" })
  @IsOptional()
  openingBalancePaise?: string;
}
