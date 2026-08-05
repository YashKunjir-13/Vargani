import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, IsUUID } from "class-validator";

export class GenerateContributionReceiptDto {
  @ApiProperty({ description: "ID of the finalized contribution" })
  @IsNotEmpty()
  @IsUUID()
  contributionId!: string;
}

export class VoidContributionReceiptDto {
  @ApiProperty({ description: "Mandatory reason for voiding contribution receipt" })
  @IsNotEmpty()
  @IsString()
  reason!: string;
}
