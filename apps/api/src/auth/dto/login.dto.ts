import { IsEnum, IsString, Matches, MinLength } from "class-validator";

export class LoginDto {
  @Matches(/^[6-9]\d{9}$/, { message: "phoneNumber must be a valid 10-digit mobile number" })
  phoneNumber!: string;

  @IsString()
  @MinLength(1)
  password!: string;

  @IsEnum(['MANDAL', 'DONOR'])
  role!: 'MANDAL' | 'DONOR';
}
