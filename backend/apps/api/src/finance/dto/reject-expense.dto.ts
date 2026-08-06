import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, MinLength } from "class-validator";

export class RejectExpenseDto {
  @ApiProperty({ example: "Original tax invoice is missing or corrupted" })
  @IsNotEmpty()
  @IsString()
  @MinLength(5)
  reason!: string;
}
