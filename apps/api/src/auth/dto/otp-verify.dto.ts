import { ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsPhoneNumber, IsString, Length } from "class-validator";
import { OtpPurpose } from "@pauti-pustak/backend-database";

export class OtpVerifyDto {
  @ApiProperty({ example: "+919876543210" })
  @IsNotEmpty()
  @IsString()
  @IsPhoneNumber("IN")
  phoneNumber!: string;

  @ApiProperty({ example: "123456" })
  @IsNotEmpty()
  @IsString()
  @Length(6, 6)
  otp!: string;

  @ApiProperty({ enum: OtpPurpose, example: OtpPurpose.LOGIN })
  @IsNotEmpty()
  @IsEnum(OtpPurpose)
  purpose!: OtpPurpose;
}
