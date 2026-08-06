import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, MinLength } from "class-validator";

export class SuspendVolunteerDto {
  @ApiProperty({ example: "Violation of collector guidelines" })
  @IsNotEmpty()
  @IsString()
  @MinLength(5)
  reason!: string;
}
