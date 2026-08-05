import { ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, Matches } from "class-validator";

export class VerifyMpinResetDto {
  @ApiProperty({ example: "9876543210", description: "Registered 10-digit mobile number" })
  @IsNotEmpty()
  @Matches(/^[6-9]\d{9}$/, { message: "phoneNumber must be a valid 10-digit mobile number" })
  phoneNumber!: string;

  @ApiProperty({ example: "123456", description: "6-digit OTP code received" })
  @IsNotEmpty()
  @Matches(/^\d{6}$/, { message: "otp must be a 6-digit numerical code" })
  otp!: string;

  @ApiProperty({ example: "654321", description: "New 6-digit MPIN to set" })
  @IsNotEmpty()
  @Matches(/^\d{6}$/, { message: "newMpin must be a 6-digit numerical PIN" })
  newMpin!: string;

  @ApiProperty({ enum: ["MANDAL", "DONOR"], example: "DONOR", description: "Target account role context" })
  @IsNotEmpty()
  @IsEnum(["MANDAL", "DONOR"])
  role!: "MANDAL" | "DONOR";
}
