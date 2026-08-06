import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, IsUUID, MinLength } from "class-validator";

export class MergeContributorAccountsDto {
  @ApiProperty({ example: "c0000000-0000-0000-0000-000000000001", description: "Surviving contributor account ID" })
  @IsNotEmpty()
  @IsUUID()
  survivingAccountId!: string;

  @ApiProperty({ example: "c0000000-0000-0000-0000-000000000002", description: "Duplicate contributor account ID to merge" })
  @IsNotEmpty()
  @IsUUID()
  mergedAccountId!: string;

  @ApiProperty({ example: "Duplicate account created during area import" })
  @IsNotEmpty()
  @IsString()
  @MinLength(5)
  reason!: string;
}
