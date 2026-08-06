import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsOptional, IsString } from "class-validator";

export class CreateNotificationTemplateDto {
  @ApiProperty({ description: "Unique template code identifier", example: "RECEIPT_ISSUED_V2" })
  @IsString()
  @IsNotEmpty()
  code: string;

  @ApiProperty({ description: "Template display name", example: "Receipt Issuance Notification" })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ description: "Channel type", example: "WHATSAPP" })
  @IsString()
  @IsNotEmpty()
  channel: string;

  @ApiProperty({ description: "Subject pattern (for email)", required: false })
  @IsString()
  @IsOptional()
  subjectPattern?: string;

  @ApiProperty({ description: "Body pattern text with {{variable}} placeholders" })
  @IsString()
  @IsNotEmpty()
  bodyPattern: string;

  @ApiProperty({ description: "ISO Language Code", example: "en", default: "en" })
  @IsString()
  @IsOptional()
  languageCode?: string;
}
