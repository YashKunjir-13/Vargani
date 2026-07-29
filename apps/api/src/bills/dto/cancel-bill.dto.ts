import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString } from "class-validator";

export class CancelBillDto {
  @ApiProperty({ description: "Mandatory justification, recorded to the audit trail" })
  @IsNotEmpty()
  @IsString()
  reason!: string;
}
