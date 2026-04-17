import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';

@Injectable()
export class FavoritesUsersService {
  constructor(
    private prisma: PrismaService,
    private usersService: UsersService,
  ) {}

  private toStringArray(raw: unknown): string[] {
    if (!Array.isArray(raw)) return [];
    return raw.filter((value): value is string => typeof value === 'string');
  }

  private hasRussianContent(value: string | null | undefined): boolean {
    if (!value) return false;
    return /[\u0410-\u042f\u0430-\u044f\u0401\u0451]/.test(value);
  }

  private buildVisibleUserWhere(currentUserId?: string) {
    return {
      role: UserRole.USER,
      isBanned: false,
      ...(currentUserId ? { id: { not: currentUserId } } : {}),
      OR: [{ emailVerified: true }, { phoneVerified: true }],
    };
  }

  private buildPreferenceTag(petsPreference: string | null) {
    if (petsPreference === 'WITH_PETS') {
      return 'Можно с животными';
    }
    if (petsPreference === 'NO_PETS') {
      return 'Без животных';
    }
    return null;
  }

  private buildLifestyle(target: {
    chronotype: string | null;
    smokingPreference: string | null;
    petsPreference: string | null;
  }) {
    return {
      chronotype: target.chronotype,
      smoking:
        target.smokingPreference == null
          ? null
          : target.smokingPreference === 'SMOKER',
      petsAllowed:
        target.petsPreference == null
          ? null
          : target.petsPreference === 'WITH_PETS',
    };
  }

  async addFavorite(ownerId: string, targetUserId: string) {
    if (ownerId === targetUserId) {
      throw new BadRequestException('Нельзя добавить себя в сохранённые');
    }

    const targetUser = await this.prisma.user.findFirst({
      where: {
        ...this.buildVisibleUserWhere(ownerId),
        id: targetUserId,
      },
      select: { id: true },
    });

    if (!targetUser) {
      throw new NotFoundException('Пользователь не найден');
    }

    await this.prisma.favoriteUser.upsert({
      where: {
        ownerId_targetUserId: {
          ownerId,
          targetUserId,
        },
      },
      update: {},
      create: {
        ownerId,
        targetUserId,
      },
    });

    return { message: 'Пользователь добавлен в сохранённые' };
  }

  async removeFavorite(ownerId: string, targetUserId: string) {
    await this.prisma.favoriteUser.deleteMany({
      where: { ownerId, targetUserId },
    });

    return { message: 'Пользователь удалён из сохранённых' };
  }

  async listFavorites(
    ownerId: string,
    page: number,
    limit: number,
  ): Promise<{
    data: Array<{
      id: string;
      firstName: string | null;
      lastName: string | null;
      age: number | null;
      city: string | null;
      bio: string | null;
      searchDistrict: string | null;
      photos: string[];
      verificationStatus: string;
      occupationStatus: string | null;
      searchBudgetMin: number | null;
      searchBudgetMax: number | null;
      preferenceTag: string | null;
      isProfileComplete: boolean;
      lifestyle: Record<string, unknown>;
      compatibility: number;
      matchPercent: number;
      ruleScore: number;
      embeddingScore: number | null;
      aiScore: number | null;
      finalScore: number;
      compatibilityBreakdown: Record<string, unknown> | null;
      compatibilityReasons: string[];
      aiReasoning: string | null;
      aiStrengths: string[];
      aiRisks: string[];
      createdAt: Date;
      isSaved: true;
    }>;
    meta: { page: number; limit: number; total: number; totalPages: number };
  }> {
    const safePage = page < 1 ? 1 : page;
    const safeLimit = Math.min(Math.max(limit, 1), 50);
    const skip = (safePage - 1) * safeLimit;

    const where = { ownerId };

    const [favorites, total] = await Promise.all([
      this.prisma.favoriteUser.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take: safeLimit,
        include: {
          target: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              age: true,
              city: true,
              bio: true,
              searchDistrict: true,
              photos: true,
              verificationStatus: true,
              onboardingCompleted: true,
              occupationStatus: true,
              searchBudgetMin: true,
              searchBudgetMax: true,
              chronotype: true,
              smokingPreference: true,
              petsPreference: true,
              createdAt: true,
            },
          },
        },
      }),
      this.prisma.favoriteUser.count({ where }),
    ]);

    const targetIds = favorites.map((favorite) => favorite.target.id);

    const latestRecommendations =
      targetIds.length === 0
        ? { data: [] as Awaited<
            ReturnType<UsersService['getPersonalizedRecommendations']>
          >['data'] }
        : await this.usersService.getPersonalizedRecommendations(
            ownerId,
            1,
            targetIds.length,
            {
              candidateUserIds: targetIds,
            },
          );

    const cacheRows = await this.prisma.aiRecommendationCache.findMany({
      where: {
        currentUserId: ownerId,
        candidateUserId: { in: targetIds },
      },
      select: {
        candidateUserId: true,
        ruleScore: true,
        embeddingScore: true,
        aiScore: true,
        finalScore: true,
        reasoning: true,
        strengths: true,
        risks: true,
      },
    });

    const cacheByCandidateId = new Map(
      cacheRows.map((row) => [row.candidateUserId, row]),
    );
    const latestByCandidateId = new Map(
      latestRecommendations.data.map((row) => [row.id, row]),
    );

    const totalPages = total === 0 ? 0 : Math.ceil(total / safeLimit);

    const data = favorites.map((favorite) => {
      const latest = latestByCandidateId.get(favorite.target.id);
      const cache = cacheByCandidateId.get(favorite.target.id);

      const fallbackFinalScore = Math.round(cache?.finalScore ?? cache?.ruleScore ?? 0);
      const finalScore = Math.round(latest?.finalScore ?? fallbackFinalScore);
      const ruleScore = Math.round(latest?.ruleScore ?? cache?.ruleScore ?? finalScore);
      const embeddingScore =
        latest?.embeddingScore == null
          ? cache?.embeddingScore == null
            ? null
            : Math.round(cache.embeddingScore)
          : Math.round(latest.embeddingScore);
      const aiScore =
        latest?.aiScore == null
          ? cache?.aiScore == null
            ? null
            : Math.round(cache.aiScore)
          : Math.round(latest.aiScore);

      const strengths = (latest?.aiStrengths ??
              this.toStringArray(cache?.strengths)).filter((value) =>
            this.hasRussianContent(value),
          );
      const risks = (latest?.aiRisks ?? this.toStringArray(cache?.risks)).filter(
        (value) => this.hasRussianContent(value),
      );
      const reasoningSource = latest?.aiReasoning ?? cache?.reasoning ?? null;
      const reasoning = this.hasRussianContent(reasoningSource)
        ? reasoningSource
        : null;
      const compatibilityReasons = (latest?.compatibilityReasons ?? []).filter(
        (value) => this.hasRussianContent(value),
      );

      return {
        id: favorite.target.id,
        firstName: favorite.target.firstName,
        lastName: favorite.target.lastName,
        age: favorite.target.age,
        city: favorite.target.city,
        bio: favorite.target.bio,
        searchDistrict: favorite.target.searchDistrict,
        photos: favorite.target.photos,
        verificationStatus: favorite.target.verificationStatus,
        occupationStatus: favorite.target.occupationStatus,
        searchBudgetMin: favorite.target.searchBudgetMin,
        searchBudgetMax: favorite.target.searchBudgetMax,
        preferenceTag: this.buildPreferenceTag(favorite.target.petsPreference),
        isProfileComplete: favorite.target.onboardingCompleted,
        lifestyle: this.buildLifestyle(favorite.target),
        compatibility: finalScore,
        matchPercent: finalScore,
        ruleScore,
        embeddingScore,
        aiScore,
        finalScore,
        compatibilityBreakdown: latest?.compatibilityBreakdown ?? null,
        compatibilityReasons,
        aiReasoning: reasoning,
        aiStrengths: strengths,
        aiRisks: risks,
        createdAt: favorite.createdAt,
        isSaved: true as const,
      };
    });

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
}
