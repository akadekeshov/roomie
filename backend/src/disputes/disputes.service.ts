import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  AgreementStatus,
  DisputeAction,
  DisputeDecision,
  DisputeStatus,
  PaymentStatus,
  Prisma,
  UserRole,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDisputeDto } from './dto/create-dispute.dto';
import { DisputeAdminQueryDto } from './dto/dispute-admin-query.dto';
import { ResolveDisputeDto } from './dto/resolve-dispute.dto';
import { UpdateDisputeStatusDto } from './dto/update-dispute-status.dto';

type CurrentUserPayload = {
  id: string;
  role?: UserRole;
};

const disputeUserSelect = {
  id: true,
  firstName: true,
  lastName: true,
  photos: true,
  city: true,
  verificationStatus: true,
} satisfies Prisma.UserSelect;

const disputeInclude = {
  reporter: {
    select: disputeUserSelect,
  },
  accused: {
    select: disputeUserSelect,
  },
  reviewedBy: {
    select: {
      id: true,
      firstName: true,
      lastName: true,
      role: true,
    },
  },
  agreement: {
    select: {
      id: true,
      status: true,
      firstUserId: true,
      secondUserId: true,
      cancelledAt: true,
    },
  },
  conversation: {
    select: {
      id: true,
    },
  },
} satisfies Prisma.DisputeInclude;

type DisputeWithRelations = Prisma.DisputeGetPayload<{
  include: typeof disputeInclude;
}>;

type DisputeDirection = 'OUTGOING' | 'INCOMING';

@Injectable()
export class DisputesService {
  constructor(private readonly prisma: PrismaService) {}

  async createDispute(dto: CreateDisputeDto, currentUser: CurrentUserPayload) {
    await this.ensureUserCanCreateDispute(currentUser.id);

    const accusedId = dto.accusedId.trim();

    if (accusedId === currentUser.id) {
      throw new BadRequestException('Нельзя подать жалобу на самого себя.');
    }

    if (!dto.conversationId && !dto.agreementId) {
      throw new BadRequestException(
        'Жалоба должна быть связана с чатом или договором.',
      );
    }

    if (dto.conversationId) {
      await this.ensureConversationComplaintAccess(
        dto.conversationId,
        currentUser.id,
        accusedId,
      );
    }

    if (dto.agreementId) {
      await this.ensureAgreementComplaintAccess(
        dto.agreementId,
        currentUser.id,
        accusedId,
      );
    }

    const dispute = await this.prisma.dispute.create({
      data: {
        agreementId: dto.agreementId,
        conversationId: dto.conversationId,
        reporterId: currentUser.id,
        accusedId,
        reason: dto.reason,
        status: DisputeStatus.OPEN,
        title: dto.title.trim(),
        description: dto.description.trim(),
        evidenceUrls:
          dto.evidenceUrls
            ?.map((url) => url.trim())
            .filter((url) => url.length > 0) ?? [],
      },
      include: disputeInclude,
    });

    return {
      ...this.decorateDisputeForViewer(dispute, currentUser.id),
      message: 'Жалоба успешно отправлена.',
    };
  }

  async getMyDisputes(userId: string) {
    await this.clearExpiredRestrictionIfNeeded(userId);

    const disputes = await this.prisma.dispute.findMany({
      where: {
        OR: [{ reporterId: userId }, { accusedId: userId }],
      },
      include: disputeInclude,
      orderBy: { createdAt: 'desc' },
    });

    return disputes.map((dispute) => this.decorateDisputeForViewer(dispute, userId));
  }

  async getDisputeById(id: string, currentUser: CurrentUserPayload) {
    const dispute = await this.prisma.dispute.findUnique({
      where: { id },
      include: disputeInclude,
    });

    if (!dispute) {
      throw new NotFoundException('Жалоба не найдена.');
    }

    const hasAccess =
      dispute.reporterId === currentUser.id ||
      dispute.accusedId === currentUser.id ||
      currentUser.role === UserRole.ADMIN ||
      currentUser.role === UserRole.MODERATOR;

    if (!hasAccess) {
      throw new ForbiddenException('У вас нет прав для выполнения этого действия.');
    }

    return this.decorateDisputeForViewer(dispute, currentUser.id);
  }

  async getAllDisputes(query: DisputeAdminQueryDto) {
    return this.prisma.dispute.findMany({
      where: {
        status: query.status,
        reason: query.reason,
      },
      include: disputeInclude,
      orderBy: { createdAt: 'desc' },
    });
  }

  async resolveDispute(
    id: string,
    dto: ResolveDisputeDto,
    currentUser: CurrentUserPayload,
  ) {
    if (
      currentUser.role !== UserRole.ADMIN &&
      currentUser.role !== UserRole.MODERATOR
    ) {
      throw new ForbiddenException('У вас нет прав для рассмотрения жалоб.');
    }

    const dispute = await this.prisma.dispute.findUnique({
      where: { id },
      include: disputeInclude,
    });

    if (!dispute) {
      throw new NotFoundException('Жалоба не найдена.');
    }

    const trimmedComment = dto.adminComment?.trim() || null;

    if (
      (dto.decision === DisputeDecision.ACCEPTED ||
        dto.decision === DisputeDecision.REJECTED) &&
      !trimmedComment
    ) {
      throw new BadRequestException(
        'Комментарий модератора обязателен для этого решения.',
      );
    }

    if (dto.decision === DisputeDecision.ACCEPTED && !dto.action) {
      throw new BadRequestException(
        'Выберите действие для подтвержденной жалобы.',
      );
    }

    if (
      dto.decision !== DisputeDecision.ACCEPTED &&
      dto.action &&
      dto.action !== DisputeAction.NONE
    ) {
      throw new BadRequestException(
        'Нельзя применить действие без подтверждения жалобы.',
      );
    }

    const now = new Date();

    const resolved = await this.prisma.$transaction(async (tx) => {
      switch (dto.decision) {
        case DisputeDecision.REJECTED:
          return tx.dispute.update({
            where: { id },
            data: {
              status: DisputeStatus.REJECTED,
              decision: DisputeDecision.REJECTED,
              action: DisputeAction.NONE,
              adminComment: trimmedComment,
              resultText: 'Жалоба отклонена. Нарушение не подтверждено.',
              reviewedById: currentUser.id,
              reviewedAt: now,
              actionAppliedAt: null,
              actionExpiresAt: null,
              accusedNotifiedAt: now,
              reporterNotifiedAt: now,
            },
            include: disputeInclude,
          });
        case DisputeDecision.NEED_MORE_INFO:
          return tx.dispute.update({
            where: { id },
            data: {
              status: DisputeStatus.IN_REVIEW,
              decision: DisputeDecision.NEED_MORE_INFO,
              action: DisputeAction.NONE,
              adminComment: trimmedComment,
              resultText:
                'Для рассмотрения жалобы требуется дополнительная информация.',
              reviewedById: currentUser.id,
              reviewedAt: now,
              actionAppliedAt: null,
              actionExpiresAt: null,
              accusedNotifiedAt: now,
              reporterNotifiedAt: now,
            },
            include: disputeInclude,
          });
        case DisputeDecision.ACCEPTED:
          return this.applyAcceptedDecision(
            tx,
            dispute,
            dto,
            trimmedComment,
            currentUser.id,
            now,
          );
        default:
          throw new BadRequestException('Нельзя применить действие без подтверждения жалобы.');
      }
    });

    return resolved;
  }

  async updateDisputeStatusLegacy(
    id: string,
    dto: UpdateDisputeStatusDto,
    currentUser: CurrentUserPayload,
  ) {
    switch (dto.status) {
      case DisputeStatus.IN_REVIEW:
        return this.resolveDispute(
          id,
          {
            decision: DisputeDecision.NEED_MORE_INFO,
            action: DisputeAction.NONE,
            adminComment: dto.adminComment,
          },
          currentUser,
        );
      case DisputeStatus.REJECTED:
        return this.resolveDispute(
          id,
          {
            decision: DisputeDecision.REJECTED,
            action: DisputeAction.NONE,
            adminComment: dto.adminComment,
          },
          currentUser,
        );
      case DisputeStatus.RESOLVED:
        return this.resolveDispute(
          id,
          {
            decision: DisputeDecision.ACCEPTED,
            action: DisputeAction.WARNING,
            adminComment:
              dto.adminComment ??
              'Жалоба подтверждена. Пользователю вынесено предупреждение.',
          },
          currentUser,
        );
      case DisputeStatus.CLOSED:
        return this.prisma.dispute.update({
          where: { id },
          data: {
            status: DisputeStatus.CLOSED,
            adminComment: dto.adminComment?.trim() || null,
            reviewedById: currentUser.id,
            reviewedAt: new Date(),
          },
          include: disputeInclude,
        });
      case DisputeStatus.OPEN:
      default:
        return this.prisma.dispute.update({
          where: { id },
          data: {
            status: DisputeStatus.OPEN,
            adminComment: dto.adminComment?.trim() || null,
            reviewedById: currentUser.id,
            reviewedAt: new Date(),
          },
          include: disputeInclude,
        });
    }
  }

  private async applyAcceptedDecision(
    tx: Prisma.TransactionClient,
    dispute: DisputeWithRelations,
    dto: ResolveDisputeDto,
    adminComment: string | null,
    reviewerId: string,
    now: Date,
  ) {
    const action = dto.action ?? DisputeAction.NONE;

    if (action === DisputeAction.NONE) {
      throw new BadRequestException(
        'Выберите действие для подтвержденной жалобы.',
      );
    }

    if (!dispute.accusedId) {
      throw new BadRequestException(
        'Жалоба не содержит пользователя, к которому можно применить действие.',
      );
    }

    let resultText = '';
    let actionExpiresAt: Date | null = null;

    switch (action) {
      case DisputeAction.WARNING:
        await tx.user.update({
          where: { id: dispute.accusedId },
          data: {
            warningCount: {
              increment: 1,
            },
          },
        });
        resultText =
          'Жалоба подтверждена. Пользователю вынесено предупреждение.';
        break;
      case DisputeAction.TEMPORARY_RESTRICTION: {
        const restrictionDays = dto.restrictionDays ?? 7;
        actionExpiresAt = new Date(
          now.getTime() + restrictionDays * 24 * 60 * 60 * 1000,
        );
        await tx.user.update({
          where: { id: dispute.accusedId },
          data: {
            isRestricted: true,
            restrictedUntil: actionExpiresAt,
          },
        });
        resultText = `Жалоба подтверждена. Пользователь временно ограничен на ${restrictionDays} дней.`;
        break;
      }
      case DisputeAction.ACCOUNT_BAN:
        await tx.user.update({
          where: { id: dispute.accusedId },
          data: {
            isBanned: true,
            bannedAt: now,
            banReason: adminComment,
          },
        });
        resultText =
          'Жалоба подтверждена. Аккаунт пользователя заблокирован.';
        break;
      case DisputeAction.AGREEMENT_CANCELLED:
        if (!dispute.agreementId) {
          throw new BadRequestException(
            'Для отмены договора жалоба должна быть связана с договором.',
          );
        }

        await tx.roommateAgreement.update({
          where: { id: dispute.agreementId },
          data: {
            status: AgreementStatus.CANCELLED,
            cancelledAt: now,
            cancelledById: reviewerId,
          },
        });

        await tx.agreementPayment.updateMany({
          where: {
            agreementId: dispute.agreementId,
            status: PaymentStatus.PENDING,
          },
          data: {
            status: PaymentStatus.CANCELLED,
          },
        });

        resultText = 'Жалоба подтверждена. Связанный договор отменен.';
        break;
      case DisputeAction.PAYMENT_REQUIRED:
        resultText =
          'Жалоба подтверждена. Пользователю необходимо выполнить оплату по договору.';
        break;
      case DisputeAction.PROFILE_FLAGGED:
        await tx.user.update({
          where: { id: dispute.accusedId },
          data: {
            profileTrustPenalty: {
              increment: 10,
            },
          },
        });
        resultText =
          'Жалоба подтверждена. Профиль пользователя помечен как требующий внимания.';
        break;
      default:
        throw new BadRequestException(
          'Выберите действие для подтвержденной жалобы.',
        );
    }

    return tx.dispute.update({
      where: { id: dispute.id },
      data: {
        status: DisputeStatus.RESOLVED,
        decision: DisputeDecision.ACCEPTED,
        action,
        adminComment,
        resultText,
        reviewedById: reviewerId,
        reviewedAt: now,
        actionAppliedAt: now,
        actionExpiresAt,
        accusedNotifiedAt: now,
        reporterNotifiedAt: now,
      },
      include: disputeInclude,
    });
  }

  private async ensureConversationComplaintAccess(
    conversationId: string,
    reporterId: string,
    accusedId: string,
  ) {
    const conversation = await this.prisma.conversation.findUnique({
      where: { id: conversationId },
      select: {
        participants: {
          select: {
            userId: true,
          },
        },
      },
    });

    if (!conversation) {
      throw new NotFoundException('Чат не найден.');
    }

    const participantIds = conversation.participants.map((item) => item.userId);
    if (!participantIds.includes(reporterId)) {
      throw new ForbiddenException(
        'У вас нет прав для подачи жалобы по этому чату.',
      );
    }

    if (!participantIds.includes(accusedId) || accusedId === reporterId) {
      throw new BadRequestException(
        'Пользователь, на которого подается жалоба, не связан с этим чатом.',
      );
    }
  }

  private async ensureAgreementComplaintAccess(
    agreementId: string,
    reporterId: string,
    accusedId: string,
  ) {
    const agreement = await this.prisma.roommateAgreement.findUnique({
      where: { id: agreementId },
      select: {
        firstUserId: true,
        secondUserId: true,
      },
    });

    if (!agreement) {
      throw new NotFoundException('Договор не найден.');
    }

    const participantIds = [agreement.firstUserId, agreement.secondUserId];
    if (!participantIds.includes(reporterId)) {
      throw new ForbiddenException(
        'У вас нет прав для подачи жалобы по этому договору.',
      );
    }

    if (!participantIds.includes(accusedId) || accusedId === reporterId) {
      throw new BadRequestException(
        'Пользователь, на которого подается жалоба, не связан с этим договором.',
      );
    }
  }

  private async ensureUserCanCreateDispute(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        isBanned: true,
      },
    });

    if (!user) {
      throw new NotFoundException('Пользователь не найден.');
    }

    if (user.isBanned) {
      throw new ForbiddenException('Ваш аккаунт заблокирован.');
    }
  }

  private async clearExpiredRestrictionIfNeeded(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        isRestricted: true,
        restrictedUntil: true,
      },
    });

    if (
      user?.isRestricted &&
      user.restrictedUntil &&
      user.restrictedUntil <= new Date()
    ) {
      await this.prisma.user.update({
        where: { id: userId },
        data: {
          isRestricted: false,
          restrictedUntil: null,
        },
      });
    }
  }

  private decorateDisputeForViewer(
    dispute: DisputeWithRelations,
    currentUserId: string,
  ) {
    const direction: DisputeDirection =
      dispute.reporterId === currentUserId ? 'OUTGOING' : 'INCOMING';

    const counterparty =
      direction === 'OUTGOING' ? dispute.accused : dispute.reporter;

    return {
      ...dispute,
      direction,
      directionLabel:
        direction === 'OUTGOING'
          ? 'Вы подали жалобу'
          : 'На вас подали жалобу',
      counterparty,
      canAppeal: false,
      isActionApplied:
        dispute.action !== DisputeAction.NONE && dispute.actionAppliedAt != null,
      viewerResultText: this.getViewerResultText(dispute, direction),
    };
  }

  private getViewerResultText(
    dispute: DisputeWithRelations,
    direction: DisputeDirection,
  ) {
    if (direction === 'OUTGOING') {
      return dispute.resultText;
    }

    switch (dispute.action) {
      case DisputeAction.WARNING:
        return 'Вам вынесено предупреждение.';
      case DisputeAction.TEMPORARY_RESTRICTION:
        return 'Ваш аккаунт временно ограничен.';
      case DisputeAction.ACCOUNT_BAN:
        return 'Ваш аккаунт заблокирован.';
      case DisputeAction.AGREEMENT_CANCELLED:
        return 'Связанный договор отменен.';
      case DisputeAction.PAYMENT_REQUIRED:
        return 'Необходимо выполнить оплату по договору.';
      case DisputeAction.PROFILE_FLAGGED:
        return 'Ваш профиль помечен как требующий внимания.';
      case DisputeAction.NONE:
      default:
        if (dispute.decision === DisputeDecision.REJECTED) {
          return 'Жалоба отклонена.';
        }
        return dispute.resultText;
    }
  }
}
