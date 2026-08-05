import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, Matches } from "class-validator";

export class CreateMpinDto {
  @ApiProperty({ example: "123456", description: "6-digit numerical MPIN" })
  @IsNotEmpty()
  @Matches(/^\d{6}$/, { message: "mpin must be a 6-digit numerical PIN" })
  mpin!: string;
}
