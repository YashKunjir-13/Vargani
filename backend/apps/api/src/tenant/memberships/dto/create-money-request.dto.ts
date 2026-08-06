import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsNumber, IsString, IsUUID, Min } from "class-validator";

export class CreateMoneyRequestDto {
  @ApiProperty({ description: "Target member user ID to request money from" })
  @IsNotEmpty()
  @IsUUID()
  targetUserId!: string;

  @ApiProperty({ description: "Amount requested in INR", example: 5000 })
  @IsNotEmpty()
  @IsNumber()
  @Min(1)
  amount!: number;

  @ApiProperty({ description: "Reason or purpose for money request", example: "Ganpati decoration expenses" })
  @IsNotEmpty()
  @IsString()
  reason!: string;
}
