import { ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsString, MinLength } from "class-validator";
import { UserStatus } from "@pauti-pustak/backend-database";

export class UpdateUserStatusDto {
  @ApiProperty({ enum: UserStatus, example: UserStatus.DEACTIVATED })
  @IsNotEmpty()
  @IsEnum(UserStatus)
  status!: UserStatus;

  @ApiProperty({ example: "Violation of terms of service" })
  @IsNotEmpty()
  @IsString()
  @MinLength(5)
  reason!: string;
}
