import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, MaxLength } from "class-validator";

export class ReplaceDocumentDto {
  @ApiProperty({ example: "mandal_stamp_v2.png" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(250)
  filename!: string;

  @ApiProperty({ example: "image/png" })
  @IsNotEmpty()
  @IsString()
  contentType!: string;

  @ApiProperty({ example: "Updated official seal stamp for year 2026" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(500)
  reason!: string;
}
