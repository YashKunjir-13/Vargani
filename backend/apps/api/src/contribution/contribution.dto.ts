import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import {
  IsDateString,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Min,
} from "class-validator";

export class CreateContributionDto {
  @ApiPropertyOptional({ description: "Optional donor/contributor ID" })
  @IsOptional()
  @IsUUID()
  contributorId?: string;

  @ApiProperty({ description: "Snapshot name of contributor" })
  @IsNotEmpty()
  @IsString()
  contributorNameSnapshot!: string;

  @ApiPropertyOptional({ description: "Snapshot contact phone/email" })
  @IsOptional()
  @IsString()
  contactSnapshot?: string;

  @ApiProperty({ description: "Date of contribution (YYYY-MM-DD)" })
  @IsNotEmpty()
  @IsDateString()
  date!: string;

  @ApiProperty({
    description:
      "Type of donation: Gold, Silver, Electronic Goods, Decoration, Food, Music Band, or custom",
  })
  @IsNotEmpty()
  @IsString()
  donationType!: string;

  @ApiPropertyOptional({ description: "Detailed item description for physical goods" })
  @IsOptional()
  @IsString()
  itemDescription?: string;

  @ApiPropertyOptional({ description: "Weight in grams (Gold/Silver)" })
  @IsOptional()
  @IsNumber()
  @Min(0)
  weight?: number;

  @ApiPropertyOptional({ description: "Estimated monetary value in INR" })
  @IsOptional()
  @IsNumber()
  @Min(0)
  estimatedValue?: number;

  @ApiPropertyOptional({ description: "Purity/Pawn certificate photo URL" })
  @IsOptional()
  @IsString()
  certificatePhotoUrl?: string;
}

export class UpdateContributionDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  contributorNameSnapshot?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  contactSnapshot?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  donationType?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  itemDescription?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  weight?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  estimatedValue?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  certificatePhotoUrl?: string;
}
