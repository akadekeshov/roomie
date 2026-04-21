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
import { UsersService } from '../users/users.service';
import { AI_SEARCH_DEFAULT_LIMIT, AI_SEARCH_MAX_LIMIT } from './ai.constants';
import { AiEmbeddingService } from './ai-embedding.service';
import {
  AI_PROFILE_USER_SELECT,
  AiProfileBuilderService,
  AiUserProfileRecord,
} from './ai-profile-builder.service';
import { AiParserService } from './ai-parser.service';
import { AiVectorSearchService } from './ai-vector-search.service';
import { AiQueryFilters } from './ai.types';
import { AiSearchRequestDto } from './dto/ai-search-request.dto';
import { AiSearchResponseDto } from './dto/ai-search-response.dto';

type SearchCandidate = {
  user: AiUserProfileRecord;
  semanticSimilarity: number;
  lexicalScore: number;
  filterScore: number;
  searchRelevance: number;
};

type SharedRecommendation = Awaited<
  ReturnType<UsersService['getPersonalizedRecommendations']>
>['data'][number];

type ScoredSearchResult = {
  recommendation: SharedRecommendation;
  user: SharedRecommendation;
  semanticSimilarity: number;
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
    private readonly aiVectorSearchService: AiVectorSearchService,
    private readonly usersService: UsersService,
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

      const searchCandidates = await this.findSearchCandidates({
        source: profileContext.user,
        queryEmbeddingVector: this.extractVector(queryEmbedding.vector),
        queryTokens: parsed.tokens,
        parsedFilters: parsed.filters,
        limit,
      });
      const scored = await this.scoreWithSharedCompatibility({
        currentUserId: userId,
        searchCandidates,
        parsedFilters: parsed.filters,
        limit,
      });

      if (scored.length > 0) {
        await this.prisma.aiSearchResult.createMany({
          data: scored.map((item) => ({
            sessionId: session.id,
            targetUserId: item.recommendation.id,
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
        results: scored.map((item) => ({
          user: {
            id: item.recommendation.id,
            firstName: item.recommendation.firstName ?? 'Пользователь',
            age: item.recommendation.age ?? 0,
            city: item.recommendation.city ?? '',
            bio: item.recommendation.bio ?? '',
            photos: item.recommendation.photos,
          },
          score: item.score,
          breakdown: item.breakdown,
          explanation: item.explanation,
        })),
        meta: {
          status: 'shared_compatibility_scoring',
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

  private async findSearchCandidates(input: {
    source: AiUserProfileRecord;
    queryEmbeddingVector: number[];
    queryTokens: string[];
    parsedFilters: AiQueryFilters;
    limit: number;
  }): Promise<SearchCandidate[]> {
    const poolSize = Math.min(Math.max(input.limit * 12, 160), 500);
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

    if (semanticUserIds.length > 0) {
      const fallbackCandidates = await this.fetchCandidates(
        input.source,
        input.parsedFilters,
        poolSize,
        [],
      );
      const byId = new Map(
        candidates.map((candidate) => [candidate.id, candidate]),
      );
      for (const candidate of fallbackCandidates) {
        if (!byId.has(candidate.id)) {
          byId.set(candidate.id, candidate);
        }
      }
      candidates = Array.from(byId.values());
    }

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

    const missingVectorUsers = candidates.filter(
      (candidate) => !vectorByUser.has(candidate.id),
    );

    if (missingVectorUsers.length > 0) {
      await this.runWithConcurrency(
        missingVectorUsers.slice(0, this.embeddingGenerationLimit()),
        4,
        async (candidate) => {
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
        },
      );
    }

    const ranked = candidates.map((candidate) => {
      const vector = vectorByUser.get(candidate.id) ?? [];
      const semanticSimilarity =
        semanticSimilarityByUser.get(candidate.id) ??
        this.semanticSimilarity(input.queryEmbeddingVector, vector);
      const lexicalScore = this.lexicalMatchScore(input.queryTokens, candidate);
      const filterScore = this.filterMatchScore(input.parsedFilters, candidate);
      const searchRelevance = this.computeSearchRelevance({
        semanticSimilarity,
        lexicalScore,
        filterScore,
      });

      return {
        user: candidate,
        semanticSimilarity,
        lexicalScore,
        filterScore,
        searchRelevance,
      };
    });

    const hasQuerySignal =
      input.queryTokens.length > 0 ||
      Object.keys(input.parsedFilters).length > 0;
    const hasUsableSemanticVector = input.queryEmbeddingVector.length >= 512;
    const relevant = hasQuerySignal
      ? ranked.filter(
          (candidate) =>
            (hasUsableSemanticVector && candidate.semanticSimilarity >= 0.62) ||
            candidate.lexicalScore > 0 ||
            candidate.filterScore > 0,
        )
      : ranked;

    relevant.sort(
      (a, b) =>
        b.searchRelevance - a.searchRelevance ||
        b.semanticSimilarity - a.semanticSimilarity,
    );
    return relevant.slice(0, input.limit);
  }

  private async scoreWithSharedCompatibility(input: {
    currentUserId: string;
    searchCandidates: SearchCandidate[];
    parsedFilters: AiQueryFilters;
    limit: number;
  }): Promise<ScoredSearchResult[]> {
    if (input.searchCandidates.length === 0) {
      return [];
    }

    const semanticByUserId = new Map(
      input.searchCandidates.map((candidate) => [
        candidate.user.id,
        candidate.semanticSimilarity,
      ]),
    );
    const relevanceByUserId = new Map(
      input.searchCandidates.map((candidate, index) => [
        candidate.user.id,
        {
          index,
          searchRelevance: candidate.searchRelevance,
        },
      ]),
    );
    const candidateUserIds = input.searchCandidates.map(
      (candidate) => candidate.user.id,
    );
    const scored = await this.usersService.getPersonalizedRecommendations(
      input.currentUserId,
      1,
      Math.max(input.limit, candidateUserIds.length),
      {
        candidateUserIds,
        gender: input.parsedFilters.preferredGender ?? null,
      },
    );

    const queryOrdered = [...scored.data].sort((left, right) => {
      const leftRelevance = relevanceByUserId.get(left.id);
      const rightRelevance = relevanceByUserId.get(right.id);
      return (
        (rightRelevance?.searchRelevance ?? 0) -
          (leftRelevance?.searchRelevance ?? 0) ||
        (leftRelevance?.index ?? 999999) - (rightRelevance?.index ?? 999999)
      );
    });

    return queryOrdered.slice(0, input.limit).map((recommendation) => {
      const finalScore = this.normalizePercent(
        recommendation.finalScore ??
          recommendation.matchPercent ??
          recommendation.compatibility ??
          0,
      );
      const normalizedScore = this.percentToRatio(finalScore);
      const semanticSimilarity =
        semanticByUserId.get(recommendation.id) ?? normalizedScore;
      const matchedFields = this.toStringArray(
        recommendation.compatibilityBreakdown?.matchedCriteria,
      );
      const partialFields = this.toStringArray(
        recommendation.compatibilityBreakdown?.partiallyMatchedCriteria,
      );
      const requiredMismatches = this.toStringArray(
        recommendation.compatibilityBreakdown?.requiredMismatches,
      );
      const criterionScores = this.toNumberRecord(
        recommendation.compatibilityBreakdown?.criterionScores,
      );

      const lifestyleMatch = this.averageCriteria(criterionScores, [
        'noisePreference',
        'smokingPreference',
        'petsPreference',
        'chronotype',
        'personalityType',
        'occupationStatus',
      ]);
      const preferenceMatch = this.averageCriteria(criterionScores, [
        'budget',
        'district',
        'roommateGenderPreference',
      ]);

      return {
        recommendation,
        user: recommendation,
        semanticSimilarity,
        score: normalizedScore,
        breakdown: {
          semanticSimilarity,
          lifestyleMatch,
          preferenceMatch,
          behavioralMatch: 0,
          profileQuality: 0,
          finalScore: normalizedScore,
        },
        explanation: {
          semantic:
            'Совместимость рассчитана общим алгоритмом, как на главном экране.',
          lifestyle: this.buildSharedLifestyleExplanation(
            matchedFields,
            partialFields,
          ),
          preferences: this.buildSharedPreferenceExplanation(
            matchedFields,
            requiredMismatches,
          ),
          matchedFields,
        },
      };
    });
  }

  private computeSearchRelevance(input: {
    semanticSimilarity: number;
    lexicalScore: number;
    filterScore: number;
  }): number {
    return this.clamp01(
      input.semanticSimilarity * 0.8 +
        input.lexicalScore * 0.15 +
        input.filterScore * 0.05,
    );
  }

  private embeddingGenerationLimit(): number {
    const raw = Number(process.env.AI_SEARCH_PROFILE_EMBED_LIMIT ?? '120');
    if (!Number.isFinite(raw)) {
      return 120;
    }
    return Math.min(Math.max(Math.floor(raw), 0), 500);
  }

  private async runWithConcurrency<T>(
    items: T[],
    concurrency: number,
    worker: (item: T) => Promise<void>,
  ): Promise<void> {
    if (items.length === 0) {
      return;
    }

    let index = 0;
    const safeConcurrency = Math.max(1, Math.min(concurrency, items.length));
    const workers = Array.from({ length: safeConcurrency }, async () => {
      while (index < items.length) {
        const item = items[index];
        index += 1;
        await worker(item);
      }
    });

    await Promise.all(workers);
  }

  private lexicalMatchScore(
    rawTokens: string[],
    candidate: AiUserProfileRecord,
  ): number {
    const tokens = rawTokens
      .map((token) => this.normalizeSearchToken(token))
      .filter((token) => token.length >= 2 && !this.isStopToken(token));

    if (tokens.length === 0) {
      return 0;
    }

    const searchable = this.buildCandidateSearchText(candidate);
    let score = 0;

    for (const token of tokens) {
      if (searchable.includes(token)) {
        score += 1;
        continue;
      }

      const stem = this.searchStem(token);
      if (stem.length >= 3 && searchable.includes(stem)) {
        score += 0.7;
      }
    }

    return this.clamp01(score / tokens.length);
  }

  private filterMatchScore(
    filters: AiQueryFilters,
    candidate: AiUserProfileRecord,
  ): number {
    const scores: number[] = [];

    if (filters.smokingPreference) {
      scores.push(
        candidate.smokingPreference === filters.smokingPreference ? 1 : 0,
      );
    }
    if (filters.petsPreference) {
      scores.push(candidate.petsPreference === filters.petsPreference ? 1 : 0);
    }
    if (filters.noisePreference) {
      scores.push(
        candidate.noisePreference === filters.noisePreference ? 1 : 0,
      );
    }
    if (filters.chronotype) {
      scores.push(candidate.chronotype === filters.chronotype ? 1 : 0);
    }
    if (filters.personalityType) {
      scores.push(
        candidate.personalityType === filters.personalityType ? 1 : 0,
      );
    }
    if (filters.preferredGender) {
      scores.push(candidate.gender === filters.preferredGender ? 1 : 0);
    }
    if (filters.occupationStatus) {
      scores.push(
        candidate.occupationStatus === filters.occupationStatus ? 1 : 0,
      );
    }
    if (filters.roommateGenderPreference) {
      scores.push(
        candidate.roommateGenderPreference === filters.roommateGenderPreference
          ? 1
          : 0,
      );
    }
    if (filters.requiresCleanLifestyle) {
      const text = this.buildCandidateSearchText(candidate);
      scores.push(
        text.includes('clean') ||
          text.includes('tidy') ||
          text.includes('neat') ||
          text.includes('chist') ||
          text.includes('чист') ||
          text.includes('поряд')
          ? 1
          : 0,
      );
    }

    if (scores.length === 0) {
      return 0;
    }

    const sum = scores.reduce((acc, value) => acc + value, 0);
    return this.clamp01(sum / scores.length);
  }

  private buildCandidateSearchText(candidate: AiUserProfileRecord): string {
    const chunks = [
      candidate.firstName,
      candidate.lastName,
      candidate.city,
      candidate.searchDistrict,
      candidate.bio,
      candidate.university,
      candidate.stayTerm,
      candidate.gender,
      candidate.occupationStatus,
      candidate.chronotype,
      candidate.noisePreference,
      candidate.personalityType,
      candidate.smokingPreference,
      candidate.petsPreference,
      candidate.roommateGenderPreference,
      this.enumSearchTerms('gender', candidate.gender),
      this.enumSearchTerms('occupationStatus', candidate.occupationStatus),
      this.enumSearchTerms('chronotype', candidate.chronotype),
      this.enumSearchTerms('noisePreference', candidate.noisePreference),
      this.enumSearchTerms('personalityType', candidate.personalityType),
      this.enumSearchTerms('smokingPreference', candidate.smokingPreference),
      this.enumSearchTerms('petsPreference', candidate.petsPreference),
      this.enumSearchTerms(
        'roommateGenderPreference',
        candidate.roommateGenderPreference,
      ),
    ];

    return this.normalizeSearchText(chunks.filter(Boolean).join(' '));
  }

  private enumSearchTerms(
    kind: string,
    value: string | null | undefined,
  ): string {
    if (!value) {
      return '';
    }

    const key = `${kind}:${value}`;
    const terms: Record<string, string> = {
      'gender:MALE': 'male man guy мужчина парень сосед',
      'gender:FEMALE': 'female woman girl женщина девушка соседка',
      'occupationStatus:STUDY':
        'student study university учится студент студентка учеба',
      'occupationStatus:WORK': 'work job employed работает работа',
      'occupationStatus:STUDY_WORK':
        'student work study job учится работает студент работа',
      'chronotype:OWL': 'night owl late sleeper сова ночной поздно',
      'chronotype:LARK': 'early morning lark жаворонок рано утро',
      'noisePreference:QUIET':
        'quiet calm silent silence тихий тихая тихо тишина спокойный спокойная спокойствие',
      'noisePreference:SOCIAL':
        'social outgoing party шумный шумная общительный тусовки',
      'personalityType:INTROVERT':
        'introvert quiet private интроверт спокойный закрытый',
      'personalityType:EXTROVERT':
        'extrovert social outgoing экстраверт общительный',
      'smokingPreference:NON_SMOKER':
        'non smoker no smoking does not smoke не курит некурящий без курения',
      'smokingPreference:SMOKER': 'smoker smoking курит курящий',
      'petsPreference:NO_PETS':
        'no pets without pets без животных без питомцев',
      'petsPreference:WITH_PETS':
        'with pets pet friendly животные питомцы с животными',
      'roommateGenderPreference:MALE': 'male man guy парень мужчина сосед',
      'roommateGenderPreference:FEMALE':
        'female woman girl девушка женщина соседка',
      'roommateGenderPreference:ANY': 'any gender любой пол не важно',
    };

    return terms[key] ?? value;
  }

  private normalizeSearchText(value: string): string {
    return value
      .toLowerCase()
      .replace(/ё/g, 'е')
      .replace(/[^\p{L}\p{N}\s-]+/gu, ' ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  private normalizeSearchToken(value: string): string {
    return this.normalizeSearchText(value);
  }

  private searchStem(value: string): string {
    return value
      .replace(
        /(иями|ями|ами|ого|ему|ыми|ими|ая|яя|ое|ее|ые|ие|ый|ий|ой|ую|юю|ом|ем|ах|ях|ов|ев|ей|ам|ям|ами|ями|а|я|ы|и|у|ю|е|о)$/u,
        '',
      )
      .replace(/(ing|ers|er|ed|es|s)$/u, '');
  }

  private isStopToken(value: string): boolean {
    return new Set([
      'и',
      'в',
      'во',
      'на',
      'по',
      'для',
      'the',
      'a',
      'an',
      'and',
      'or',
    ]).has(value);
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

  private buildSharedLifestyleExplanation(
    matched: string[],
    partial: string[],
  ): string {
    const lifestyleFields = [
      'noisePreference',
      'smokingPreference',
      'petsPreference',
      'chronotype',
      'personalityType',
      'occupationStatus',
    ];
    const matchedLifestyle = matched.filter((field) =>
      lifestyleFields.includes(field),
    );
    const partialLifestyle = partial.filter((field) =>
      lifestyleFields.includes(field),
    );

    if (matchedLifestyle.length > 0) {
      return `Совпадения по образу жизни: ${matchedLifestyle.join(', ')}.`;
    }
    if (partialLifestyle.length > 0) {
      return `Есть частичные совпадения по образу жизни: ${partialLifestyle.join(', ')}.`;
    }
    return 'Явных совпадений по образу жизни общий алгоритм не нашел.';
  }

  private buildSharedPreferenceExplanation(
    matched: string[],
    requiredMismatches: string[],
  ): string {
    const preferenceFields = ['budget', 'district', 'roommateGenderPreference'];
    const matchedPreferences = matched.filter((field) =>
      preferenceFields.includes(field),
    );
    const requiredPreferenceMismatches = requiredMismatches.filter((field) =>
      preferenceFields.includes(field),
    );

    if (matchedPreferences.length > 0) {
      return `Совпадения по предпочтениям: ${matchedPreferences.join(', ')}.`;
    }
    if (requiredPreferenceMismatches.length > 0) {
      return `Есть важные расхождения: ${requiredPreferenceMismatches.join(', ')}.`;
    }
    return 'Предпочтения оценены тем же правилом, что и на главном экране.';
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

  private semanticSimilarity(vectorA: number[], vectorB: number[]): number {
    const length = Math.min(vectorA.length, vectorB.length);
    if (length === 0) {
      return 0;
    }

    let dot = 0;
    let normA = 0;
    let normB = 0;

    for (let i = 0; i < length; i++) {
      const a = vectorA[i] ?? 0;
      const b = vectorB[i] ?? 0;
      dot += a * b;
      normA += a * a;
      normB += b * b;
    }

    const denom = Math.sqrt(normA) * Math.sqrt(normB);
    if (!denom || !Number.isFinite(denom)) {
      return 0;
    }

    return this.clamp01((dot / denom + 1) / 2);
  }

  private normalizePercent(value: number | null | undefined): number {
    if (!Number.isFinite(value ?? NaN)) {
      return 0;
    }
    return Math.max(0, Math.min(100, Number(value)));
  }

  private percentToRatio(value: number): number {
    return this.clamp01(value / 100);
  }

  private averageCriteria(
    scores: Record<string, number>,
    criteria: string[],
  ): number {
    const values = criteria
      .map((criterion) => scores[criterion])
      .filter((value): value is number => Number.isFinite(value));

    if (values.length === 0) {
      return 0;
    }

    const sum = values.reduce((acc, value) => acc + value, 0);
    return this.clamp01(sum / values.length);
  }

  private toNumberRecord(value: unknown): Record<string, number> {
    if (!value || typeof value !== 'object' || Array.isArray(value)) {
      return {};
    }

    const result: Record<string, number> = {};
    for (const [key, raw] of Object.entries(value)) {
      const numeric = Number(raw);
      if (Number.isFinite(numeric)) {
        result[key] = numeric;
      }
    }
    return result;
  }

  private toStringArray(value: unknown): string[] {
    if (!Array.isArray(value)) {
      return [];
    }
    return value
      .filter((item): item is string => typeof item === 'string')
      .map((item) => item.trim())
      .filter(Boolean);
  }

  private clamp01(value: number): number {
    if (!Number.isFinite(value)) {
      return 0;
    }
    if (value < 0) {
      return 0;
    }
    if (value > 1) {
      return 1;
    }
    return Number(value.toFixed(4));
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
