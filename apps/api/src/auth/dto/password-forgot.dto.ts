import { ApiProperty } from "@nestjs/swagger";
import { IsEmail, IsNotEmpty, IsString } from "class-validator";

export class PasswordForgotDto {
  @ApiProperty({ example: "user@example.com" })
  @IsNotEmpty()
  @IsString()
  @IsEmail()
  email!: string;
}
