import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, MinLength } from "class-validator";

export class PasswordResetDto {
  @ApiProperty({ description: "Verification token received from password reset challenge" })
  @IsNotEmpty()
  @IsString()
  resetToken!: string;

  @ApiProperty({ minLength: 8, example: "NewStrongPass#123" })
  @IsNotEmpty()
  @IsString()
  @MinLength(8)
  newPassword!: string;
}
