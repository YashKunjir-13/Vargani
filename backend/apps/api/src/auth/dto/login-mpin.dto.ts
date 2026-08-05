import { ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, Matches } from "class-validator";

export class LoginMpinDto {
  @ApiProperty({ example: "9876543210", description: "Registered 10-digit mobile number" })
  @IsNotEmpty()
  @Matches(/^[6-9]\d{9}$/, { message: "phoneNumber must be a valid 10-digit mobile number" })
  phoneNumber!: string;

  @ApiProperty({ example: "123456", description: "6-digit numerical MPIN" })
  @IsNotEmpty()
  @Matches(/^\d{6}$/, { message: "mpin must be a 6-digit numerical PIN" })
  mpin!: string;

  @ApiProperty({ enum: ["MANDAL", "DONOR"], example: "DONOR", description: "Target account role context" })
  @IsNotEmpty()
  @IsEnum(["MANDAL", "DONOR"])
  role!: "MANDAL" | "DONOR";
}
