import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Prisma, UserRole, VerificationStatus } from '@prisma/client';
import { RejectVerificationDto } from './dto/reject-verification.dto';
import { UpdateUserRoleDto } from './dto/update-user-role.dto';
import { SetUserBanDto } from './dto/set-user-ban.dto';

type Reviewer = Prisma.UserGetPayload<{
  select: {
    id: true;
    email: true;
    phone: true;
    role: true;
    firstName: true;
    lastName: true;
  };
}>;

@Injectable()
export class AdminVerificationsService {
  constructor(private prisma: PrismaService) {}

  private buildDisplayName(user: {
    firstName: string | null;
    lastName: string | null;
    email: string | null;
    phone: string | null;
  }) {
    const full = [user.firstName, user.lastName].filter(Boolean).join(' ').trim();
    return full || user.firstName || user.email || user.phone || 'Unknown';
  }

  async getPendingVerifications() {
    const users = await this.prisma.user.findMany({
      where: {
        verificationStatus: {
          in: [VerificationStatus.PENDING, VerificationStatus.NONE],
        },
      },
      select: {
        id: true,
        email: true,
        phone: true,
        firstName: true,
        lastName: true,
        verificationDocumentUrl: true,
        verificationSelfieUrl: true,
        verificationStatus: true,
        updatedAt: true,
        createdAt: true,
      },
      orderBy: { updatedAt: 'desc' },
    });

    const appUrl = process.env.APP_URL;

    return users.map((user) => ({
      id: user.id,
      name: this.buildDisplayName(user),
      email: user.email,
      phone: user.phone,
      documentUrl: user.verificationDocumentUrl,
      selfieUrl: user.verificationSelfieUrl,
      documentFullUrl:
        appUrl && user.verificationDocumentUrl
          ? `${appUrl}${user.verificationDocumentUrl}`
          : null,
      selfieFullUrl:
        appUrl && user.verificationSelfieUrl
          ? `${appUrl}${user.verificationSelfieUrl}`
          : null,
      status: user.verificationStatus,
      submittedAt: user.updatedAt,
      createdAt: user.createdAt,
    }));
  }

  async getUsers(search?: string) {
    const q = (search ?? '').trim();
    const where: Prisma.UserWhereInput =
      q.length === 0
        ? {}
        : {
            OR: [
              { email: { contains: q, mode: 'insensitive' } },
              { phone: { contains: q, mode: 'insensitive' } },
              { firstName: { contains: q, mode: 'insensitive' } },
              { lastName: { contains: q, mode: 'insensitive' } },
            ],
          };

    return this.prisma.user.findMany({
      where,
      select: {
        id: true,
        email: true,
        phone: true,
        firstName: true,
        lastName: true,
        role: true,
        isBanned: true,
        verificationStatus: true,
        onboardingCompleted: true,
        createdAt: true,
        updatedAt: true,
      },
      orderBy: { updatedAt: 'desc' },
      take: 300,
    });
  }

  async updateUserRole(
    userId: string,
    dto: UpdateUserRoleDto,
    adminId: string,
  ) {
    if (userId === adminId) {
      throw new BadRequestException('You cannot change your own role');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true },
    });

    if (!user) throw new NotFoundException('User not found');

    return this.prisma.user.update({
      where: { id: userId },
      data: { role: dto.role as UserRole },
      select: {
        id: true,
        role: true,
        email: true,
        phone: true,
        isBanned: true,
        updatedAt: true,
      },
    });
  }

  async setUserBanStatus(
    userId: string,
    dto: SetUserBanDto,
    adminId: string,
  ) {
    if (userId === adminId && dto.isBanned) {
      throw new BadRequestException('You cannot ban your own account');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true },
    });

    if (!user) throw new NotFoundException('User not found');

    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: { isBanned: dto.isBanned },
      select: {
        id: true,
        email: true,
        phone: true,
        role: true,
        isBanned: true,
        updatedAt: true,
      },
    });

    if (dto.isBanned) {
      await this.prisma.refreshToken.deleteMany({ where: { userId } });
    }

    return updated;
  }

  async getVerificationDetails(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        phone: true,
        firstName: true,
        lastName: true,
        age: true,
        city: true,
        verificationStatus: true,
        verificationDocumentUrl: true,
        verificationSelfieUrl: true,
        verificationRejectReason: true,
        verificationReviewedAt: true,
        verificationReviewedBy: true,
        updatedAt: true,
        createdAt: true,
      },
    });

    if (!user) throw new NotFoundException('User not found');

    let reviewedByUser: Reviewer | null = null;
    if (user.verificationReviewedBy) {
      reviewedByUser = await this.prisma.user.findUnique({
        where: { id: user.verificationReviewedBy },
        select: {
          id: true,
          email: true,
          phone: true,
          firstName: true,
          lastName: true,
          role: true,
        },
      });
    }

    const appUrl = process.env.APP_URL;

    return {
      id: user.id,
      name: this.buildDisplayName(user),
      email: user.email,
      phone: user.phone,
      age: user.age,
      city: user.city,
      verificationStatus: user.verificationStatus,
      verificationDocumentUrl: user.verificationDocumentUrl,
      verificationSelfieUrl: user.verificationSelfieUrl,
      documentFullUrl:
        appUrl && user.verificationDocumentUrl
          ? `${appUrl}${user.verificationDocumentUrl}`
          : null,
      selfieFullUrl:
        appUrl && user.verificationSelfieUrl
          ? `${appUrl}${user.verificationSelfieUrl}`
          : null,
      verificationRejectReason: user.verificationRejectReason,
      verificationReviewedAt: user.verificationReviewedAt,
      verificationReviewedBy: reviewedByUser
        ? {
            id: reviewedByUser.id,
            name: this.buildDisplayName(reviewedByUser),
            email: reviewedByUser.email,
            phone: reviewedByUser.phone,
            role: reviewedByUser.role,
          }
        : null,
      submittedAt: user.updatedAt,
      createdAt: user.createdAt,
    };
  }

  async approveVerification(userId: string, reviewerId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        verificationStatus: true,
        verificationDocumentUrl: true,
        verificationSelfieUrl: true,
      },
    });

    if (!user) throw new NotFoundException('User not found');

    if (user.verificationStatus === VerificationStatus.VERIFIED) {
      throw new BadRequestException('User is already verified');
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: {
        verificationStatus: VerificationStatus.VERIFIED,
        verificationReviewedAt: new Date(),
        verificationReviewedBy: reviewerId,
        verificationRejectReason: null,
      },
      select: {
        id: true,
        verificationStatus: true,
        verificationReviewedAt: true,
        verificationReviewedBy: true,
      },
    });
  }

  async rejectVerification(
    userId: string,
    reviewerId: string,
    dto: RejectVerificationDto,
  ) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, verificationStatus: true },
    });

    if (!user) throw new NotFoundException('User not found');

    if (user.verificationStatus !== VerificationStatus.PENDING) {
      throw new BadRequestException(
        `Cannot reject verification with status: ${user.verificationStatus}`,
      );
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: {
        verificationStatus: VerificationStatus.REJECTED,
        verificationRejectReason: dto.reason,
        verificationReviewedAt: new Date(),
        verificationReviewedBy: reviewerId,
      },
      select: {
        id: true,
        verificationStatus: true,
        verificationRejectReason: true,
        verificationReviewedAt: true,
        verificationReviewedBy: true,
      },
    });
  }
}
