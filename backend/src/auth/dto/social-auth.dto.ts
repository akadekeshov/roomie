import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsOptional,
  IsString,
  ValidateIf,
  IsNotEmpty,
  IsEmail,
} from 'class-validator';

export enum SocialProvider {
  GOOGLE = 'GOOGLE',
  FACEBOOK = 'FACEBOOK',
}

export class SocialAuthDto {
  @ApiProperty({ enum: SocialProvider, example: SocialProvider.GOOGLE })
  @IsEnum(SocialProvider)
  provider: SocialProvider;

  @ApiPropertyOptional({ description: 'OIDC id_token from provider' })
  @ValidateIf((o) => !o.accessToken)
  @IsString()
  @IsNotEmpty()
  idToken?: string;

  @ApiPropertyOptional({ description: 'OAuth access token from provider' })
  @ValidateIf((o) => !o.idToken)
  @IsString()
  @IsNotEmpty()
  accessToken?: string;

  @ApiPropertyOptional({ description: 'Device id/fingerprint for future use' })
  @IsOptional()
  @IsString()
  deviceId?: string;

  @ApiPropertyOptional({ description: 'Device name for future use' })
  @IsOptional()
  @IsString()
  deviceName?: string;

  @ApiPropertyOptional({ description: 'Optional fallback email from client' })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ description: 'Optional fallback name from client' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ description: 'Optional fallback avatar URL from client' })
  @IsOptional()
  @IsString()
  avatarUrl?: string;
}

