import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsUUID } from "class-validator";

export class SelectOrganizationDto {
  @ApiProperty({ example: "00000000-0000-4000-a000-000000000001" })
  @IsNotEmpty()
  @IsUUID()
  organizationId!: string;
}
