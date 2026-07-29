import { ApiProperty } from "@nestjs/swagger";
import { PaymentChannel, PaymentStatus } from "@pauti-pustak/backend-database";
import { IsDateString, IsEnum, IsOptional, IsUUID } from "class-validator";

export class ListPaymentsQueryDto {
  @ApiProperty({ required: false, enum: PaymentStatus })
  @IsOptional()
  @IsEnum(PaymentStatus)
  status?: PaymentStatus;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsUUID()
  donorId?: string;

  @ApiProperty({ required: false, enum: PaymentChannel })
  @IsOptional()
  @IsEnum(PaymentChannel)
  channel?: PaymentChannel;

  @ApiProperty({ required: false, description: "ISO date, inclusive lower bound on paymentDateTime" })
  @IsOptional()
  @IsDateString()
  from?: string;

  @ApiProperty({ required: false, description: "ISO date, inclusive upper bound on paymentDateTime" })
  @IsOptional()
  @IsDateString()
  to?: string;
}
