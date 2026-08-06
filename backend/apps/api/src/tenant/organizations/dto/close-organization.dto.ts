import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, MinLength } from "class-validator";

export class CloseOrganizationDto {
  @ApiProperty({ example: "Event completed and audit finalized" })
  @IsNotEmpty()
  @IsString()
  @MinLength(5)
  reason!: string;
}
