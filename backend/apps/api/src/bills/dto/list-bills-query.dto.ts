import { ApiProperty } from "@nestjs/swagger";
import { BillStatus } from "@pauti-pustak/backend-database";
import { IsDateString, IsEnum, IsOptional, IsString, IsUUID } from "class-validator";

export class ListBillsQueryDto {
  @ApiProperty({ required: false, enum: BillStatus })
  @IsOptional()
  @IsEnum(BillStatus)
  status?: BillStatus;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsUUID()
  vendorId?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  taskOrField?: string;

  @ApiProperty({ required: false, description: "ISO date, inclusive lower bound on date" })
  @IsOptional()
  @IsDateString()
  from?: string;

  @ApiProperty({ required: false, description: "ISO date, inclusive upper bound on date" })
  @IsOptional()
  @IsDateString()
  to?: string;
}
