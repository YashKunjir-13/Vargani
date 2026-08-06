import { ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsOptional, IsPhoneNumber, IsString, IsUUID } from "class-validator";
import { InvitationDeliveryMethod } from "@pauti-pustak/backend-database";

export class CreateInvitationDto {
  @ApiProperty({ example: "a0000000-0000-0000-0000-000000000001", description: "Target role ID" })
  @IsNotEmpty()
  @IsUUID()
  roleId!: string;

  @ApiProperty({ enum: InvitationDeliveryMethod, example: InvitationDeliveryMethod.MOBILE })
  @IsNotEmpty()
  @IsEnum(InvitationDeliveryMethod)
  deliveryMethod!: InvitationDeliveryMethod;

  @ApiProperty({ example: "+919876543210" })
  @IsOptional()
  @IsString()
  @IsPhoneNumber("IN")
  targetMobile?: string;

  @ApiProperty({ example: "member@example.com" })
  @IsOptional()
  @IsString()
  targetEmail?: string;
}
