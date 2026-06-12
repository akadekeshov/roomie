import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class FacebookAuthDto {
  @ApiProperty({ description: 'OAuth access token from Facebook' })
  @IsString()
  @IsNotEmpty()
  accessToken!: string;

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
