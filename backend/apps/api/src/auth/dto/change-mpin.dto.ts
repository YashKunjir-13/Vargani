import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, Matches } from "class-validator";

export class ChangeMpinDto {
  @ApiProperty({ example: "123456", description: "Current 6-digit MPIN" })
  @IsNotEmpty()
  @Matches(/^\d{6}$/, { message: "oldMpin must be a 6-digit numerical PIN" })
  oldMpin!: string;

  @ApiProperty({ example: "654321", description: "New 6-digit MPIN" })
  @IsNotEmpty()
  @Matches(/^\d{6}$/, { message: "newMpin must be a 6-digit numerical PIN" })
  newMpin!: string;
}
