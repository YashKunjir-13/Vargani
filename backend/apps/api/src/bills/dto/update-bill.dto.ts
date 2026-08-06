import { ApiProperty } from "@nestjs/swagger";
import { IsDateString, IsNotEmpty, IsNumber, IsOptional, IsPositive, IsString, IsUUID } from "class-validator";

/**
 * Every field here is editable -- but only while the bill is still Draft
 * (enforced in BillsService.update, not here). Once Pending Approval or
 * later, PATCH /bills/:id is rejected outright regardless of which fields
 * are sent.
 */
export class UpdateBillDto {
  @ApiProperty({ required: false, nullable: true })
  @IsOptional()
  @IsUUID()
  vendorId?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  receiverNameSnapshot?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  contactSnapshot?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  @IsPositive()
  amount?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsDateString()
  date?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNotEmpty()
  @IsString()
  taskOrField?: string;

  @ApiProperty({ required: false, nullable: true })
  @IsOptional()
  @IsUUID()
  milestoneId?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  billPhotoUrl?: string;
}
