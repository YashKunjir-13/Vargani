import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsUUID } from "class-validator";

export class AssignRoleDto {
  @ApiProperty({ example: "a0000000-0000-0000-0000-000000000001" })
  @IsNotEmpty()
  @IsUUID()
  roleId!: string;
}
