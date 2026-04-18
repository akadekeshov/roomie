import {
  HttpException,
  Injectable,
  InternalServerErrorException,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import {
  AiEmbeddingKind,
  AiSearchStatus,
  Prisma,
  UserRole,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AI_SEARCH_DEFAULT_LIMIT, AI_SEARCH_MAX_LIMIT } from './ai.constants';
import { AiEmbeddingService } from './ai-embedding.service';
import {
  AI_PROFILE_USER_SELECT,
  AiProfileBuilderService,
  AiUserProfileRecord,
} from './ai-profile-builder.service';
import { AiParserService } from './ai-parser.service';
import { AiScoringService } from './ai-scoring.service';
import { AiVectorSearchService } from './ai-vector-search.service';
import { AiQueryFilters } from './ai.types';
import { AiSearchRequestDto } from './dto/ai-search-request.dto';
import { AiSearchResponseDto } from './dto/ai-search-response.dto';

type RankedCandidate = {
  user: AiUserProfileRecord;
  score: number;
  breakdown: {
    semanticSimilarity: number;
    lifestyleMatch: number;
    preferenceMatch: number;
    behavioralMatch: number;
    profileQuality: number;
    finalScore: number;
  };
  explanation: {
    semantic: string;
    lifestyle: string;
    preferences: string;
    matchedFields: string[];
  };
};

@Injectable()
export class AiSearchService {
  private readonly logger = new Logger(AiSearchService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly aiParserService: AiParserService,
    private readonly aiProfileBuilderService: AiProfileBuilderService,
    private readonly aiEmbeddingService: AiEmbeddingService,
    private readonly aiScoringService: AiScoringService,
    private readonly aiVectorSearchService: AiVectorSearchService,
  ) {}

  async search(
    userId: string,
    dto: AiSearchRequestDto,
  ): Promise<AiSearchResponseDto> {
    const limit = this.normalizeLimit(dto.limit);
    const parsed = this.aiParserService.parse(dto.query);

    try {
      const profileContext =
        await this.aiProfileBuilderService.buildAndPersistForUser(userId);

      const [profileEmbedding, preferencesEmbedding, queryEmbedding] =
        await Promise.all([
          this.aiEmbeddingService.ensureProfileEmbedding(
            userId,
            profileContext.unifiedProfileId,
            profileContext.unified.profileText,
          ),
          this.aiEmbeddingService.ensurePreferencesEmbedding(
            userId,
            profileContext.unifiedProfileId,
            profileContext.preferencesText,
          ),
          this.aiEmbeddingService.createQueryEmbedding(
            userId,
            parsed.normalizedQuery,
          ),
        ]);

      const session = await this.prisma.aiSearchSession.create({
        data: {
          userId,
          query: dto.query,
          normalizedQuery: parsed.normalizedQuery,
          parsedFilters: {
            filters: parsed.filters,
            lifestyleSignals: parsed.lifestyleSignals,
            personalityHints: parsed.personalityHints,
            tokens: parsed.tokens.slice(0, 120),
          } as Prisma.InputJsonValue,
          queryEmbeddingId: queryEmbedding.id,
          status: AiSearchStatus.COMPLETED,
        },
      });

      const ranked = await this.rankCandidates({
        source: profileContext.user,
        queryEmbeddingVector: this.extractVector(queryEmbedding.vector),
        parsedFilters: parsed.filters,
        limit,
      });

      if (ranked.length > 0) {
        await this.prisma.aiSearchResult.createMany({
          data: ranked.map((item) => ({
            sessionId: session.id,
            targetUserId: item.user.id,
            semanticSimilarity: item.breakdown.semanticSimilarity,
            lifestyleMatch: item.breakdown.lifestyleMatch,
            preferenceMatch: item.breakdown.preferenceMatch,
            behavioralMatch: item.breakdown.behavioralMatch,
            profileQuality: item.breakdown.profileQuality,
            finalScore: item.breakdown.finalScore,
            matchedFields: item.explanation.matchedFields,
            explanation: item.explanation as Prisma.InputJsonValue,
          })),
        });
      }

      return {
        results: ranked.map((item) => ({
          user: {
            id: item.user.id,
            firstName: item.user.firstName ?? 'Пользователь',
            age: item.user.age ?? 0,
            city: item.user.city ?? '',
            bio: item.user.bio ?? '',
            photos: item.user.photos,
          },
          score: item.score,
          breakdown: item.breakdown,
          explanation: item.explanation,
        })),
        meta: {
          status: 'stage_6_pgvector_ready',
          limit,
          sessionId: session.id,
          parsedFilters: parsed.filters,
          profileCompleteness: Number(
            profileContext.unified.completeness.toFixed(4),
          ),
          embeddings: {
            profileEmbeddingId: profileEmbedding.id,
            preferencesEmbeddingId: preferencesEmbedding.id,
            queryEmbeddingId: queryEmbedding.id,
          },
        },
      };
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'AI search failed';
      this.logger.error(`AI search failed for user=${userId}: ${message}`);

      try {
        await this.prisma.aiSearchSession.create({
          data: {
            userId,
            query: dto.query,
            normalizedQuery: parsed.normalizedQuery,
            parsedFilters: {
              filters: parsed.filters,
              lifestyleSignals: parsed.lifestyleSignals,
              personalityHints: parsed.personalityHints,
              tokens: parsed.tokens.slice(0, 120),
            } as Prisma.InputJsonValue,
            status: AiSearchStatus.FAILED,
            errorMessage: message,
          },
        });
      } catch (sessionWriteError) {
        const details =
          sessionWriteError instanceof Error
            ? sessionWriteError.message
            : 'unknown session write error';
        this.logger.error(
          `Failed to persist failed ai_search_session: ${details}`,
        );
      }

      if (error instanceof HttpException) {
        throw error;
      }

      if (
        message.includes('OpenAI embeddings failed') ||
        message.includes('OPENAI_API_KEY')
      ) {
        throw new ServiceUnavailableException('AI-поиск временно недоступен');
      }

      throw new InternalServerErrorException('Не удалось выполнить AI-поиск');
    }
  }

  private async rankCandidates(input: {
    source: AiUserProfileRecord;
    queryEmbeddingVector: number[];
    parsedFilters: AiQueryFilters;
    limit: number;
  }): Promise<RankedCandidate[]> {
    const poolSize = Math.min(Math.max(input.limit * 4, 40), 140);
    const semanticPoolLimit = Math.min(poolSize * 4, 300);

    const semanticRows =
      await this.aiVectorSearchService.findNearestProfileEmbeddings(
        input.queryEmbeddingVector,
        {
          limit: semanticPoolLimit,
          excludeUserId: input.source.id,
        },
      );

    const semanticSimilarityByUser = new Map<string, number>();
    const semanticUserIds: string[] = [];
    for (const row of semanticRows) {
      if (!row.userId || semanticSimilarityByUser.has(row.userId)) {
        continue;
      }
      semanticSimilarityByUser.set(row.userId, row.similarity);
      semanticUserIds.push(row.userId);
    }

    let candidates = await this.fetchCandidates(
      input.source,
      input.parsedFilters,
      poolSize,
      semanticUserIds,
    );

    if (candidates.length === 0) {
      candidates = await this.fetchCandidates(
        input.source,
        input.parsedFilters,
        poolSize,
        [],
      );
    }

    if (candidates.length === 0) {
      return [];
    }

    const candidateIds = candidates.map((user) => user.id);
    const vectorByUser = await this.fetchCandidateVectors(candidateIds);

    const missingVectorUsers = candidates
      .filter((candidate) => !vectorByUser.has(candidate.id))
      .slice(0, 8);

    if (missingVectorUsers.length > 0) {
      await Promise.all(
        missingVectorUsers.map(async (candidate) => {
          const context =
            await this.aiProfileBuilderService.buildAndPersistFromRecord(
              candidate,
            );
          const embedding =
            await this.aiEmbeddingService.ensureProfileEmbedding(
              candidate.id,
              context.unifiedProfileId,
              context.unified.profileText,
            );
          vectorByUser.set(candidate.id, this.extractVector(embedding.vector));
        }),
      );
    }

    const ranked: RankedCandidate[] = [];

    for (const candidate of candidates) {
      const candidateProfile =
        this.aiProfileBuilderService.buildUnifiedProfile(candidate);
      const vector = vectorByUser.get(candidate.id) ?? [];
      const semanticSimilarity =
        semanticSimilarityByUser.get(candidate.id) ??
        this.aiScoringService.semanticSimilarity(
          input.queryEmbeddingVector,
          vector,
        );

      const lifestyle = this.aiScoringService.calculateLifestyleMatch(
        input.source,
        candidate,
        input.parsedFilters,
      );
      const preference = this.aiScoringService.calculatePreferenceMatch(
        input.source,
        candidate,
        input.parsedFilters,
      );
      const behavioralMatch =
        this.aiScoringService.calculateBehavioralMatch(candidate);
      const profileQuality = this.aiScoringService.calculateProfileQuality(
        candidateProfile.completeness,
        candidate.bio,
        candidate.photos,
      );

      const breakdown = this.aiScoringService.calculateBreakdown({
        semanticSimilarity,
        lifestyleMatch: lifestyle.score,
        preferenceMatch: preference.score,
        behavioralMatch,
        profileQuality,
      });

      const matchedFields = Array.from(
        new Set([
          ...lifestyle.matchedFields,
          ...preference.matchedFields,
          ...(semanticSimilarity >= 0.75 ? ['semanticIntent'] : []),
        ]),
      );

      ranked.push({
        user: candidate,
        score: breakdown.finalScore,
        breakdown: {
          semanticSimilarity: breakdown.semanticSimilarity,
          lifestyleMatch: breakdown.lifestyleMatch,
          preferenceMatch: breakdown.preferenceMatch,
          behavioralMatch: breakdown.behavioralMatch,
          profileQuality: breakdown.profileQuality,
          finalScore: breakdown.finalScore,
        },
        explanation: {
          semantic: `Семантическая близость между запросом и профилем составляет ${Math.round(
            breakdown.semanticSimilarity * 100,
          )}%.`,
          lifestyle: this.buildLifestyleExplanation(lifestyle.matchedFields),
          preferences: this.buildPreferenceExplanation(
            preference.matchedFields,
          ),
          matchedFields,
        },
      });
    }

    ranked.sort((a, b) => b.score - a.score);
    return ranked.slice(0, input.limit);
  }

  private async fetchCandidates(
    source: AiUserProfileRecord,
    parsedFilters: AiQueryFilters,
    take: number,
    prioritizedUserIds: string[],
  ): Promise<AiUserProfileRecord[]> {
    const baseWhere: Prisma.UserWhereInput = {
      id: { not: source.id },
      role: UserRole.USER,
      isBanned: false,
      onboardingCompleted: true,
      ...(source.city ? { city: source.city } : {}),
      ...(parsedFilters.preferredGender
        ? { gender: parsedFilters.preferredGender }
        : {}),
    };

    if (prioritizedUserIds.length > 0) {
      const candidates = await this.prisma.user.findMany({
        where: {
          ...baseWhere,
          id: { in: prioritizedUserIds },
        },
        select: AI_PROFILE_USER_SELECT,
      });

      if (candidates.length > 0) {
        const order = new Map(
          prioritizedUserIds.map((id, index) => [id, index] as const),
        );
        candidates.sort(
          (a, b) => (order.get(a.id) ?? 999999) - (order.get(b.id) ?? 999999),
        );
        return candidates.slice(0, take);
      }
    }

    const strictCandidates = await this.prisma.user.findMany({
      where: baseWhere,
      select: AI_PROFILE_USER_SELECT,
      orderBy: { updatedAt: 'desc' },
      take,
    });

    if (strictCandidates.length > 0 || !source.city) {
      return strictCandidates;
    }

    const relaxedWhere: Prisma.UserWhereInput = {
      ...baseWhere,
    };
    delete relaxedWhere.city;

    return this.prisma.user.findMany({
      where: relaxedWhere,
      select: AI_PROFILE_USER_SELECT,
      orderBy: { updatedAt: 'desc' },
      take,
    });
  }

  private async fetchCandidateVectors(
    candidateIds: string[],
  ): Promise<Map<string, number[]>> {
    if (candidateIds.length === 0) {
      return new Map<string, number[]>();
    }

    const rows = await this.prisma.aiEmbedding.findMany({
      where: {
        kind: AiEmbeddingKind.USER_PROFILE,
        userId: { in: candidateIds },
      },
      select: {
        userId: true,
        vector: true,
        generatedAt: true,
      },
      orderBy: [{ userId: 'asc' }, { generatedAt: 'desc' }],
    });

    const result = new Map<string, number[]>();
    for (const row of rows) {
      if (!row.userId || result.has(row.userId)) {
        continue;
      }
      result.set(row.userId, this.extractVector(row.vector));
    }

    return result;
  }

  private buildLifestyleExplanation(matched: string[]): string {
    if (matched.length === 0) {
      return 'Явных совпадений по образу жизни не найдено, совместимость умеренная.';
    }
    return `Совпадения по образу жизни: ${matched.join(', ')}.`;
  }

  private buildPreferenceExplanation(matched: string[]): string {
    if (matched.length === 0) {
      return 'Совпадение предпочтений частичное: бюджет и локация совпадают не полностью.';
    }
    return `Совпадения по предпочтениям: ${matched.join(', ')}.`;
  }

  private extractVector(value: Prisma.JsonValue): number[] {
    if (!Array.isArray(value)) {
      return [];
    }
    const result: number[] = [];
    for (const item of value) {
      if (typeof item === 'number' && Number.isFinite(item)) {
        result.push(item);
      } else if (typeof item === 'string') {
        const parsed = Number(item);
        if (Number.isFinite(parsed)) {
          result.push(parsed);
        }
      }
    }
    return result;
  }

  private normalizeLimit(limit: number | undefined): number {
    if (!limit) {
      return AI_SEARCH_DEFAULT_LIMIT;
    }
    if (limit < 1) {
      return 1;
    }
    return Math.min(limit, AI_SEARCH_MAX_LIMIT);
  }
}
