import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  ValidateIf,
} from 'class-validator';

export class GoogleAuthDto {
  @ApiPropertyOptional({ description: 'OIDC id_token from Google' })
  @ValidateIf((o) => !o.accessToken)
  @IsString()
  @IsNotEmpty()
  idToken?: string;

  @ApiPropertyOptional({ description: 'OAuth access token from Google' })
  @ValidateIf((o) => !o.idToken)
  @IsString()
  @IsNotEmpty()
  accessToken?: string;

  @ApiPropertyOptional({ description: 'Optional fallback email from client' })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ description: 'Optional fallback name from client' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({
    description: 'Optional fallback avatar URL from client',
  })
  @IsOptional()
  @IsString()
  avatarUrl?: string;
}
