import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, MinLength } from "class-validator";

export class ReopenEventDto {
  @ApiProperty({ example: "Late vendor bills and pending collections reconciliation required" })
  @IsNotEmpty()
  @IsString()
  @MinLength(5)
  reason!: string;
}
