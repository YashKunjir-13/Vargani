import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsInt, IsObject, IsOptional, Max, Min } from "class-validator";

export class UpdatePlatformSettingsDto {
  @ApiPropertyOptional({ example: { GANPATI: true, NAVRATRI: true, DIWALI: true } })
  @IsOptional()
  @IsObject()
  supportedEventTypes?: Record<string, any>;

  @ApiPropertyOptional({ example: 10485760 })
  @IsOptional()
  maxFileSizeBytes?: number;

  @ApiPropertyOptional({ example: 5242880 })
  @IsOptional()
  maxLogoSizeBytes?: number;

  @ApiPropertyOptional({ example: 5 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(20)
  maxAttachmentsPerEntity?: number;

  @ApiPropertyOptional({ example: { enableNewBillingUI: true } })
  @IsOptional()
  @IsObject()
  featureFlags?: Record<string, any>;
}
