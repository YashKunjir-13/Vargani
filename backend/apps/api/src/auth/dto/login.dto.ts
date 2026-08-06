import { ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsString, Matches, MinLength } from "class-validator";

export class LoginDto {
  @ApiProperty({ example: "9876543210", description: "Valid 10-digit mobile number" })
  @IsNotEmpty()
  @Matches(/^[6-9]\d{9}$/, { message: "phoneNumber must be a valid 10-digit mobile number" })
  phoneNumber!: string;

  @ApiProperty({ example: "Pass#12345", description: "Account password" })
  @IsNotEmpty()
  @IsString()
  @MinLength(1)
  password!: string;

  @ApiProperty({ enum: ["MANDAL", "DONOR"], example: "DONOR", description: "Target account role context" })
  @IsNotEmpty()
  @IsEnum(["MANDAL", "DONOR"])
  role!: "MANDAL" | "DONOR";
}

