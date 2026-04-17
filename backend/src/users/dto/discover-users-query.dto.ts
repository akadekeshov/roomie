import { Transform, Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Gender } from '@prisma/client';
import { IsEnum, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';

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

  @ApiPropertyOptional({
    example: 150000,
    minimum: 0,
    description: 'Maximum monthly budget',
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  budgetMax?: number | null;

  @ApiPropertyOptional({
    example: 'Almalinsky district',
    description: 'District name; use "All districts" or leave empty to ignore',
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
