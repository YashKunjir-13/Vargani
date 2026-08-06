import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, MaxLength } from "class-validator";

export class ReplaceReceiptDto {
  @ApiProperty({ example: "Corrected donor name and amount spelling on paper receipt" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(500)
  reason!: string;
}
