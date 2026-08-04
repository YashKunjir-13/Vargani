import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, Matches } from "class-validator";

export class ForgotMpinDto {
  @ApiProperty({ example: "9876543210", description: "Registered 10-digit mobile number" })
  @IsNotEmpty()
  @Matches(/^[6-9]\d{9}$/, { message: "phoneNumber must be a valid 10-digit mobile number" })
  phoneNumber!: string;
}
