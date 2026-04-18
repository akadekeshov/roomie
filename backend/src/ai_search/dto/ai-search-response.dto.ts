import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

class AiScoreBreakdownDto {
  @ApiProperty({ example: 0.81 })
  semanticSimilarity!: number;

  @ApiProperty({ example: 0.75 })
  lifestyleMatch!: number;

  @ApiProperty({ example: 0.8 })
  preferenceMatch!: number;

  @ApiProperty({ example: 0.7 })
  behavioralMatch!: number;

  @ApiProperty({ example: 0.9 })
  profileQuality!: number;

  @ApiProperty({ example: 0.79 })
  finalScore!: number;
}

class AiExplanationDto {
  @ApiProperty({
    example: 'Высокая семантическая близость по образу жизни и привычкам.',
  })
  semantic!: string;

  @ApiProperty({
    example: 'Предпочтения по курению и уровню шума совпадают.',
  })
  lifestyle!: string;

  @ApiProperty({
    example: 'Бюджет и предпочтения по полу соседа совместимы.',
  })
  preferences!: string;

  @ApiProperty({
    type: [String],
    example: ['smokingPreference', 'noisePreference'],
  })
  matchedFields!: string[];
}

class AiMatchedUserDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  firstName!: string;

  @ApiProperty()
  age!: number;

  @ApiProperty()
  city!: string;

  @ApiProperty()
  bio!: string;

  @ApiProperty({ type: [String] })
  photos!: string[];
}

class AiSearchResultItemDto {
  @ApiProperty({ type: AiMatchedUserDto })
  user!: AiMatchedUserDto;

  @ApiProperty({ example: 0.87 })
  score!: number;

  @ApiProperty({ type: AiScoreBreakdownDto })
  breakdown!: AiScoreBreakdownDto;

  @ApiProperty({ type: AiExplanationDto })
  explanation!: AiExplanationDto;
}

class AiSearchEmbeddingsMetaDto {
  @ApiProperty()
  profileEmbeddingId!: string;

  @ApiProperty()
  preferencesEmbeddingId!: string;

  @ApiProperty()
  queryEmbeddingId!: string;
}

class AiSearchMetaDto {
  @ApiProperty({ example: 'stage_6_pgvector_ready' })
  status!: string;

  @ApiProperty({ example: 20 })
  limit!: number;

  @ApiPropertyOptional({
    example: '0c3c06f4-3fa2-4378-b716-ac8a2a661040',
  })
  sessionId?: string;

  @ApiPropertyOptional({
    example: {
      smokingPreference: 'NON_SMOKER',
      preferredGender: 'FEMALE',
      noisePreference: 'QUIET',
    },
  })
  parsedFilters?: Record<string, unknown>;

  @ApiPropertyOptional({
    example: 0.8125,
  })
  profileCompleteness?: number;

  @ApiPropertyOptional({ type: AiSearchEmbeddingsMetaDto })
  embeddings?: AiSearchEmbeddingsMetaDto;
}

export class AiSearchResponseDto {
  @ApiProperty({ type: [AiSearchResultItemDto] })
  results!: AiSearchResultItemDto[];

  @ApiProperty({ type: AiSearchMetaDto })
  meta!: AiSearchMetaDto;
}
