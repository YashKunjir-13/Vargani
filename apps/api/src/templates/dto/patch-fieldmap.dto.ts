import { Type } from "class-transformer";
import { ArrayMinSize, IsArray, IsIn, IsInt, IsNumber, IsOptional, Max, Min, ValidateNested } from "class-validator";
import { ApiProperty } from "@nestjs/swagger";
import { VALID_FIELD_KEYS } from "../field-map.validator";

export class FieldMapEntryDto {
  @ApiProperty({ enum: VALID_FIELD_KEYS })
  @IsIn(VALID_FIELD_KEYS)
  fieldKey!: string;

  @ApiProperty({ required: false, default: 1 })
  @IsOptional()
  @IsInt()
  @Min(1)
  page?: number;

  @ApiProperty()
  @IsNumber()
  @Min(0)
  @Max(1)
  x!: number;

  @ApiProperty()
  @IsNumber()
  @Min(0)
  @Max(1)
  y!: number;

  @ApiProperty({ required: false, default: 12 })
  @IsOptional()
  @IsNumber()
  fontSize?: number;

  @ApiProperty({ required: false, nullable: true })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(1)
  detectionConfidence?: number | null;
}

export class PatchFieldMapDto {
  @ApiProperty({ type: [FieldMapEntryDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => FieldMapEntryDto)
  fieldMap!: FieldMapEntryDto[];
}
