import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, Matches } from 'class-validator';

export class BindMockCardDto {
  @ApiProperty({ example: '4242' })
  @IsString()
  @Matches(/^\d{4}$/, {
    message: 'Введите последние 4 цифры карты.',
  })
  cardLast4!: string;

  @ApiPropertyOptional({ example: 'VISA' })
  @IsOptional()
  @IsString()
  cardBrand?: string;
}
