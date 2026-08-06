import { ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsOptional, IsString } from "class-validator";
import { MembershipStatus } from "@pauti-pustak/backend-database";

export class UpdateMembershipStatusDto {
  @ApiProperty({ enum: MembershipStatus, example: MembershipStatus.INACTIVE })
  @IsNotEmpty()
  @IsEnum(MembershipStatus)
  status!: MembershipStatus;

  @ApiProperty({ example: "Temporarily on leave" })
  @IsOptional()
  @IsString()
  reason?: string;
}
