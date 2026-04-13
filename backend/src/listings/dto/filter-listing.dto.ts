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
  RoomType,
  SmokingPreference,
} from '@prisma/client';

export class FilterListingDto {
  @ApiPropertyOptional({ example: 1, minimum: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 20, minimum: 1, maximum: 100 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  @ApiPropertyOptional({ example: 'Almaty' })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional({ example: 50000, minimum: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  priceMin?: number;

  @ApiPropertyOptional({ example: 150000, minimum: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  priceMax?: number;

  @ApiPropertyOptional({ enum: RoomType })
  @IsOptional()
  @IsEnum(RoomType)
  roomType?: RoomType;

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

  @ApiPropertyOptional({
    example: '2026-03-15',
    description: 'Minimum available from date (ISO string)',
  })
  @IsOptional()
  @IsString()
  availableFrom?: string;

  @ApiPropertyOptional({
    example: '2026-04-01',
    description: 'Maximum available to date (ISO string)',
  })
  @IsOptional()
  @IsString()
  availableTo?: string;
}

