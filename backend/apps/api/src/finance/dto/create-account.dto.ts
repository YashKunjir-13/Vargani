import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsOptional, IsString, MaxLength } from "class-validator";
import { FinancialAccountType } from "@pauti-pustak/backend-database";

export class CreateAccountDto {
  @ApiProperty({ enum: FinancialAccountType, example: FinancialAccountType.BANK })
  @IsNotEmpty()
  @IsEnum(FinancialAccountType)
  type!: FinancialAccountType;

  @ApiProperty({ example: "State Bank of India Main Account" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(120)
  displayName!: string;

  @ApiPropertyOptional({ example: "XXXX-1234" })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  maskedIdentifier?: string;

  @ApiPropertyOptional({ example: "0", description: "Opening balance in paise" })
  @IsOptional()
  @IsString()
  openingBalancePaise?: string;
}
