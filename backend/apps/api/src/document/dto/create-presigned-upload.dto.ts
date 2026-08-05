import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { DocumentPurpose } from "@pauti-pustak/backend-database";
import { IsEnum, IsNotEmpty, IsOptional, IsString, MaxLength } from "class-validator";

export class CreatePresignedUploadDto {
  @ApiProperty({ example: "mandal_stamp.png" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(250)
  filename!: string;

  @ApiProperty({ example: "image/png" })
  @IsNotEmpty()
  @IsString()
  contentType!: string;

  @ApiProperty({ enum: DocumentPurpose, example: DocumentPurpose.ORGANIZATION_STAMP })
  @IsNotEmpty()
  @IsEnum(DocumentPurpose)
  purpose!: DocumentPurpose;

  @ApiPropertyOptional({ example: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" })
  @IsOptional()
  @IsString()
  sha256?: string;
}
