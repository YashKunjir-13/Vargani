import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsOptional, IsPhoneNumber, IsString, IsUUID, MinLength } from "class-validator";

export class CreateDirectMemberDto {
  @ApiProperty({ example: "New Member" })
  @IsNotEmpty()
  @IsString()
  displayName!: string;

  @ApiProperty({ example: "+919876543210" })
  @IsNotEmpty()
  @IsString()
  @IsPhoneNumber("IN")
  mobile!: string;

  @ApiProperty({ example: "a0000000-0000-0000-0000-000000000001" })
  @IsNotEmpty()
  @IsUUID()
  roleId!: string;

  @ApiProperty({ example: "Password#123" })
  @IsOptional()
  @IsString()
  @MinLength(8)
  password?: string;
}
