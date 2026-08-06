import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, Matches } from "class-validator";

export class ConfirmUploadDto {
  @ApiProperty({ example: "524288", description: "Actual uploaded file size in bytes" })
  @IsNotEmpty()
  @Matches(/^[1-9]\d*$/, { message: "fileSizeBytes must be a positive integer string" })
  fileSizeBytes!: string;

  @ApiProperty({ example: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" })
  @IsNotEmpty()
  @IsString()
  sha256!: string;
}
