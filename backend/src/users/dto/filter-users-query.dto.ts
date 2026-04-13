import { Type } from 'class-transformer';
import {
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  Gender,
  NoisePreference,
  PetsPreference,
  SmokingPreference,
} from '@prisma/client';

export class FilterUsersQueryDto {
  @ApiPropertyOptional({ example: 1, minimum: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 20, minimum: 1, maximum: 50 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(50)
  limit?: number = 20;

  @ApiPropertyOptional({ example: 'Almaty' })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional({
    example: 'Алмалинский р-н',
    description: 'Preferred district / search area',
  })
  @IsOptional()
  @IsString()
  district?: string;

  @ApiPropertyOptional({
    example: 50000,
    minimum: 0,
    description: 'Minimum preferred budget per month',
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  priceMin?: number;

  @ApiPropertyOptional({
    example: 150000,
    minimum: 0,
    description: 'Maximum preferred budget per month',
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  priceMax?: number;

  @ApiPropertyOptional({ enum: Gender })
  @IsOptional()
  @IsEnum(Gender)
  gender?: Gender;

  @ApiPropertyOptional({ enum: PetsPreference })
  @IsOptional()
  @IsEnum(PetsPreference)
  petsPreference?: PetsPreference;

  @ApiPropertyOptional({ enum: SmokingPreference })
  @IsOptional()
  @IsEnum(SmokingPreference)
  smokingPreference?: SmokingPreference;

  @ApiPropertyOptional({ enum: NoisePreference })
  @IsOptional()
  @IsEnum(NoisePreference)
  noisePreference?: NoisePreference;
}

