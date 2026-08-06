import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsEmail, IsOptional, IsPhoneNumber, IsString } from "class-validator";

export class ChangeContactDto {
  @ApiPropertyOptional({ example: "+919876543210" })
  @IsOptional()
  @IsString()
  @IsPhoneNumber("IN")
  newMobile?: string;

  @ApiPropertyOptional({ example: "new.email@example.com" })
  @IsOptional()
  @IsString()
  @IsEmail()
  newEmail?: string;
}
