import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { UpdatePasswordDto } from './dto/update-password.dto';
import { VerificationStatus, UserRole } from '@prisma/client';
import type { Express } from 'express';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
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
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const avatarUrl = `/uploads/avatars/${file.filename}`;

    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: {
        photos: [avatarUrl],
      },
      select: {
        id: true,
        photos: true,
      },
    });

    return { avatarUrl: updated.photos[0] ?? null };
  }

  async getRecommendations(userId: string, page: number, limit: number) {
    const safePage = page < 1 ? 1 : page;
    const safeLimit = Math.min(Math.max(limit, 1), 50);
    const skip = (safePage - 1) * safeLimit;

    const baseWhere = {
      role: UserRole.USER,
      onboardingCompleted: true,
      verificationStatus: VerificationStatus.VERIFIED,
      NOT: { id: userId },
    } as const;

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where: baseWhere,
        orderBy: { createdAt: 'desc' },
        skip,
        take: safeLimit,
        select: {
          id: true,
          firstName: true,
          lastName: true,
          age: true,
          city: true,
          bio: true,
          searchDistrict: true,
          photos: true,
          createdAt: true,
          occupationStatus: true,
          searchBudgetMin: true,
          searchBudgetMax: true,
        },
      }),
      this.prisma.user.count({ where: baseWhere }),
    ]);

    const ids = users.map((u) => u.id);

    const favorites = ids.length
      ? await this.prisma.favoriteUser.findMany({
          where: {
            ownerId: userId,
            targetUserId: { in: ids },
          },
          select: { targetUserId: true },
        })
      : [];

    const favoriteSet = new Set(favorites.map((f) => f.targetUserId));

    const data = users.map((u) => ({
      id: u.id,
      firstName: u.firstName,
      lastName: u.lastName,
      age: u.age,
      city: u.city,
      bio: u.bio,
      searchDistrict: u.searchDistrict,
      photos: u.photos,
      createdAt: u.createdAt,
      isSaved: favoriteSet.has(u.id),
      occupationStatus: u.occupationStatus,
      searchBudgetMin: u.searchBudgetMin,
      searchBudgetMax: u.searchBudgetMax,
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
}
