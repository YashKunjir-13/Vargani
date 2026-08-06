import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString } from "class-validator";

export class VerifyPaymentSignatureDto {
  @ApiProperty({ example: "order_9f8e7d6c5b4a3f2e" })
  @IsNotEmpty()
  @IsString()
  razorpayOrderId!: string;

  @ApiProperty({ example: "pay_1a2b3c4d5e6f7g8h" })
  @IsNotEmpty()
  @IsString()
  razorpayPaymentId!: string;

  @ApiProperty({ example: "9f8e7d6c5b4a3f2e1a2b3c4d5e6f7g8h" })
  @IsNotEmpty()
  @IsString()
  razorpaySignature!: string;
}
