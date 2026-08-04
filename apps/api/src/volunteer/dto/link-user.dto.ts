import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsUUID } from "class-validator";

export class LinkUserDto {
  @ApiProperty({ example: "u0000000-0000-0000-0000-000000000001", description: "Target identity user ID" })
  @IsNotEmpty()
  @IsUUID()
  linkedUserId!: string;
}
