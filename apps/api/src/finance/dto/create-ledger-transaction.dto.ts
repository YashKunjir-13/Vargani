import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import { ArrayMinSize, IsArray, IsEnum, IsNotEmpty, IsOptional, IsString, ValidateNested } from "class-validator";
import { LedgerAccountClass, LedgerEntrySide, LedgerTransactionType } from "@pauti-pustak/backend-database";

export class LedgerEntryLineDto {
  @ApiProperty({ example: "CASH_ON_HAND" })
  @IsNotEmpty()
  @IsString()
  accountCode!: string;

  @ApiProperty({ enum: LedgerAccountClass, example: LedgerAccountClass.ASSET })
  @IsNotEmpty()
  @IsEnum(LedgerAccountClass)
  accountClass!: LedgerAccountClass;

  @ApiProperty({ enum: LedgerEntrySide, example: LedgerEntrySide.DEBIT })
  @IsNotEmpty()
  @IsEnum(LedgerEntrySide)
  side!: LedgerEntrySide;

  @ApiProperty({ example: "500000", description: "Amount in paise" })
  @IsNotEmpty()
  @IsString()
  amountPaise!: string;

  @ApiPropertyOptional({ example: "acc-0000-0000-0000-000000000001" })
  @IsOptional()
  @IsString()
  financialAccountId?: string;
}

export class CreateLedgerTransactionDto {
  @ApiProperty({ enum: LedgerTransactionType, example: LedgerTransactionType.DONATION_RECEIPT })
  @IsNotEmpty()
  @IsEnum(LedgerTransactionType)
  type!: LedgerTransactionType;

  @ApiProperty({ example: "COLLECTION_RECORD" })
  @IsNotEmpty()
  @IsString()
  sourceType!: string;

  @ApiProperty({ example: "c0000000-0000-0000-0000-000000000001" })
  @IsNotEmpty()
  @IsString()
  sourceId!: string;

  @ApiProperty({ example: "IDEM-LEDGER-12345" })
  @IsNotEmpty()
  @IsString()
  idempotencyKey!: string;

  @ApiPropertyOptional({ example: "Donation receipt collection entry" })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ type: [LedgerEntryLineDto] })
  @IsArray()
  @ArrayMinSize(2)
  @ValidateNested({ each: true })
  @Type(() => LedgerEntryLineDto)
  entries!: LedgerEntryLineDto[];
}
