import {
  Injectable,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { VerificationStatus } from '@prisma/client';
import { VerificationDocumentDto } from './dto/verification-document.dto';
import { VerificationSelfieDto } from './dto/verification-selfie.dto';
import type { Express } from 'express';

@Injectable()
export class VerificationService {
  constructor(private prisma: PrismaService) {}

  async uploadDocument(userId: string, dto: VerificationDocumentDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, verificationStatus: true },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    // If verified, allow re-uploading (user might want to update)
    // If rejected, allow re-uploading to resubmit
    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: {
        verificationDocumentUrl: dto.documentUrl,
        // Reset status if it was REJECTED and user is re-uploading
        ...(user.verificationStatus === VerificationStatus.REJECTED && {
          verificationStatus: VerificationStatus.NONE,
          verificationRejectReason: null,
        }),
      },
      select: {
        id: true,
        verificationDocumentUrl: true,
        verificationStatus: true,
      },
    });

    return updated;
  }

  async uploadDocumentFile(userId: string, file: Express.Multer.File) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, verificationStatus: true },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    const documentUrl = `/uploads/kyc/documents/${file.filename}`;

    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: {
        verificationDocumentUrl: documentUrl,
        ...(user.verificationStatus === VerificationStatus.REJECTED && {
          verificationStatus: VerificationStatus.NONE,
          verificationRejectReason: null,
        }),
      },
      select: {
        id: true,
        verificationDocumentUrl: true,
        verificationStatus: true,
      },
    });

    return updated;
  }

  async uploadSelfie(userId: string, dto: VerificationSelfieDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, verificationStatus: true },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    // If verified, allow re-uploading
    // If rejected, allow re-uploading to resubmit
    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: {
        verificationSelfieUrl: dto.selfieUrl,
        // Reset status if it was REJECTED and user is re-uploading
        ...(user.verificationStatus === VerificationStatus.REJECTED && {
          verificationStatus: VerificationStatus.NONE,
          verificationRejectReason: null,
        }),
      },
      select: {
        id: true,
        verificationSelfieUrl: true,
        verificationStatus: true,
      },
    });

    return updated;
  }

  async uploadSelfieFile(userId: string, file: Express.Multer.File) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, verificationStatus: true },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    const selfieUrl = `/uploads/kyc/selfies/${file.filename}`;

    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: {
        verificationSelfieUrl: selfieUrl,
        ...(user.verificationStatus === VerificationStatus.REJECTED && {
          verificationStatus: VerificationStatus.NONE,
          verificationRejectReason: null,
        }),
      },
      select: {
        id: true,
        verificationSelfieUrl: true,
        verificationStatus: true,
      },
    });

    return updated;
  }

  async submitVerification(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        verificationStatus: true,
        verificationDocumentUrl: true,
        verificationSelfieUrl: true,
      },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    if (user.verificationStatus === VerificationStatus.VERIFIED) {
      throw new ConflictException(
        'Verification already approved. Cannot resubmit.',
      );
    }

    if (!user.verificationDocumentUrl) {
      throw new BadRequestException('Verification document is required');
    }

    if (!user.verificationSelfieUrl) {
      throw new BadRequestException('Verification selfie is required');
    }

    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: {
        verificationStatus: VerificationStatus.PENDING,
        verificationRejectReason: null,
        verificationReviewedAt: null,
        verificationReviewedBy: null,
      },
      select: {
        id: true,
        verificationStatus: true,
        verificationDocumentUrl: true,
        verificationSelfieUrl: true,
      },
    });

    return updated;
  }

  async getMyVerification(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        verificationStatus: true,
        verificationDocumentUrl: true,
        verificationSelfieUrl: true,
        verificationRejectReason: true,
        verificationReviewedAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    return {
      status: user.verificationStatus,
      documentUrl: user.verificationDocumentUrl,
      selfieUrl: user.verificationSelfieUrl,
      rejectReason: user.verificationRejectReason,
      reviewedAt: user.verificationReviewedAt,
      lastUpdated: user.updatedAt,
    };
  }
}
