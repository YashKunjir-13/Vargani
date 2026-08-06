import { ApiProperty } from "@nestjs/swagger";
import { IsOptional, IsString } from "class-validator";

/**
 * Only address/contact are ever editable, and only while a payment is still
 * Pending Match (enforced in PaymentsService.update, not here) -- core
 * fields (amount, donor identity, date) are never exposed on this DTO, so
 * the global ValidationPipe's forbidNonWhitelisted rejects any attempt to
 * send them.
 */
export class UpdatePaymentDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  addressSnapshot?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  contactSnapshot?: string;
}
