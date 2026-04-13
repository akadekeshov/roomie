import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import type { Express } from 'express';
import { Prisma, UserRole, VerificationStatus } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { UpdatePasswordDto } from './dto/update-password.dto';
import { DiscoverUsersQueryDto } from './dto/discover-users-query.dto';
import { FilterUsersQueryDto } from './dto/filter-users-query.dto';

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
    verificationStatus: true;
    createdAt: true;
  };
}>;

type DiscoverUser = UserPreview & {
  compatibility: number | null;
  compatibilityReasons: string[];
};

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async getRecommendations(currentUserId: string, page = 1, limit = 20) {
    return this.discoverUsers(currentUserId, { page, limit });
  }

  /**
   * Personalized recommendations for the current user based on their profile
   * (district, budget, lifestyle, roommate gender preference, etc.).
   */
  async getPersonalizedRecommendations(currentUserId: string, limit = 50): Promise<{
    data: DiscoverUser[];
    meta: { page: number; limit: number; total: number; totalPages: number };
  }> {
    const me = await this.prisma.user.findUnique({
      where: { id: currentUserId },
      select: {
        id: true,
        city: true,
        searchDistrict: true,
        searchBudgetMin: true,
        searchBudgetMax: true,
        roommateGenderPreference: true,
        noisePreference: true,
        smokingPreference: true,
        petsPreference: true,
        onboardingCompleted: true,
        verificationStatus: true,
        isBanned: true,
      },
    });

    if (!me || me.isBanned) {
      return {
        data: [],
        meta: { page: 1, limit, total: 0, totalPages: 0 },
      };
    }

    if (!me.onboardingCompleted || me.verificationStatus !== VerificationStatus.VERIFIED) {
      // Profile not ready for personalized recommendations.
      return {
        data: [],
        meta: { page: 1, limit, total: 0, totalPages: 0 },
      };
    }

    const where: Prisma.UserWhereInput = {
      role: UserRole.USER,
      verificationStatus: VerificationStatus.VERIFIED,
      onboardingCompleted: true,
      id: { not: currentUserId },
    };

    const andConditions: Prisma.UserWhereInput[] = [];

    const normalizedDistrict =
      typeof me.searchDistrict === 'string'
        ? me.searchDistrict.trim()
        : me.searchDistrict ?? null;

    if (normalizedDistrict && normalizedDistrict.length > 0) {
      andConditions.push({ searchDistrict: normalizedDistrict });
    } else if (me.city) {
      andConditions.push({ city: me.city });
    }

    if (andConditions.length > 0) {
      where.AND = andConditions;
    }

    const candidates = await this.prisma.user.findMany({
      where,
      take: limit * 3, // take more, then sort by compatibility
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
        verificationStatus: true,
        createdAt: true,
      },
    });

    const scored: DiscoverUser[] = candidates.map((user) => {
      let score = 0;
      const reasons: string[] = [];

      // District / city match.
      if (
        me.searchDistrict &&
        user.searchDistrict &&
        me.searchDistrict === user.searchDistrict
      ) {
        score += 30;
        reasons.push('Совпадает район поиска');
      } else if (me.city && user.city && me.city === user.city) {
        score += 15;
        reasons.push('Совпадает город');
      }

      // Budget overlap.
      if (me.searchBudgetMin != null || me.searchBudgetMax != null) {
        const myMin = me.searchBudgetMin ?? 0;
        const myMax = me.searchBudgetMax ?? Number.MAX_SAFE_INTEGER;
        const theirMin = user.searchBudgetMin ?? 0;
        const theirMax = user.searchBudgetMax ?? Number.MAX_SAFE_INTEGER;

        const overlaps = myMin <= theirMax && theirMin <= myMax;
        if (overlaps) {
          score += 20;
          reasons.push('Похожий бюджет на аренду');
        }
      }

      // Roommate gender preference.
      if (me.roommateGenderPreference && user.gender) {
        if (me.roommateGenderPreference === 'ANY') {
          score += 5;
        } else if (me.roommateGenderPreference === user.gender) {
          score += 15;
          reasons.push('Подходит по предпочтению пола соседа');
        }
      }

      // Lifestyle: pets / smoking / noise.
      if (me.petsPreference && user.petsPreference && me.petsPreference === user.petsPreference) {
        score += 10;
        reasons.push('Совпадает отношение к животным');
      }

      if (
        me.smokingPreference &&
        user.smokingPreference &&
        me.smokingPreference === user.smokingPreference
      ) {
        score += 10;
        reasons.push('Совпадает отношение к курению');
      }

      if (
        me.noisePreference &&
        user.noisePreference &&
        me.noisePreference === user.noisePreference
      ) {
        score += 10;
        reasons.push('Похожие предпочтения по образу жизни/шуму');
      }

      const compatibility = Math.max(0, Math.min(100, score));

      return {
        ...user,
        compatibility,
        compatibilityReasons: reasons,
      };
    });

    scored.sort(
      (a, b) => (b.compatibility ?? 0) - (a.compatibility ?? 0),
    );

    const page = 1;
    const paged = scored.slice(0, limit);

    return {
      data: paged,
      meta: {
        page,
        limit,
        total: scored.length,
        totalPages: scored.length === 0 ? 0 : Math.ceil(scored.length / limit),
      },
    };
  }

  async getPublicProfile(currentUserId: string, targetUserId: string) {
    const user = await this.prisma.user.findUnique({
      where: {
        id: targetUserId,
        role: UserRole.USER,
        onboardingCompleted: true,
        verificationStatus: VerificationStatus.VERIFIED,
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
        createdAt: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
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

    const where: Prisma.UserWhereInput = {
      role: UserRole.USER,
      verificationStatus: VerificationStatus.VERIFIED,
      onboardingCompleted: true,
      id: { not: currentUserId },
    };

    const andConditions: Prisma.UserWhereInput[] = [];

    const normalizedDistrict =
      typeof district === 'string' ? district.trim() : district ?? null;

    if (normalizedDistrict && normalizedDistrict !== 'Все районы') {
      andConditions.push({ searchDistrict: normalizedDistrict });
    }

    if (gender) {
      andConditions.push({ gender });
    }

    if (ageRange === '18-25') {
      andConditions.push({
        age: { gte: 18, lte: 25 },
      });
    } else if (ageRange === '25+') {
      andConditions.push({
        age: { gte: 25 },
      });
    }

    if (budgetMax !== undefined && budgetMax !== null) {
      andConditions.push({
        OR: [
          { searchBudgetMin: { lte: budgetMax } },
          { searchBudgetMin: null },
        ],
      });
    }

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
          verificationStatus: true,
          createdAt: true,
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    // Fisher-Yates shuffle in-memory
    for (let i = users.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [users[i], users[j]] = [users[j], users[i]];
    }

    const data: DiscoverUser[] = users.map((user) => ({
      ...user,
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
    data: UserPreview[];
    meta: { page: number; limit: number; total: number; totalPages: number };
  }> {
    const {
      page = 1,
      limit = 20,
      city,
      district,
      priceMin,
      priceMax,
      gender,
      petsPreference,
      smokingPreference,
      noisePreference,
    } = query;

    const safePage = page < 1 ? 1 : page;
    const safeLimit = Math.min(Math.max(limit, 1), 50);
    const skip = (safePage - 1) * safeLimit;

    const where: Prisma.UserWhereInput = {
      role: UserRole.USER,
      verificationStatus: VerificationStatus.VERIFIED,
      onboardingCompleted: true,
      id: { not: currentUserId },
    };

    const andConditions: Prisma.UserWhereInput[] = [];

    const normalizedCity =
      typeof city === 'string' ? city.trim() : city ?? null;
    const normalizedDistrict =
      typeof district === 'string' ? district.trim() : district ?? null;

    if (normalizedCity && normalizedCity.length > 0) {
      andConditions.push({
        city: {
          contains: normalizedCity,
          mode: 'insensitive',
        },
      });
    }

    if (normalizedDistrict && normalizedDistrict.length > 0) {
      andConditions.push({
        searchDistrict: normalizedDistrict,
      });
    }

    if (priceMin !== undefined || priceMax !== undefined) {
      const budgetCondition: Prisma.UserWhereInput = {};

      if (priceMin !== undefined) {
        budgetCondition.searchBudgetMin = { gte: priceMin };
      }

      if (priceMax !== undefined) {
        budgetCondition.searchBudgetMax = { lte: priceMax };
      }

      andConditions.push(budgetCondition);
    }

    if (gender) {
      andConditions.push({ gender });
    }

    if (petsPreference) {
      andConditions.push({ petsPreference });
    }

    if (smokingPreference) {
      andConditions.push({ smokingPreference });
    }

    if (noisePreference) {
      andConditions.push({ noisePreference });
    }

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
          verificationStatus: true,
          createdAt: true,
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    return {
      data: users,
      meta: {
        page: safePage,
        limit: safeLimit,
        total,
        totalPages: total === 0 ? 0 : Math.ceil(total / safeLimit),
      },
    };
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
      throw new NotFoundException('User not found');
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

    return user;
  }

  async updatePassword(userId: string, updatePasswordDto: UpdatePasswordDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const isPasswordValid = await bcrypt.compare(
      updatePasswordDto.currentPassword,
      user.password,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Current password is incorrect');
    }

    const hashedPassword = await bcrypt.hash(updatePasswordDto.newPassword, 10);

    await this.prisma.user.update({
      where: { id: userId },
      data: { password: hashedPassword },
    });

    return { message: 'Password updated successfully' };
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
