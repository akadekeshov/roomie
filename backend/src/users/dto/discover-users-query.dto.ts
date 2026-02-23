import { IsOptional, IsNumber, Min, Max, IsString, IsEnum } from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Gender } from '@prisma/client';

export class DiscoverUsersQueryDto {
  @ApiPropertyOptional({ example: 1, minimum: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 10, minimum: 1, maximum: 50 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(50)
  limit?: number = 10;

  @ApiPropertyOptional({ example: 150000, minimum: 0, description: 'Max budget per month (до X)' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  budgetMax?: number | null;

  @ApiPropertyOptional({
    example: 'Алмалинский р-н',
    description: 'District name; use "Все районы" or empty to ignore',
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  district?: string | null;

  @ApiPropertyOptional({ enum: Gender, description: 'Preferred roommate gender' })
  @IsOptional()
  @IsEnum(Gender)
  gender?: Gender | null;

  @ApiPropertyOptional({
    enum: ['18-25', '25+'],
    description: 'Age range filter',
  })
  @IsOptional()
  @IsString()
  ageRange?: '18-25' | '25+' | null;
}

