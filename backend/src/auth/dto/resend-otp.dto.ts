import { IsEnum, IsString, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { OTPChannel, OTPPurpose } from '@prisma/client';

export class ResendOtpDto {
  @ApiProperty({ enum: OTPChannel, example: 'EMAIL' })
  @IsEnum(OTPChannel)
  channel: OTPChannel;

  @ApiProperty({ example: 'user@example.com or +77767767676' })
  @IsString()
  target: string;

  @ApiProperty({ enum: OTPPurpose, example: 'REGISTER' })
  @IsEnum(OTPPurpose)
  purpose: OTPPurpose;
}
