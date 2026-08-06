import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsOptional, IsString, IsUUID, MinLength } from "class-validator";

export class TransferOwnershipDto {
  @ApiProperty({ example: "a0000000-0000-0000-0000-000000000001", description: "Target active same-org member user ID" })
  @IsNotEmpty()
  @IsUUID()
  newOwnerUserId!: string;

  @ApiProperty({ example: "Elected new president for 2026" })
  @IsNotEmpty()
  @IsString()
  @MinLength(5)
  reason!: string;

  @ApiProperty({ example: "b0000000-0000-0000-0000-000000000002", description: "Optional role ID for outgoing owner" })
  @IsOptional()
  @IsUUID()
  outgoingOwnerRoleId?: string;
}
