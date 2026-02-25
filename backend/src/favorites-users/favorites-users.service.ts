import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UserRole, VerificationStatus } from '@prisma/client';

@Injectable()
export class FavoritesUsersService {
  constructor(private prisma: PrismaService) {}

  async addFavorite(ownerId: string, targetUserId: string) {
    if (ownerId === targetUserId) {
      throw new BadRequestException('You cannot favorite yourself');
    }

    const targetUser = await this.prisma.user.findUnique({
      where: {
        id: targetUserId,
        role: UserRole.USER,
        onboardingCompleted: true,
        verificationStatus: VerificationStatus.VERIFIED,
      },
      select: { id: true },
    });

    if (!targetUser) {
      throw new NotFoundException('User not found');
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

    return { message: 'User added to favorites' };
  }

  async removeFavorite(ownerId: string, targetUserId: string) {
    await this.prisma.favoriteUser.deleteMany({
      where: {
        ownerId,
        targetUserId,
      },
    });

    return { message: 'User removed from favorites' };
  }

  async listFavorites(
    ownerId: string,
    page: number,
    limit: number,
  ): Promise<{
    data: Array<{
      id: string;
      firstName: string | null;
      age: number | null;
      city: string | null;
      searchDistrict: string | null;
      photos: string[];
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
              age: true,
              city: true,
              searchDistrict: true,
              photos: true,
              createdAt: true,
            },
          },
        },
      }),
      this.prisma.favoriteUser.count({ where }),
    ]);

    const totalPages = total === 0 ? 0 : Math.ceil(total / safeLimit);

    const data = favorites.map((f) => ({
      id: f.target.id,
      firstName: f.target.firstName,
      age: f.target.age,
      city: f.target.city,
      searchDistrict: f.target.searchDistrict,
      photos: f.target.photos,
      createdAt: f.createdAt,
      isSaved: true as const,
    }));

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

