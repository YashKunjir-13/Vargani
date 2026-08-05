import { ApiProperty } from "@nestjs/swagger";
import { PaymentChannel } from "@pauti-pustak/backend-database";
import { IsDateString, IsEnum, IsNotEmpty, IsNumber, IsOptional, IsPositive, IsString, IsUUID } from "class-validator";

export class CreatePaymentDto {
  @ApiProperty({ enum: PaymentChannel })
  @IsEnum(PaymentChannel)
  channel!: PaymentChannel;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  donorNameSnapshot!: string;

  @ApiProperty({ required: false, nullable: true, description: "Set only if the payer is a registered Donor" })
  @IsOptional()
  @IsUUID()
  donorId?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  addressSnapshot?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  contactSnapshot?: string;

  @ApiProperty()
  @IsNumber()
  @IsPositive()
  amount!: number;

  @ApiProperty({ required: false, description: "Defaults to now if omitted" })
  @IsOptional()
  @IsDateString()
  paymentDateTime?: string;

  @ApiProperty({
    required: false,
    nullable: true,
    description: "Volunteer/Treasurer who facilitated a QR-code payment on the ground",
  })
  @IsOptional()
  @IsUUID()
  collectedByUserId?: string;
}
