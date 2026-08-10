import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsNumber, IsOptional, IsPositive, IsString, IsUUID } from "class-validator";

export class CollectDonationDto {
  @ApiProperty({ description: "Donor full name snapshot" })
  @IsNotEmpty()
  @IsString()
  donorNameSnapshot!: string;

  @ApiProperty({ required: false, description: "Donor mobile contact number" })
  @IsOptional()
  @IsString()
  contactSnapshot?: string;

  @ApiProperty({ required: false, description: "Donor address snapshot" })
  @IsOptional()
  @IsString()
  addressSnapshot?: string;

  @ApiProperty({ description: "Donation amount in Rupees" })
  @IsNumber()
  @IsPositive()
  amount!: number;

  @ApiProperty({ description: "Payment method: Cash, UPI, Net Banking, Cheque" })
  @IsNotEmpty()
  @IsString()
  paymentMethod!: string;

  @ApiProperty({ required: false, nullable: true, description: "Optional UUID if payer is registered Donor" })
  @IsOptional()
  @IsUUID()
  donorId?: string;
}
