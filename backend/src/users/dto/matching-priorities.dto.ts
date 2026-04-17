import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsIn, IsOptional } from 'class-validator';

const LEVELS = ['required', 'important', 'neutral'] as const;
export type MatchingPriorityLevelDto = (typeof LEVELS)[number];

function normalizeLevel(value: unknown): unknown {
  if (typeof value !== 'string') return value;
  return value.trim().toLowerCase();
}

export class MatchingPrioritiesDto {
  @ApiPropertyOptional({ enum: LEVELS })
  @IsOptional()
  @Transform(({ value }) => normalizeLevel(value))
  @IsIn(LEVELS)
  budget?: MatchingPriorityLevelDto;

  @ApiPropertyOptional({ enum: LEVELS })
  @IsOptional()
  @Transform(({ value }) => normalizeLevel(value))
  @IsIn(LEVELS)
  district?: MatchingPriorityLevelDto;

  @ApiPropertyOptional({ enum: LEVELS })
  @IsOptional()
  @Transform(({ value }) => normalizeLevel(value))
  @IsIn(LEVELS)
  noisePreference?: MatchingPriorityLevelDto;

  @ApiPropertyOptional({ enum: LEVELS })
  @IsOptional()
  @Transform(({ value }) => normalizeLevel(value))
  @IsIn(LEVELS)
  smokingPreference?: MatchingPriorityLevelDto;

  @ApiPropertyOptional({ enum: LEVELS })
  @IsOptional()
  @Transform(({ value }) => normalizeLevel(value))
  @IsIn(LEVELS)
  petsPreference?: MatchingPriorityLevelDto;

  @ApiPropertyOptional({ enum: LEVELS })
  @IsOptional()
  @Transform(({ value }) => normalizeLevel(value))
  @IsIn(LEVELS)
  chronotype?: MatchingPriorityLevelDto;

  @ApiPropertyOptional({ enum: LEVELS })
  @IsOptional()
  @Transform(({ value }) => normalizeLevel(value))
  @IsIn(LEVELS)
  personalityType?: MatchingPriorityLevelDto;

  @ApiPropertyOptional({ enum: LEVELS })
  @IsOptional()
  @Transform(({ value }) => normalizeLevel(value))
  @IsIn(LEVELS)
  occupationStatus?: MatchingPriorityLevelDto;
}
