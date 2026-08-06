import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsOptional, IsString, MaxLength } from "class-validator";

export class ConfigureBankingDto {
  @ApiPropertyOptional({ example: "ABCDE1234F" })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  panNumber?: string;

  @ApiPropertyOptional({ example: "912345678901" })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  accountNumber?: string;

  @ApiPropertyOptional({ example: "SBIN0001234" })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  ifscCode?: string;

  @ApiPropertyOptional({ example: "mandal@upi" })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  upiId?: string;
}
