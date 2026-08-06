import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, MinLength } from "class-validator";

export class RefreshTokenDto {
  @ApiProperty({ description: "Opaque refresh token string issued during login or OTP verification" })
  @IsNotEmpty()
  @IsString()
  @MinLength(1)
  refreshToken!: string;
}

