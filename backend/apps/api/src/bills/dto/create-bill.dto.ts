import { ApiProperty } from "@nestjs/swagger";
import { IsDateString, IsNotEmpty, IsNumber, IsOptional, IsPositive, IsString, IsUUID } from "class-validator";

export class CreateBillDto {
  @ApiProperty({ required: false, nullable: true, description: "Set if the receiver is a registered Vendor" })
  @IsOptional()
  @IsUUID()
  vendorId?: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  receiverNameSnapshot!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  contactSnapshot?: string;

  @ApiProperty()
  @IsNumber()
  @IsPositive()
  amount!: number;

  @ApiProperty()
  @IsDateString()
  date!: string;

  @ApiProperty({ description: "The task/field this expense relates to" })
  @IsNotEmpty()
  @IsString()
  taskOrField!: string;

  @ApiProperty({ required: false, nullable: true })
  @IsOptional()
  @IsUUID()
  milestoneId?: string;

  @ApiProperty({ required: false, description: "URL of an already-uploaded photo of the physical vendor bill" })
  @IsOptional()
  @IsString()
  billPhotoUrl?: string;
}
