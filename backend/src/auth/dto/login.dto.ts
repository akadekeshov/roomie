import {
  IsEmail,
  IsString,
  ValidateIf,
  IsNotEmpty,
  Matches,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class LoginDto {
  @ApiPropertyOptional({ example: 'user@example.com' })
  @ValidateIf((o) => !o.phone)
  @IsNotEmpty({ message: 'Either email or phone must be provided' })
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ example: '+77767767676' })
  @ValidateIf((o) => !o.email)
  @IsNotEmpty({ message: 'Either email or phone must be provided' })
  @IsString()
  @Matches(/^\+[1-9]\d{1,14}$/, {
    message: 'Phone must be in E.164 format (e.g., +77767767676)',
  })
  phone?: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  @IsNotEmpty()
  password: string;
}
