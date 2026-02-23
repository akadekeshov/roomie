import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { Prisma, UserRole, VerificationStatus } from '@prisma/client';
import { UpdateUserDto } from './dto/update-user.dto';
import { UpdatePasswordDto } from './dto/update-password.dto';

type UserPreview = Prisma.UserGetPayload<{
  select: {
    id: true;
    firstName: true;
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
    createdAt: true;
  };
}>;

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

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
    page: number,
    limit: number,
  ): Promise<{
    data: UserPreview[];
    meta: { page: number; limit: number; total: number; totalPages: number };
  }> {
    const safePage = page < 1 ? 1 : page;
    const safeLimit = Math.min(Math.max(limit, 1), 50);
    const skip = (safePage - 1) * safeLimit;

    const where = {
      role: UserRole.USER,
      verificationStatus: VerificationStatus.VERIFIED,
      onboardingCompleted: true,
      id: { not: currentUserId },
    };

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: safeLimit,
        select: {
          id: true,
          firstName: true,
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
          createdAt: true,
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    // Fisher–Yates shuffle in-memory
    for (let i = users.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [users[i], users[j]] = [users[j], users[i]];
    }

    const totalPages = total === 0 ? 0 : Math.ceil(total / safeLimit);

    return {
      data: users,
      meta: {
        page: safePage,
        limit: safeLimit,
        total,
        totalPages,
      },
    };
  }

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
}
