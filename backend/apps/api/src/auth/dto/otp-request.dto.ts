import { ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsPhoneNumber, IsString } from "class-validator";
import { OtpPurpose } from "@pauti-pustak/backend-database";

export class OtpRequestDto {
  @ApiProperty({ type: String, example: "+919876543210", description: "Target mobile number in E.164 format" })
  @IsNotEmpty()
  @IsString()
  @IsPhoneNumber("IN")
  phoneNumber!: string;

  @ApiProperty({ enum: OtpPurpose, example: OtpPurpose.LOGIN })
  @IsNotEmpty()
  @IsEnum(OtpPurpose)
  purpose!: OtpPurpose;
}
