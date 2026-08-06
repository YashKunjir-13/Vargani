import { ApiProperty } from "@nestjs/swagger";
import { DevicePlatform } from "@pauti-pustak/backend-database";
import { IsEnum, IsNotEmpty, IsString } from "class-validator";

export class RegisterDeviceTokenDto {
  @ApiProperty({ description: "FCM / APNs device token string", example: "fcm_token_xyz_123" })
  @IsString()
  @IsNotEmpty()
  deviceToken: string;

  @ApiProperty({ description: "Target mobile or web platform", enum: DevicePlatform, example: DevicePlatform.ANDROID })
  @IsEnum(DevicePlatform)
  platform: DevicePlatform;
}
