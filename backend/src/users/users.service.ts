import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import type { Express } from 'express';
import { createHash } from 'crypto';
import {
  Gender,
  NoisePreference,
  PetsPreference,
  Prisma,
  SmokingPreference,
  UserRole,
} from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { OpenAIService } from '../ai/openai.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { UpdatePasswordDto } from './dto/update-password.dto';
import { DiscoverUsersQueryDto } from './dto/discover-users-query.dto';
import { FilterUsersQueryDto } from './dto/filter-users-query.dto';
import { MatchingPrioritiesDto } from './dto/matching-priorities.dto';
import {
  DEFAULT_MATCHING_PRIORITIES,
  MATCHING_CRITERIA,
  MATCHING_PRIORITY_LEVELS,
  MATCHING_PRIORITY_WEIGHTS,
  MatchingCriterion,
  MatchingPriorityLevel,
} from './matching.constants';

type UserPreview = Prisma.UserGetPayload<{
  select: {
    id: true;
    firstName: true;
    lastName: true;
    age: true;
    city: true;
    bio: true;
    photos: true;
    gender: true;
    occupationStatus: true;
    university: true;
    chronotype: true;
    noisePreference: true;
    personalityType: true;
    smokingPreference: true;
    petsPreference: true;
    searchBudgetMin: true;
    searchBudgetMax: true;
    searchDistrict: true;
    stayTerm: true;
    roommateGenderPreference: true;
    onboardingCompleted: true;
    emailVerified: true;
    phoneVerified: true;
    verificationStatus: true;
    createdAt: true;
    updatedAt: true;
  };
}>;

type DiscoverUser = UserPreview & {
  compatibility: number | null;
  compatibilityReasons: string[];
  matchPercent?: number;
  ruleScore?: number;
  embeddingScore?: number | null;
  aiScore?: number | null;
  finalScore?: number;
  compatibilityBreakdown?: {
    matchedCriteria: string[];
    partiallyMatchedCriteria: string[];
    mismatchedCriteria: string[];
    requiredMismatches: string[];
    criterionScores: Record<string, number>;
  };
  isSaved?: boolean;
  isProfileComplete?: boolean;
  aiReasoning?: string | null;
  aiStrengths?: string[];
  aiRisks?: string[];
};

type RecommendationCacheRow = Prisma.AiRecommendationCacheGetPayload<{
  select: {
    candidateUserId: true;
    aiScore: true;
    reasoning: true;
    strengths: true;
    risks: true;
    updatedAt: true;
  };
}>;

type EmbeddingRow = Prisma.UserEmbeddingGetPayload<{
  select: {
    id: true;
    userId: true;
    profileText: true;
    profileTextHash: true;
    model: true;
    dimensions: true;
    vector: true;
    updatedAt: true;
  };
}>;

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(
    private prisma: PrismaService,
    private openAIService: OpenAIService,
  ) {}

  private parseLimit(
    value: unknown,
    fallback: number,
    max: number,
    min = 1,
  ): number {
    const n = Number(value);
    if (!Number.isFinite(n)) return fallback;
    return Math.min(Math.max(Math.floor(n), min), max);
  }

  private normalizeMatchingPriorities(
    raw: unknown,
  ): Record<MatchingCriterion, MatchingPriorityLevel> {
    const result = { ...DEFAULT_MATCHING_PRIORITIES };
    if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return result;

    const source = raw as Record<string, unknown>;
    for (const criterion of MATCHING_CRITERIA) {
      const value = source[criterion];
      if (typeof value !== 'string') continue;
      const normalized = value.trim().toLowerCase() as MatchingPriorityLevel;
      if (
        (MATCHING_PRIORITY_LEVELS as readonly string[]).includes(normalized)
      ) {
        result[criterion] = normalized;
      }
    }

    return result;
  }

  private buildVisibleUserWhere(currentUserId: string): Prisma.UserWhereInput {
    return {
      role: UserRole.USER,
      isBanned: false,
      id: { not: currentUserId },
      OR: [{ emailVerified: true }, { phoneVerified: true }],
    };
  }

  private normalizeComparableText(value: string | null | undefined): string {
    return (value ?? '').trim().toLowerCase();
  }

  private isAllDistrictValue(value: string | null | undefined): boolean {
    const normalized = this.normalizeComparableText(value);
    return (
      normalized.length === 0 ||
      normalized === 'all districts' ||
      normalized === 'any district' ||
      normalized === 'any' ||
      normalized === 'all' ||
      normalized === '\u0432\u0441\u0435 \u0440\u0430\u0439\u043e\u043d\u044b'
    );
  }

  private pushRoommateGenderPreferenceFilter(
    andConditions: Prisma.UserWhereInput[],
    preference: string | null | undefined,
  ) {
    if (!preference || preference === 'ANY') {
      return;
    }

    andConditions.push({
      gender: preference as Gender,
    });
  }

  private appendCandidateFilters(
    andConditions: Prisma.UserWhereInput[],
    filters: {
      city?: string | null;
      district?: string | null;
      priceMin?: number | null;
      priceMax?: number | null;
      budgetMax?: number | null;
      gender?: string | null;
      petsPreference?: string | null;
      smokingPreference?: string | null;
      noisePreference?: string | null;
      ageRange?: '18-25' | '25+' | null;
    },
  ) {
    const normalizedCity =
      typeof filters.city === 'string'
        ? filters.city.trim()
        : (filters.city ?? null);
    const normalizedDistrict =
      typeof filters.district === 'string'
        ? filters.district.trim()
        : (filters.district ?? null);

    if (normalizedCity && normalizedCity.length > 0) {
      andConditions.push({
        city: {
          contains: normalizedCity,
          mode: 'insensitive',
        },
      });
    }

    if (normalizedDistrict && !this.isAllDistrictValue(normalizedDistrict)) {
      andConditions.push({
        searchDistrict: normalizedDistrict,
      });
    }

    const priceMin = filters.priceMin ?? null;
    const priceMax = filters.priceMax ?? null;
    const budgetMax = filters.budgetMax ?? null;

    if (priceMin !== null || priceMax !== null) {
      if (priceMin !== null && priceMax !== null) {
        andConditions.push({
          OR: [
            {
              AND: [
                { searchBudgetMin: { lte: priceMax } },
                { searchBudgetMax: { gte: priceMin } },
              ],
            },
            { searchBudgetMin: null },
            { searchBudgetMax: null },
          ],
        });
      } else if (priceMin !== null) {
        andConditions.push({
          OR: [
            { searchBudgetMax: { gte: priceMin } },
            { searchBudgetMax: null },
          ],
        });
      } else if (priceMax !== null) {
        andConditions.push({
          OR: [
            { searchBudgetMin: { lte: priceMax } },
            { searchBudgetMin: null },
          ],
        });
      }
    } else if (budgetMax !== null) {
      andConditions.push({
        OR: [
          { searchBudgetMin: { lte: budgetMax } },
          { searchBudgetMin: null },
        ],
      });
    }

    if (filters.gender) {
      andConditions.push({
        gender: filters.gender as Gender,
      });
    }

    if (filters.petsPreference) {
      andConditions.push({
        petsPreference: filters.petsPreference as PetsPreference,
      });
    }

    if (filters.smokingPreference) {
      andConditions.push({
        smokingPreference: filters.smokingPreference as SmokingPreference,
      });
    }

    if (filters.noisePreference) {
      andConditions.push({
        noisePreference: filters.noisePreference as NoisePreference,
      });
    }

    if (filters.ageRange === '18-25') {
      andConditions.push({
        age: { gte: 18, lte: 25 },
      });
    } else if (filters.ageRange === '25+') {
      andConditions.push({
        age: { gte: 25 },
      });
    }
  }

  private toStringArray(raw: Prisma.JsonValue | null | undefined): string[] {
    if (!Array.isArray(raw)) return [];
    return raw.filter((value): value is string => typeof value === 'string');
  }

  private isProfileComplete(user: {
    occupationStatus?: string | null;
    university?: string | null;
    bio?: string | null;
    chronotype?: string | null;
    noisePreference?: string | null;
    personalityType?: string | null;
    smokingPreference?: string | null;
    petsPreference?: string | null;
    searchBudgetMin?: number | null;
    searchBudgetMax?: number | null;
    searchDistrict?: string | null;
    roommateGenderPreference?: string | null;
    stayTerm?: string | null;
    photos?: string[] | null;
    onboardingCompleted?: boolean;
  }): boolean {
    if (user.onboardingCompleted) {
      return true;
    }

    const photos = user.photos ?? [];
    return Boolean(
      user.occupationStatus &&
      user.university &&
      user.bio &&
      user.chronotype &&
      user.noisePreference &&
      user.personalityType &&
      user.smokingPreference &&
      user.petsPreference &&
      user.searchBudgetMin != null &&
      user.searchBudgetMax != null &&
      user.searchDistrict &&
      user.roommateGenderPreference &&
      user.stayTerm &&
      photos.some((photo) => photo.trim().length > 0),
    );
  }

  private categoryMatch(
    a: unknown,
    b: unknown,
  ): {
    score: number;
    reason: string;
  } {
    if (!a || !b) {
      return { score: 0.5, reason: 'insufficient_data' };
    }
    return {
      score: a === b ? 1 : 0,
      reason: a === b ? 'exact_match' : 'mismatch',
    };
  }

  private budgetMatch(
    meMin: number | null,
    meMax: number | null,
    otherMin: number | null,
    otherMax: number | null,
  ): { score: number; reason: string } {
    if (
      meMin == null ||
      meMax == null ||
      otherMin == null ||
      otherMax == null ||
      meMin > meMax ||
      otherMin > otherMax
    ) {
      return { score: 0.5, reason: 'insufficient_data' };
    }

    const overlaps = meMin <= otherMax && otherMin <= meMax;
    if (overlaps) return { score: 1, reason: 'overlap' };

    const gap = meMin > otherMax ? meMin - otherMax : otherMin - meMax;
    const window = Math.max(meMax - meMin, otherMax - otherMin, 1);
    if (gap <= window * 0.25) return { score: 0.5, reason: 'close' };
    return { score: 0, reason: 'far' };
  }

  private roommateGenderMatch(
    preference: string | null | undefined,
    gender: string | null | undefined,
  ): { score: number; reason: string } {
    if (!preference || preference === 'ANY') {
      return { score: 1, reason: 'no_preference' };
    }
    if (!gender) {
      return { score: 0.5, reason: 'insufficient_data' };
    }
    return {
      score: preference === gender ? 1 : 0,
      reason: preference === gender ? 'exact_match' : 'mismatch',
    };
  }

  private districtMatch(
    me: { city: string | null; searchDistrict: string | null },
    candidate: {
      city: string | null;
      searchDistrict: string | null;
    },
  ): { score: number; reason: string } {
    const myDistrict = me.searchDistrict?.trim();
    const theirDistrict = candidate.searchDistrict?.trim();
    const myCity = me.city?.trim();
    const theirCity = candidate.city?.trim();

    if (myDistrict && theirDistrict && myDistrict === theirDistrict) {
      return { score: 1, reason: 'same_district' };
    }
    if (myCity && theirCity && myCity === theirCity) {
      return { score: 0.5, reason: 'same_city' };
    }
    if (!myCity || !theirCity)
      return { score: 0.5, reason: 'insufficient_data' };
    return { score: 0, reason: 'different_city' };
  }

  private buildCompatibilityReasons(
    matchedCriteria: string[],
    requiredMismatches: string[],
  ): string[] {
    const reasons: string[] = [];

    if (matchedCriteria.includes('budget')) {
      reasons.push('Хорошее совпадение по бюджету');
    }
    if (matchedCriteria.includes('district')) {
      reasons.push('Локация хорошо совпадает');
    }
    if (matchedCriteria.includes('noisePreference')) {
      reasons.push('Похожие предпочтения по уровню шума');
    }
    if (matchedCriteria.includes('smokingPreference')) {
      reasons.push('Совпадает отношение к курению');
    }
    if (requiredMismatches.length > 0) {
      reasons.push(
        `Есть конфликты по обязательным критериям: ${requiredMismatches.join(', ')}`,
      );
    }

    return reasons;
  }

  private compactAiProfile(user: {
    city: string | null;
    searchDistrict: string | null;
    searchBudgetMin: number | null;
    searchBudgetMax: number | null;
    occupationStatus: string | null;
    chronotype: string | null;
    noisePreference: string | null;
    personalityType: string | null;
    smokingPreference: string | null;
    petsPreference: string | null;
    roommateGenderPreference?: string | null;
    bio: string | null;
    stayTerm?: string | null;
  }) {
    return {
      location: {
        city: user.city,
        district: user.searchDistrict,
      },
      budget: {
        min: user.searchBudgetMin,
        max: user.searchBudgetMax,
      },
      lifestyle: {
        occupationStatus: user.occupationStatus,
        chronotype: user.chronotype,
        noisePreference: user.noisePreference,
        personalityType: user.personalityType,
        smokingPreference: user.smokingPreference,
        petsPreference: user.petsPreference,
      },
      stayTerm: user.stayTerm ?? null,
      roommateGenderPreference: user.roommateGenderPreference ?? null,
      bio: user.bio,
    };
  }

  private clampScore(value: number): number {
    if (!Number.isFinite(value)) return 0;
    return Math.max(0, Math.min(100, value));
  }

  private cosineSimilarity(a: number[], b: number[]): number {
    if (a.length === 0 || b.length === 0 || a.length !== b.length) return 0;
    let dot = 0;
    let normA = 0;
    let normB = 0;
    for (let i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA <= 0 || normB <= 0) return 0;
    return dot / (Math.sqrt(normA) * Math.sqrt(normB));
  }

  private semanticTextFromProfile(user: {
    gender?: string | null;
    age?: number | null;
    city: string | null;
    searchDistrict: string | null;
    searchBudgetMin: number | null;
    searchBudgetMax: number | null;
    occupationStatus: string | null;
    chronotype: string | null;
    noisePreference: string | null;
    personalityType: string | null;
    smokingPreference: string | null;
    petsPreference: string | null;
    stayTerm?: string | null;
    university?: string | null;
    roommateGenderPreference?: string | null;
    bio: string | null;
  }): string {
    const chunks = [
      user.bio?.trim() ?? '',
      user.gender ? `gender: ${user.gender}` : '',
      user.age != null ? `age: ${user.age}` : '',
      user.city ? `city: ${user.city}` : '',
      user.searchDistrict ? `district: ${user.searchDistrict}` : '',
      user.searchBudgetMin != null || user.searchBudgetMax != null
        ? `budget: ${user.searchBudgetMin ?? '?'}-${user.searchBudgetMax ?? '?'}`
        : '',
      user.occupationStatus ? `occupation: ${user.occupationStatus}` : '',
      user.university ? `university: ${user.university}` : '',
      user.chronotype ? `chronotype: ${user.chronotype}` : '',
      user.noisePreference ? `noise: ${user.noisePreference}` : '',
      user.personalityType ? `personality: ${user.personalityType}` : '',
      user.smokingPreference ? `smoking: ${user.smokingPreference}` : '',
      user.petsPreference ? `pets: ${user.petsPreference}` : '',
      user.stayTerm ? `stayTerm: ${user.stayTerm}` : '',
      user.roommateGenderPreference
        ? `roommateGenderPreference: ${user.roommateGenderPreference}`
        : '',
    ].filter(Boolean);
    return chunks.join('\n').slice(0, 3500);
  }

  private parseEmbeddingVector(raw: unknown): number[] | null {
    if (!Array.isArray(raw) || raw.length === 0) return null;
    const vector: number[] = [];
    for (const value of raw) {
      if (typeof value !== 'number' || !Number.isFinite(value)) {
        return null;
      }
      vector.push(value);
    }
    return vector;
  }

  private profileTextHash(text: string): string {
    return createHash('sha256').update(text).digest('hex');
  }

  private async upsertUserEmbedding(params: {
    userId: string;
    text: string;
    hash: string;
    vector: number[];
  }): Promise<void> {
    await this.prisma.userEmbedding.upsert({
      where: { userId: params.userId },
      update: {
        profileText: params.text,
        profileTextHash: params.hash,
        model: process.env.OPENAI_EMBEDDING_MODEL || 'text-embedding-3-small',
        dimensions: params.vector.length,
        vector: params.vector,
      },
      create: {
        userId: params.userId,
        profileText: params.text,
        profileTextHash: params.hash,
        model: process.env.OPENAI_EMBEDDING_MODEL || 'text-embedding-3-small',
        dimensions: params.vector.length,
        vector: params.vector,
      },
    });
  }

  private computeFinalScore(
    ruleScore: number,
    embeddingScore: number | null,
    aiScore: number | null,
  ): number {
    if (aiScore == null && embeddingScore == null) {
      return this.clampScore(ruleScore);
    }
    if (aiScore == null) {
      return this.clampScore(ruleScore * 0.7 + (embeddingScore ?? 0) * 0.3);
    }
    if (embeddingScore == null) {
      return this.clampScore(ruleScore * 0.85 + aiScore * 0.15);
    }
    return this.clampScore(
      ruleScore * 0.6 + embeddingScore * 0.25 + aiScore * 0.15,
    );
  }

  private getNewestTimestamp(
    ...dates: Array<Date | null | undefined>
  ): Date | null {
    const validDates = dates.filter(
      (date): date is Date => date instanceof Date,
    );
    if (validDates.length === 0) return null;

    return validDates.reduce((latest, current) =>
      latest.getTime() >= current.getTime() ? latest : current,
    );
  }

  private hasRussianContent(value: string | null | undefined): boolean {
    if (!value) return false;
    return /[\u0410-\u042f\u0430-\u044f\u0401\u0451]/.test(value);
  }

  private isRussianAiCache(cache: RecommendationCacheRow): boolean {
    const strengths = this.toStringArray(cache.strengths);
    const risks = this.toStringArray(cache.risks);

    return (
      this.hasRussianContent(cache.reasoning ?? null) &&
      strengths.length > 0 &&
      strengths.every((value) => this.hasRussianContent(value)) &&
      risks.length > 0 &&
      risks.every((value) => this.hasRussianContent(value))
    );
  }

  private containsCyrillic(value: string | null | undefined): boolean {
    if (!value) return false;
    return /[\u0410-\u042f\u0430-\u044f\u0401\u0451]/.test(value);
  }

  private isRussianAiResult(
    result:
      | {
          reasoning: string | null | undefined;
          strengths: string[] | null | undefined;
          risks: string[] | null | undefined;
        }
      | null
      | undefined,
  ): boolean {
    if (!result) return false;

    const strengths = (result.strengths ?? []).filter(
      (value): value is string => typeof value === 'string',
    );
    const risks = (result.risks ?? []).filter(
      (value): value is string => typeof value === 'string',
    );

    return (
      this.containsCyrillic(result.reasoning ?? null) &&
      strengths.length > 0 &&
      strengths.every((value) => this.containsCyrillic(value)) &&
      risks.length > 0 &&
      risks.every((value) => this.containsCyrillic(value))
    );
  }

  private isRecommendationCacheFresh(params: {
    cache: RecommendationCacheRow;
    currentUserUpdatedAt: Date;
    candidateUpdatedAt: Date;
    currentEmbeddingUpdatedAt?: Date | null;
    candidateEmbeddingUpdatedAt?: Date | null;
  }): boolean {
    const latestRelevantUpdate = this.getNewestTimestamp(
      params.currentUserUpdatedAt,
      params.candidateUpdatedAt,
      params.currentEmbeddingUpdatedAt,
      params.candidateEmbeddingUpdatedAt,
    );

    if (!latestRelevantUpdate) return true;
    return (
      params.cache.updatedAt.getTime() >= latestRelevantUpdate.getTime() &&
      this.isRussianAiCache(params.cache)
    );
  }

  private async runWithConcurrency<T>(
    items: T[],
    concurrency: number,
    worker: (item: T) => Promise<void>,
  ): Promise<void> {
    if (items.length === 0) return;

    let index = 0;
    const safeConcurrency = Math.max(1, Math.min(concurrency, items.length));
    await Promise.all(
      Array.from({ length: safeConcurrency }, async () => {
        while (index < items.length) {
          const currentIndex = index;
          index += 1;
          await worker(items[currentIndex]);
        }
      }),
    );
  }

  private async ensureEmbeddings(params: {
    me: {
      id: string;
      embedding: EmbeddingRow | null;
      text: string;
    };
    candidates: Array<{
      id: string;
      embedding: EmbeddingRow | null;
      text: string;
    }>;
    maxCandidateGenerations: number;
  }): Promise<{
    meVector: number[] | null;
    candidateVectors: Map<string, number[]>;
    generatedCandidateCount: number;
  }> {
    const candidateVectors = new Map<string, number[]>();
    const meHash = this.profileTextHash(params.me.text);
    let meVector =
      params.me.embedding?.profileTextHash === meHash
        ? this.parseEmbeddingVector(params.me.embedding.vector)
        : null;

    type Missing = { userId: string; text: string; hash: string };
    const missingCandidates: Missing[] = [];

    for (const candidate of params.candidates) {
      const candidateHash = this.profileTextHash(candidate.text);
      const cached =
        candidate.embedding?.profileTextHash === candidateHash
          ? this.parseEmbeddingVector(candidate.embedding.vector)
          : null;
      if (cached) {
        candidateVectors.set(candidate.id, cached);
      } else {
        missingCandidates.push({
          userId: candidate.id,
          text: candidate.text,
          hash: candidateHash,
        });
      }
    }

    if (!this.openAIService.isEnabled()) {
      return { meVector, candidateVectors, generatedCandidateCount: 0 };
    }

    if (!meVector) {
      try {
        const vector = await this.openAIService.createEmbedding(params.me.text);
        if (Array.isArray(vector) && vector.length > 0) {
          await this.upsertUserEmbedding({
            userId: params.me.id,
            text: params.me.text,
            hash: meHash,
            vector,
          });
          meVector = vector;
        }
      } catch (error) {
        this.logger.warn(
          `Failed to refresh current user embedding for ${params.me.id}: ${
            error instanceof Error ? error.message : 'unknown error'
          }`,
        );
      }
    }

    const candidatesToGenerate = missingCandidates.slice(
      0,
      Math.max(0, params.maxCandidateGenerations),
    );

    if (candidatesToGenerate.length === 0) {
      return { meVector, candidateVectors, generatedCandidateCount: 0 };
    }

    try {
      const generated = await this.openAIService.createEmbeddings(
        candidatesToGenerate.map((entry) => entry.text),
      );
      for (let i = 0; i < candidatesToGenerate.length; i++) {
        const current = candidatesToGenerate[i];
        const vector = generated[i];
        if (!Array.isArray(vector) || vector.length === 0) continue;
        await this.upsertUserEmbedding({
          userId: current.userId,
          text: current.text,
          hash: current.hash,
          vector,
        });
        candidateVectors.set(current.userId, vector);
      }
    } catch (error) {
      this.logger.warn(
        `Failed to refresh candidate embeddings for ${candidatesToGenerate.length} users: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }

    return {
      meVector,
      candidateVectors,
      generatedCandidateCount: candidatesToGenerate.length,
    };
  }

  private resolveCachedEmbeddings(params: {
    me: {
      embedding: EmbeddingRow | null;
      text: string;
    };
    candidates: Array<{
      id: string;
      embedding: EmbeddingRow | null;
      text: string;
    }>;
  }): {
    meVector: number[] | null;
    candidateVectors: Map<string, number[]>;
  } {
    const candidateVectors = new Map<string, number[]>();
    const meHash = this.profileTextHash(params.me.text);
    const meVector =
      params.me.embedding?.profileTextHash === meHash
        ? this.parseEmbeddingVector(params.me.embedding.vector)
        : null;

    for (const candidate of params.candidates) {
      const candidateHash = this.profileTextHash(candidate.text);
      const cached =
        candidate.embedding?.profileTextHash === candidateHash
          ? this.parseEmbeddingVector(candidate.embedding.vector)
          : null;
      if (cached) {
        candidateVectors.set(candidate.id, cached);
      }
    }

    return { meVector, candidateVectors };
  }

  private queueRecommendationWarmup(params: {
    currentUserId: string;
    me: {
      id: string;
      embedding: EmbeddingRow | null;
      text: string;
      aiProfile: Record<string, unknown>;
    };
    candidates: Array<{
      id: string;
      embedding: EmbeddingRow | null;
      text: string;
      aiProfile: Record<string, unknown>;
      scored: DiscoverUser;
    }>;
    maxCandidateEmbeddings: number;
    maxAiCandidates: number;
    aiConcurrency: number;
  }): void {
    if (!this.openAIService.isEnabled() || params.candidates.length === 0) {
      return;
    }

    void (async () => {
      const warmCandidates = params.candidates.slice(
        0,
        Math.max(params.maxCandidateEmbeddings, params.maxAiCandidates),
      );
      const { meVector, candidateVectors, generatedCandidateCount } =
        await this.ensureEmbeddings({
          me: {
            id: params.me.id,
            embedding: params.me.embedding,
            text: params.me.text,
          },
          candidates: warmCandidates.map((candidate) => ({
            id: candidate.id,
            embedding: candidate.embedding,
            text: candidate.text,
          })),
          maxCandidateGenerations: params.maxCandidateEmbeddings,
        });

      for (const candidate of warmCandidates) {
        const candidateVector = candidateVectors.get(candidate.id) ?? null;
        if (meVector && candidateVector) {
          candidate.scored.embeddingScore = Math.round(
            this.clampScore(((this.cosineSimilarity(meVector, candidateVector) + 1) / 2) * 100),
          );
          candidate.scored.finalScore = Math.round(
            this.computeFinalScore(
              candidate.scored.ruleScore ?? 0,
              candidate.scored.embeddingScore ?? null,
              candidate.scored.aiScore ?? null,
            ),
          );
          candidate.scored.compatibility = candidate.scored.finalScore;
          candidate.scored.matchPercent = candidate.scored.finalScore;
        }
      }

      const aiTargets = warmCandidates
        .filter((candidate) => candidate.scored.aiScore == null)
        .sort(
          (left, right) =>
            (right.scored.finalScore ?? 0) - (left.scored.finalScore ?? 0),
        )
        .slice(0, params.maxAiCandidates);

      let aiCallsMade = 0;
      await this.runWithConcurrency(
        aiTargets,
        Math.max(1, params.aiConcurrency),
        async (candidate) => {
          let ai: Awaited<
            ReturnType<OpenAIService['evaluateRoommateCompatibility']>
          > | null = null;
          try {
            ai = await this.openAIService.evaluateRoommateCompatibility({
              me: params.me.aiProfile,
              candidate: candidate.aiProfile,
            });
          } catch {
            ai = null;
          }

          if (!ai || !this.isRussianAiResult(ai)) {
            return;
          }

          aiCallsMade += 1;
          candidate.scored.aiScore = Math.round(
            this.clampScore(ai.compatibilityScore),
          );
          candidate.scored.aiReasoning = ai.reasoning;
          candidate.scored.aiStrengths = ai.strengths;
          candidate.scored.aiRisks = ai.risks;
          candidate.scored.finalScore = Math.round(
            this.computeFinalScore(
              candidate.scored.ruleScore ?? 0,
              candidate.scored.embeddingScore ?? null,
              candidate.scored.aiScore ?? null,
            ),
          );
          candidate.scored.compatibility = candidate.scored.finalScore;
          candidate.scored.matchPercent = candidate.scored.finalScore;
          await this.upsertRecommendationCache(
            params.currentUserId,
            candidate.scored,
          );
        },
      );

      const candidatesToPersist =
        aiTargets.length > 0
          ? warmCandidates
          : warmCandidates.filter(
              (candidate) => candidate.scored.embeddingScore != null,
            );

      await Promise.all(
        candidatesToPersist.map((candidate) =>
          this.upsertRecommendationCache(params.currentUserId, candidate.scored),
        ),
      );

      this.logger.debug(
        `Recommendation warmup finished: user=${params.currentUserId}, generatedEmbeddings=${generatedCandidateCount}, aiCalls=${aiCallsMade}, candidates=${warmCandidates.length}`,
      );
    })().catch((error) => {
      this.logger.warn(
        `Recommendation warmup failed for ${params.currentUserId}: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    });
  }

  private async upsertRecommendationCache(
    currentUserId: string,
    candidate: DiscoverUser,
  ): Promise<void> {
    const shouldPersistAi = this.isRussianAiResult({
      reasoning: candidate.aiReasoning,
      strengths: candidate.aiStrengths,
      risks: candidate.aiRisks,
    });
    const persistedAiScore =
      shouldPersistAi && candidate.aiScore != null
        ? Number(candidate.aiScore)
        : null;
    const persistedReasoning = shouldPersistAi ? candidate.aiReasoning : null;
    const persistedStrengths = shouldPersistAi ? candidate.aiStrengths ?? [] : [];
    const persistedRisks = shouldPersistAi ? candidate.aiRisks ?? [] : [];

    await this.prisma.aiRecommendationCache.upsert({
      where: {
        currentUserId_candidateUserId: {
          currentUserId,
          candidateUserId: candidate.id,
        },
      },
      update: {
        ruleScore: Number(candidate.ruleScore ?? 0),
        embeddingScore:
          candidate.embeddingScore == null
            ? null
            : Number(candidate.embeddingScore),
        aiScore: persistedAiScore,
        finalScore: Number(candidate.finalScore ?? 0),
        reasoning: persistedReasoning,
        strengths: persistedStrengths,
        risks: persistedRisks,
      },
      create: {
        currentUserId,
        candidateUserId: candidate.id,
        ruleScore: Number(candidate.ruleScore ?? 0),
        embeddingScore:
          candidate.embeddingScore == null
            ? null
            : Number(candidate.embeddingScore),
        aiScore: persistedAiScore,
        finalScore: Number(candidate.finalScore ?? 0),
        reasoning: persistedReasoning,
        strengths: persistedStrengths,
        risks: persistedRisks,
      },
    });
  }

  async refreshUserEmbedding(userId: string): Promise<boolean> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        gender: true,
        age: true,
        city: true,
        bio: true,
        searchDistrict: true,
        searchBudgetMin: true,
        searchBudgetMax: true,
        roommateGenderPreference: true,
        occupationStatus: true,
        university: true,
        chronotype: true,
        noisePreference: true,
        personalityType: true,
        smokingPreference: true,
        petsPreference: true,
        stayTerm: true,
      },
    });
    if (!user) {
      throw new NotFoundException('Пользователь не найден');
    }

    if (!this.openAIService.isEnabled()) {
      return false;
    }

    const text = this.semanticTextFromProfile(user);
    const hash = this.profileTextHash(text);
    try {
      const embedding = await this.openAIService.createEmbedding(text);
      await this.upsertUserEmbedding({
        userId,
        text,
        hash,
        vector: embedding,
      });
      return true;
    } catch (error) {
      this.logger.warn(
        `Failed to refresh embedding for ${userId}: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
      return false;
    }
  }

  async regenerateMyEmbedding(userId: string): Promise<{ refreshed: boolean }> {
    const refreshed = await this.refreshUserEmbedding(userId);
    return { refreshed };
  }

  async getRecommendationCache(userId: string, limit = 20) {
    const safeLimit = this.parseLimit(limit, 20, 100);
    return this.prisma.aiRecommendationCache.findMany({
      where: { currentUserId: userId },
      take: safeLimit,
      orderBy: { finalScore: 'desc' },
      select: {
        id: true,
        currentUserId: true,
        candidateUserId: true,
        ruleScore: true,
        embeddingScore: true,
        aiScore: true,
        finalScore: true,
        reasoning: true,
        strengths: true,
        risks: true,
        updatedAt: true,
      },
    });
  }

  async getRecommendations(
    currentUserId: string,
    query: DiscoverUsersQueryDto,
  ) {
    const hasFilters = Boolean(
      query.budgetMax != null ||
      (query.district != null && !this.isAllDistrictValue(query.district)) ||
      query.gender ||
      query.ageRange,
    );

    const personalized = await this.getPersonalizedRecommendations(
      currentUserId,
      query.page ?? 1,
      query.limit ?? 20,
      {
        district: query.district,
        budgetMax: query.budgetMax,
        gender: query.gender,
        ageRange: query.ageRange,
      },
    );

    if (personalized.data.length > 0 || hasFilters) {
      return personalized;
    }

    return this.discoverUsers(currentUserId, query);
  }

  async getMatchingPriorities(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, matchingPriorities: true },
    });
    if (!user) throw new NotFoundException('Пользователь не найден');

    return {
      matchingPriorities: this.normalizeMatchingPriorities(
        user.matchingPriorities,
      ),
    };
  }

  async updateMatchingPriorities(userId: string, dto: MatchingPrioritiesDto) {
    const existing = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { matchingPriorities: true },
    });
    if (!existing) throw new NotFoundException('Пользователь не найден');

    const incoming = dto as Record<string, unknown>;
    const hasAny = MATCHING_CRITERIA.some(
      (criterion) => incoming[criterion] != null,
    );
    if (!hasAny) {
      throw new BadRequestException(
        'Укажите хотя бы один приоритет для подбора',
      );
    }

    const current = this.normalizeMatchingPriorities(
      existing.matchingPriorities,
    );
    const merged = {
      ...current,
      ...dto,
    };

    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: { matchingPriorities: this.normalizeMatchingPriorities(merged) },
      select: { matchingPriorities: true },
    });

    return {
      matchingPriorities: this.normalizeMatchingPriorities(
        updated.matchingPriorities,
      ),
    };
  }

  /**
   * Personalized recommendations for the current user based on their profile
   * (district, budget, lifestyle, roommate gender preference, etc.).
   */
  async getPersonalizedRecommendations(
    currentUserId: string,
    page = 1,
    limit = 50,
    filters?: {
      candidateUserIds?: string[] | null;
      city?: string | null;
      district?: string | null;
      priceMin?: number | null;
      priceMax?: number | null;
      budgetMax?: number | null;
      gender?: string | null;
      petsPreference?: string | null;
      smokingPreference?: string | null;
      noisePreference?: string | null;
      ageRange?: '18-25' | '25+' | null;
    } | null,
  ): Promise<{
    data: DiscoverUser[];
    meta: { page: number; limit: number; total: number; totalPages: number };
  }> {
    const startedAt = Date.now();
    const specificCandidateIds = Array.from(
      new Set(
        (filters?.candidateUserIds ?? []).filter(
          (value): value is string => typeof value === 'string' && value.length > 0,
        ),
      ),
    );
    const safePage = this.parseLimit(page, 1, 10_000);
    const safeLimit = this.parseLimit(limit, 20, filters ? 100 : 50);
    const aiTopN = this.parseLimit(process.env.HYBRID_AI_TOP_N, 8, 20);
    const aiConcurrency = this.parseLimit(
      process.env.HYBRID_AI_CONCURRENCY,
      3,
      6,
    );
    const embeddingTopN = this.parseLimit(
      process.env.HYBRID_EMBED_TOP_N,
      Math.max(safeLimit * 2, 24),
      80,
    );
    const candidatePoolSize = Math.max(safeLimit * 5, 100);

    const me = await this.prisma.user.findUnique({
      where: { id: currentUserId },
      select: {
        id: true,
        gender: true,
        age: true,
        city: true,
        bio: true,
        searchDistrict: true,
        searchBudgetMin: true,
        searchBudgetMax: true,
        roommateGenderPreference: true,
        occupationStatus: true,
        university: true,
        chronotype: true,
        noisePreference: true,
        personalityType: true,
        smokingPreference: true,
        petsPreference: true,
        stayTerm: true,
        onboardingCompleted: true,
        verificationStatus: true,
        isBanned: true,
        matchingPriorities: true,
        updatedAt: true,
        embedding: {
          select: {
            id: true,
            userId: true,
            profileText: true,
            profileTextHash: true,
            model: true,
            dimensions: true,
            vector: true,
            updatedAt: true,
          },
        },
      },
    });

    if (!me || me.isBanned) {
      return {
        data: [],
        meta: { page: 1, limit: safeLimit, total: 0, totalPages: 0 },
      };
    }

    const priorities = this.normalizeMatchingPriorities(me.matchingPriorities);
    const candidateWhere: Prisma.UserWhereInput =
      this.buildVisibleUserWhere(currentUserId);
    const candidateConditions: Prisma.UserWhereInput[] = [];

    this.pushRoommateGenderPreferenceFilter(
      candidateConditions,
      me.roommateGenderPreference,
    );
    if (filters) {
      this.appendCandidateFilters(candidateConditions, filters);
    }
    if (specificCandidateIds.length > 0) {
      candidateConditions.push({
        id: { in: specificCandidateIds },
      });
    }
    if (candidateConditions.length > 0) {
      candidateWhere.AND = candidateConditions;
    }

    const candidates = await this.prisma.user.findMany({
      where: candidateWhere,
      take:
        specificCandidateIds.length > 0
          ? Math.max(specificCandidateIds.length, safeLimit)
          : candidatePoolSize,
      orderBy: [{ onboardingCompleted: 'desc' }, { updatedAt: 'desc' }],
      select: {
        id: true,
        firstName: true,
        lastName: true,
        age: true,
        city: true,
        bio: true,
        photos: true,
        gender: true,
        occupationStatus: true,
        university: true,
        chronotype: true,
        noisePreference: true,
        personalityType: true,
        smokingPreference: true,
        petsPreference: true,
        searchBudgetMin: true,
        searchBudgetMax: true,
        searchDistrict: true,
        stayTerm: true,
        onboardingCompleted: true,
        emailVerified: true,
        phoneVerified: true,
        verificationStatus: true,
        createdAt: true,
        updatedAt: true,
        roommateGenderPreference: true,
        embedding: {
          select: {
            id: true,
            userId: true,
            profileText: true,
            profileTextHash: true,
            model: true,
            dimensions: true,
            vector: true,
            updatedAt: true,
          },
        },
      },
    });

    if (candidates.length === 0) {
      this.logger.debug(
        `Recommendation pipeline finished: user=${currentUserId}, candidates=0, durationMs=${
          Date.now() - startedAt
        }`,
      );
      return {
        data: [],
        meta: { page: safePage, limit: safeLimit, total: 0, totalPages: 0 },
      };
    }

    const candidateIds = candidates.map((candidate) => candidate.id);
    const [favorites, existingCache] = await Promise.all([
      this.prisma.favoriteUser.findMany({
        where: {
          ownerId: currentUserId,
          targetUserId: { in: candidateIds },
        },
        select: { targetUserId: true },
      }),
      this.prisma.aiRecommendationCache.findMany({
        where: {
          currentUserId,
          candidateUserId: { in: candidateIds },
        },
        select: {
          candidateUserId: true,
          aiScore: true,
          reasoning: true,
          strengths: true,
          risks: true,
          updatedAt: true,
        },
      }),
    ]);

    const favoriteIds = new Set(
      favorites.map((favorite) => favorite.targetUserId),
    );
    const candidateById = new Map(
      candidates.map((candidate) => [candidate.id, candidate]),
    );
    const cacheByCandidateId = new Map(
      existingCache.map((cache) => [cache.candidateUserId, cache]),
    );
    this.logger.debug(
      `Recommendation pipeline start: user=${currentUserId}, candidates=${candidates.length}, meEmbedding=${
        me.embedding ? 'present' : 'missing'
      }`,
    );

    const scored = candidates.map((candidate) => {
      const { embedding: _ignoredEmbedding, ...candidateProfile } = candidate;
      void _ignoredEmbedding;
      const criterionScores: Record<string, number> = {};
      const matchedCriteria: string[] = [];
      const partiallyMatchedCriteria: string[] = [];
      const mismatchedCriteria: string[] = [];
      const requiredMismatches: string[] = [];

      let weightedSum = 0;
      let totalWeight = 0;

      const budget = this.budgetMatch(
        me.searchBudgetMin,
        me.searchBudgetMax,
        candidateProfile.searchBudgetMin,
        candidateProfile.searchBudgetMax,
      );
      const district = this.districtMatch(me, candidateProfile);
      const noise = this.categoryMatch(
        me.noisePreference,
        candidateProfile.noisePreference,
      );
      const smoking = this.categoryMatch(
        me.smokingPreference,
        candidateProfile.smokingPreference,
      );
      const pets = this.categoryMatch(
        me.petsPreference,
        candidateProfile.petsPreference,
      );
      const chrono = this.categoryMatch(
        me.chronotype,
        candidateProfile.chronotype,
      );
      const personality = this.categoryMatch(
        me.personalityType,
        candidateProfile.personalityType,
      );
      const occupation = this.categoryMatch(
        me.occupationStatus,
        candidateProfile.occupationStatus,
      );
      const myGenderPreference = this.roommateGenderMatch(
        me.roommateGenderPreference,
        candidateProfile.gender,
      );
      const candidateGenderPreference = this.roommateGenderMatch(
        candidateProfile.roommateGenderPreference,
        me.gender,
      );
      const genderPreferenceScore =
        (myGenderPreference.score + candidateGenderPreference.score) / 2;

      const rawScores: Record<MatchingCriterion, number> = {
        budget: budget.score,
        district: district.score,
        noisePreference: noise.score,
        smokingPreference: smoking.score,
        petsPreference: pets.score,
        chronotype: chrono.score,
        personalityType: personality.score,
        occupationStatus: occupation.score,
      };

      for (const criterion of MATCHING_CRITERIA) {
        const score = rawScores[criterion];
        const level = priorities[criterion];
        const weight = MATCHING_PRIORITY_WEIGHTS[level];

        criterionScores[criterion] = score;
        weightedSum += score * weight;
        totalWeight += weight;

        if (score >= 0.99) matchedCriteria.push(criterion);
        else if (score > 0 && score < 1)
          partiallyMatchedCriteria.push(criterion);
        else mismatchedCriteria.push(criterion);

        if (level === 'required' && score < 0.5) {
          requiredMismatches.push(criterion);
        }
      }

      criterionScores.roommateGenderPreference = genderPreferenceScore;
      weightedSum += genderPreferenceScore * 0.4;
      totalWeight += 0.4;
      if (genderPreferenceScore >= 0.99) {
        matchedCriteria.push('roommateGenderPreference');
      } else if (genderPreferenceScore > 0 && genderPreferenceScore < 1) {
        partiallyMatchedCriteria.push('roommateGenderPreference');
      } else {
        mismatchedCriteria.push('roommateGenderPreference');
      }

      let ruleScore = totalWeight > 0 ? (weightedSum / totalWeight) * 100 : 0;
      if (requiredMismatches.length > 0) {
        // Required mismatches apply a strong penalty without dropping the user entirely.
        const penaltyRatio = Math.min(0.75, requiredMismatches.length * 0.25);
        ruleScore = ruleScore * (1 - penaltyRatio);
      }
      ruleScore = this.clampScore(ruleScore);

      const base: DiscoverUser = {
        ...candidateProfile,
        isSaved: favoriteIds.has(candidateProfile.id),
        isProfileComplete: this.isProfileComplete(candidateProfile),
        compatibility: Math.round(ruleScore),
        matchPercent: Math.round(ruleScore),
        ruleScore: Math.round(ruleScore),
        embeddingScore: null,
        aiScore: null,
        finalScore: Math.round(ruleScore),
        compatibilityReasons: this.buildCompatibilityReasons(
          matchedCriteria,
          requiredMismatches,
        ),
        compatibilityBreakdown: {
          matchedCriteria,
          partiallyMatchedCriteria,
          mismatchedCriteria,
          requiredMismatches,
          criterionScores,
        },
        aiReasoning: null,
        aiStrengths: [],
        aiRisks: [],
      };

      return base;
    });

    scored.sort((a, b) => (b.ruleScore ?? 0) - (a.ruleScore ?? 0));

    const meProfileText = this.semanticTextFromProfile(me);
    const cachedEmbeddings = this.resolveCachedEmbeddings({
      me: {
        embedding: me.embedding,
        text: meProfileText,
      },
      candidates: scored.map((candidate) => {
        const rawCandidate = candidateById.get(candidate.id);
        return {
          id: candidate.id,
          embedding: rawCandidate?.embedding ?? null,
          text: rawCandidate
            ? this.semanticTextFromProfile(rawCandidate)
            : '',
        };
      }),
    });
    const meVector = cachedEmbeddings.meVector;
    const candidateVectors = cachedEmbeddings.candidateVectors;
    const generatedCandidateCount = 0;

    let candidateEmbeddingsFound = 0;
    for (const candidate of scored) {
      const candidateVector = candidateVectors.get(candidate.id) ?? null;
      if (meVector && candidateVector) {
        const cosine = this.cosineSimilarity(meVector, candidateVector);
        candidate.embeddingScore = Math.round(
          this.clampScore(((cosine + 1) / 2) * 100),
        );
        candidateEmbeddingsFound += 1;
      } else {
        candidate.embeddingScore = null;
      }
    }

    for (const candidate of scored) {
      const rawCandidate = candidateById.get(candidate.id);
      const cache = cacheByCandidateId.get(candidate.id);
      if (
        rawCandidate &&
        cache &&
        this.isRecommendationCacheFresh({
          cache,
          currentUserUpdatedAt: me.updatedAt,
          candidateUpdatedAt: rawCandidate.updatedAt,
          currentEmbeddingUpdatedAt: me.embedding?.updatedAt,
          candidateEmbeddingUpdatedAt: rawCandidate.embedding?.updatedAt,
        })
      ) {
        candidate.aiScore =
          cache.aiScore == null
            ? null
            : Math.round(this.clampScore(cache.aiScore));
        candidate.aiReasoning = cache.reasoning ?? null;
        candidate.aiStrengths = this.toStringArray(cache.strengths);
        candidate.aiRisks = this.toStringArray(cache.risks);
      }

      candidate.finalScore = Math.round(
        this.computeFinalScore(
          candidate.ruleScore ?? 0,
          candidate.embeddingScore ?? null,
          candidate.aiScore ?? null,
        ),
      );
      candidate.compatibility = candidate.finalScore;
      candidate.matchPercent = candidate.finalScore;
    }

    scored.sort((a, b) => (b.finalScore ?? 0) - (a.finalScore ?? 0));
    let aiCallsMade = 0;

    const warmupCandidates: Array<{
      id: string;
      embedding: EmbeddingRow | null;
      text: string;
      aiProfile: Record<string, unknown>;
      scored: DiscoverUser;
    }> = [];

    for (const candidate of scored) {
      const rawCandidate = candidateById.get(candidate.id);
      if (!rawCandidate) continue;

      warmupCandidates.push({
        id: candidate.id,
        embedding: rawCandidate.embedding ?? null,
        text: this.semanticTextFromProfile(rawCandidate),
        aiProfile: this.compactAiProfile(rawCandidate),
        scored: candidate,
      });
    }

    this.queueRecommendationWarmup({
      currentUserId,
      me: {
        id: me.id,
        embedding: me.embedding,
        text: meProfileText,
        aiProfile: this.compactAiProfile(me),
      },
      candidates: warmupCandidates,
      maxCandidateEmbeddings: Math.min(embeddingTopN, 6),
      maxAiCandidates: Math.min(aiTopN, 2),
      aiConcurrency: Math.min(aiConcurrency, 2),
    });

    const candidatesToCache =
      specificCandidateIds.length > 0
        ? scored
        : scored.slice(0, Math.max(safeLimit * 2, 30));
    await Promise.all(
      candidatesToCache.map((candidate) =>
        this.upsertRecommendationCache(currentUserId, candidate),
      ),
    );

    scored.sort((a, b) => (b.finalScore ?? 0) - (a.finalScore ?? 0));
    const skip = (safePage - 1) * safeLimit;
    const paged = scored.slice(skip, skip + safeLimit);

    this.logger.debug(
      `Recommendation pipeline finished: user=${currentUserId}, candidates=${
        scored.length
      }, meEmbedding=${meVector ? 'present' : 'missing'}, candidateEmbeddings=${
        candidateEmbeddingsFound
      }/${scored.length}, generatedEmbeddings=${generatedCandidateCount}, aiCalls=${aiCallsMade}, durationMs=${
        Date.now() - startedAt
      }`,
    );

    return {
      data: paged,
      meta: {
        page: safePage,
        limit: safeLimit,
        total: scored.length,
        totalPages:
          scored.length === 0 ? 0 : Math.ceil(scored.length / safeLimit),
      },
    };
  }

  async getPublicProfile(currentUserId: string, targetUserId: string) {
    const user = await this.prisma.user.findFirst({
      where: {
        ...this.buildVisibleUserWhere(currentUserId),
        id: targetUserId,
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        age: true,
        city: true,
        bio: true,
        photos: true,
        occupationStatus: true,
        university: true,
        chronotype: true,
        noisePreference: true,
        personalityType: true,
        smokingPreference: true,
        petsPreference: true,
        searchBudgetMin: true,
        searchBudgetMax: true,
        searchDistrict: true,
        roommateGenderPreference: true,
        stayTerm: true,
        onboardingCompleted: true,
        verificationStatus: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw new NotFoundException('Пользователь не найден');
    }

    const favorite = await this.prisma.favoriteUser.findUnique({
      where: {
        ownerId_targetUserId: {
          ownerId: currentUserId,
          targetUserId,
        },
      },
    });

    return {
      ...user,
      isSaved: !!favorite,
      isProfileComplete: this.isProfileComplete(user),
    };
  }

  async discoverUsers(
    currentUserId: string,
    query: DiscoverUsersQueryDto,
  ): Promise<{
    data: DiscoverUser[];
    meta: { page: number; limit: number; total: number; totalPages: number };
  }> {
    const {
      page = 1,
      limit = 10,
      budgetMax,
      district,
      gender,
      ageRange,
    } = query;

    const safePage = page < 1 ? 1 : page;
    const safeLimit = Math.min(Math.max(limit, 1), 50);
    const skip = (safePage - 1) * safeLimit;
    const currentUser = await this.prisma.user.findUnique({
      where: { id: currentUserId },
      select: { roommateGenderPreference: true },
    });

    const where: Prisma.UserWhereInput =
      this.buildVisibleUserWhere(currentUserId);

    const andConditions: Prisma.UserWhereInput[] = [];
    this.pushRoommateGenderPreferenceFilter(
      andConditions,
      currentUser?.roommateGenderPreference,
    );
    this.appendCandidateFilters(andConditions, {
      district,
      budgetMax,
      gender,
      ageRange,
    });

    if (andConditions.length > 0) {
      where.AND = andConditions;
    }

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: safeLimit,
        select: {
          id: true,
          firstName: true,
          lastName: true,
          age: true,
          city: true,
          bio: true,
          photos: true,
          gender: true,
          occupationStatus: true,
          university: true,
          chronotype: true,
          noisePreference: true,
          personalityType: true,
          smokingPreference: true,
          petsPreference: true,
          searchBudgetMin: true,
          searchBudgetMax: true,
          searchDistrict: true,
          stayTerm: true,
          roommateGenderPreference: true,
          onboardingCompleted: true,
          emailVerified: true,
          phoneVerified: true,
          verificationStatus: true,
          createdAt: true,
          updatedAt: true,
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    const favorites = await this.prisma.favoriteUser.findMany({
      where: {
        ownerId: currentUserId,
        targetUserId: { in: users.map((user) => user.id) },
      },
      select: { targetUserId: true },
    });
    const favoriteIds = new Set(
      favorites.map((favorite) => favorite.targetUserId),
    );

    // Fisher-Yates shuffle in-memory
    for (let i = users.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [users[i], users[j]] = [users[j], users[i]];
    }

    const data: DiscoverUser[] = users.map((user) => ({
      ...user,
      isSaved: favoriteIds.has(user.id),
      isProfileComplete: this.isProfileComplete(user),
      compatibility: null,
      compatibilityReasons: [],
    }));

    const totalPages = total === 0 ? 0 : Math.ceil(total / safeLimit);

    return {
      data,
      meta: {
        page: safePage,
        limit: safeLimit,
        total,
        totalPages,
      },
    };
  }

  async filterUsers(
    currentUserId: string,
    query: FilterUsersQueryDto,
  ): Promise<{
    data: DiscoverUser[];
    meta: { page: number; limit: number; total: number; totalPages: number };
  }> {
    return this.getPersonalizedRecommendations(
      currentUserId,
      query.page ?? 1,
      query.limit ?? 20,
      {
        city: query.city,
        district: query.district,
        priceMin: query.priceMin,
        priceMax: query.priceMax,
        gender: query.gender ?? null,
        petsPreference: query.petsPreference ?? null,
        smokingPreference: query.smokingPreference ?? null,
        noisePreference: query.noisePreference ?? null,
      },
    );
  }

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        phone: true,
        firstName: true,
        lastName: true,
        photos: true,
        gender: true,
        age: true,
        bio: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw new NotFoundException('Пользователь не найден');
    }

    return user;
  }

  async updateMe(userId: string, updateUserDto: UpdateUserDto) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: updateUserDto,
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        gender: true,
        age: true,
        bio: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    await this.refreshUserEmbedding(userId).catch(() => false);

    return user;
  }

  async updatePassword(userId: string, updatePasswordDto: UpdatePasswordDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('Пользователь не найден');
    }

    const isPasswordValid = await bcrypt.compare(
      updatePasswordDto.currentPassword,
      user.password,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Текущий пароль указан неверно');
    }

    const hashedPassword = await bcrypt.hash(updatePasswordDto.newPassword, 10);

    await this.prisma.user.update({
      where: { id: userId },
      data: { password: hashedPassword },
    });

    return { message: 'Пароль успешно обновлён' };
  }

  async updateAvatarFile(userId: string, file: Express.Multer.File) {
    const avatarPath = `/uploads/avatars/${file.filename}`;

    return this.prisma.user.update({
      where: { id: userId },
      data: {
        photos: [avatarPath],
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        photos: true,
        updatedAt: true,
      },
    });
  }
}
