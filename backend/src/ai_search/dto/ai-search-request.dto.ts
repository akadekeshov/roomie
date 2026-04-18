import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';

export class AiSearchRequestDto {
  @ApiProperty({
    example: 'Найди спокойную соседку, которая не курит',
    description: 'Поисковый запрос на естественном языке',
  })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  @MaxLength(500)
  query!: string;

  @ApiPropertyOptional({
    example: 20,
    description: 'Желаемое количество результатов',
    minimum: 1,
    maximum: 50,
  })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number;
}
