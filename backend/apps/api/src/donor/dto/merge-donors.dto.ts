import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, IsUUID, MinLength } from "class-validator";

export class MergeDonorsDto {
  @ApiProperty({ example: "a0000000-0000-0000-0000-000000000001", description: "Target surviving donor profile ID" })
  @IsNotEmpty()
  @IsUUID()
  survivingDonorId!: string;

  @ApiProperty({ example: "b0000000-0000-0000-0000-000000000002", description: "Duplicate donor profile ID to merge into survivor" })
  @IsNotEmpty()
  @IsUUID()
  mergedDonorId!: string;

  @ApiProperty({ example: "Duplicate entry registered offline during festival entry" })
  @IsNotEmpty()
  @IsString()
  @MinLength(5)
  reason!: string;
}
