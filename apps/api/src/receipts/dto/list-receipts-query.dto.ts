import { ApiProperty } from "@nestjs/swagger";
import { PaymentReceiptStatus } from "@pauti-pustak/backend-database";
import { IsDateString, IsEnum, IsOptional, IsUUID } from "class-validator";

export class ListReceiptsQueryDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsUUID()
  donorId?: string;

  @ApiProperty({ required: false, enum: PaymentReceiptStatus })
  @IsOptional()
  @IsEnum(PaymentReceiptStatus)
  status?: PaymentReceiptStatus;

  @ApiProperty({ required: false, description: "ISO date, inclusive lower bound on issuedDate" })
  @IsOptional()
  @IsDateString()
  from?: string;

  @ApiProperty({ required: false, description: "ISO date, inclusive upper bound on issuedDate" })
  @IsOptional()
  @IsDateString()
  to?: string;
}
