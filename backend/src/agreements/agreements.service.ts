import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  AgreementStatus,
  Prisma,
  RoommateAgreement,
  UserRole,
} from '@prisma/client';
import { PaymentsService } from '../payments/payments.service';
import { PrismaService } from '../prisma/prisma.service';
import { ConfirmAgreementDto } from './dto/confirm-agreement.dto';
import { CreateAgreementFromConversationDto } from './dto/create-agreement-from-conversation.dto';
import { UpdateAgreementDto } from './dto/update-agreement.dto';

type CurrentUserPayload = {
  id: string;
  role?: UserRole;
};

const agreementUserSelect = {
  id: true,
  firstName: true,
  lastName: true,
  age: true,
  photos: true,
  city: true,
  email: true,
  phone: true,
  verificationStatus: true,
} satisfies Prisma.UserSelect;

const agreementInclude = {
  creator: { select: agreementUserSelect },
  firstUser: { select: agreementUserSelect },
  secondUser: { select: agreementUserSelect },
  conversation: {
    select: {
      id: true,
      participants: {
        select: {
          userId: true,
        },
      },
    },
  },
  payments: {
    orderBy: [{ dueDate: 'asc' }, { createdAt: 'desc' }],
  },
  disputes: {
    select: {
      id: true,
      status: true,
      reason: true,
      createdAt: true,
    },
    orderBy: { createdAt: 'desc' },
  },
} satisfies Prisma.RoommateAgreementInclude;

type AgreementWithRelations = Prisma.RoommateAgreementGetPayload<{
  include: typeof agreementInclude;
}>;

type ConversationParticipantRecord = Prisma.ConversationGetPayload<{
  include: {
    participants: {
      include: {
        user: {
          select: typeof agreementUserSelect;
        };
      };
    };
  };
}>;

@Injectable()
export class AgreementsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly paymentsService: PaymentsService,
  ) {}

  private readonly defaultDisputeTerms =
    'Спорные ситуации сначала рассматриваются через чат, жалобу и модерацию внутри приложения.';

  async createFromConversation(
    dto: CreateAgreementFromConversationDto,
    currentUser: CurrentUserPayload,
  ) {
    await this.ensureAgreementActionAllowed(currentUser.id);

    const eligibility = await this.checkConversationEligibility(
      dto.conversationId,
      currentUser.id,
    );

    if (!eligibility.canCreateAgreement) {
      if (eligibility.existingAgreement?.status === AgreementStatus.DRAFT) {
        return this.getAgreementEntityOrThrow(eligibility.existingAgreement.id);
      }

      throw new BadRequestException(
        eligibility.reason ??
          'Чтобы создать договор, сначала нужно обсудить условия в чате.',
      );
    }

    const conversation = await this.getConversationForAgreement(
      dto.conversationId,
      currentUser.id,
    );
    const otherParticipant = this.getOtherParticipant(conversation, currentUser.id);

    const agreement = await this.prisma.roommateAgreement.create({
      data: {
        conversationId: conversation.id,
        creatorId: currentUser.id,
        firstUserId: currentUser.id,
        secondUserId: otherParticipant.id,
        status: AgreementStatus.DRAFT,
        disputeTerms: this.defaultDisputeTerms,
        digitalSignatureStatus: 'NONE',
        notaryStatus: 'NOT_REQUIRED',
      },
      include: agreementInclude,
    });

    return this.decorateAgreement(agreement, currentUser.id);
  }

  async getMyAgreements(currentUserId: string) {
    const agreements = await this.prisma.roommateAgreement.findMany({
      where: {
        OR: [{ firstUserId: currentUserId }, { secondUserId: currentUserId }],
      },
      include: agreementInclude,
      orderBy: { createdAt: 'desc' },
    });

    return agreements.map((agreement) =>
      this.decorateAgreement(agreement, currentUserId),
    );
  }

  async getAgreementById(id: string, currentUser: CurrentUserPayload) {
    const agreement = await this.ensureAgreementAccess(id, currentUser);
    return this.decorateAgreement(agreement, currentUser.id);
  }

  async updateAgreement(
    id: string,
    dto: UpdateAgreementDto,
    currentUser: CurrentUserPayload,
  ) {
    const agreement = await this.ensureAgreementAccess(id, currentUser);
    this.ensureParticipant(agreement, currentUser.id);

    if (agreement.status === AgreementStatus.ACTIVE) {
      throw new BadRequestException('Активный договор нельзя редактировать.');
    }

    if (agreement.status === AgreementStatus.PENDING_CONFIRMATION) {
      throw new BadRequestException(
        'Договор уже отправлен на подтверждение. Редактирование недоступно.',
      );
    }

    if (agreement.status !== AgreementStatus.DRAFT) {
      throw new BadRequestException(
        'Договор нельзя редактировать в текущем статусе.',
      );
    }

    const updated = await this.prisma.roommateAgreement.update({
      where: { id },
      data: this.mapAgreementUpdate(dto),
      include: agreementInclude,
    });

    return this.decorateAgreement(updated, currentUser.id);
  }

  async sendForConfirmation(id: string, currentUser: CurrentUserPayload) {
    await this.ensureAgreementActionAllowed(currentUser.id);

    const agreement = await this.ensureAgreementAccess(id, currentUser);
    this.ensureParticipant(agreement, currentUser.id);

    if (agreement.creatorId !== currentUser.id) {
      throw new ForbiddenException(
        'У вас нет прав для выполнения этого действия.',
      );
    }

    if (agreement.status !== AgreementStatus.DRAFT) {
      throw new BadRequestException(
        'Отправить на подтверждение можно только черновик договора.',
      );
    }

    if (!this.isAgreementReadyForConfirmation(agreement)) {
      throw new BadRequestException(
        'Заполните основные условия договора перед отправкой на подтверждение.',
      );
    }

    const now = new Date();
    const updated = await this.prisma.roommateAgreement.update({
      where: { id },
      data: {
        status: AgreementStatus.PENDING_CONFIRMATION,
        sentForConfirmationAt: now,
        firstUserConfirmedAt:
          agreement.firstUserId === currentUser.id
            ? agreement.firstUserConfirmedAt ?? now
            : agreement.firstUserConfirmedAt,
        secondUserConfirmedAt:
          agreement.secondUserId === currentUser.id
            ? agreement.secondUserConfirmedAt ?? now
            : agreement.secondUserConfirmedAt,
      },
      include: agreementInclude,
    });

    return this.decorateAgreement(updated, currentUser.id);
  }

  async confirmAgreement(
    id: string,
    dto: ConfirmAgreementDto,
    currentUser: CurrentUserPayload,
  ) {
    await this.ensureAgreementActionAllowed(currentUser.id);

    if (dto.confirm === false) {
      throw new BadRequestException('Подтверждение договора не выполнено.');
    }

    const agreement = await this.ensureAgreementAccess(id, currentUser);
    this.ensureParticipant(agreement, currentUser.id);

    if (agreement.status !== AgreementStatus.PENDING_CONFIRMATION) {
      throw new BadRequestException(
        'Подтверждение доступно только после отправки договора на подтверждение.',
      );
    }

    const alreadyConfirmed =
      agreement.firstUserId === currentUser.id
        ? agreement.firstUserConfirmedAt != null
        : agreement.secondUserConfirmedAt != null;

    if (alreadyConfirmed) {
      throw new BadRequestException('Вы уже подтвердили договор.');
    }

    const now = new Date();
    const firstUserConfirmedAt =
      agreement.firstUserId === currentUser.id ? now : agreement.firstUserConfirmedAt;
    const secondUserConfirmedAt =
      agreement.secondUserId === currentUser.id
        ? now
        : agreement.secondUserConfirmedAt;

    const nextStatus =
      firstUserConfirmedAt && secondUserConfirmedAt
        ? AgreementStatus.ACTIVE
        : AgreementStatus.PENDING_CONFIRMATION;

    const updated = await this.prisma.roommateAgreement.update({
      where: { id },
      data: {
        firstUserConfirmedAt,
        secondUserConfirmedAt,
        status: nextStatus,
      },
      include: agreementInclude,
    });

    if (updated.status === AgreementStatus.ACTIVE) {
      await this.paymentsService.createInitialAgreementPayments(updated);
    }

    return this.decorateAgreement(
      await this.getAgreementEntityOrThrow(id),
      currentUser.id,
    );
  }

  async rejectAgreement(id: string, currentUser: CurrentUserPayload) {
    const agreement = await this.ensureAgreementAccess(id, currentUser);
    this.ensureParticipant(agreement, currentUser.id);

    if (agreement.status !== AgreementStatus.PENDING_CONFIRMATION) {
      throw new BadRequestException(
        'Отклонить можно только договор, который ожидает подтверждения.',
      );
    }

    const updated = await this.prisma.roommateAgreement.update({
      where: { id },
      data: {
        status: AgreementStatus.REJECTED,
        rejectedAt: agreement.rejectedAt ?? new Date(),
        rejectedById: currentUser.id,
      },
      include: agreementInclude,
    });

    return this.decorateAgreement(updated, currentUser.id);
  }

  async cancelAgreement(id: string, currentUser: CurrentUserPayload) {
    const agreement = await this.ensureAgreementAccess(id, currentUser);
    const isAdmin = this.isModeratorOrAdmin(currentUser.role);
    const isParticipant =
      agreement.firstUserId === currentUser.id ||
      agreement.secondUserId === currentUser.id;
    const isCreator = agreement.creatorId === currentUser.id;

    if (!isAdmin && !isParticipant) {
      throw new ForbiddenException('У вас нет прав для выполнения этого действия.');
    }

    if (!isAdmin && agreement.status === AgreementStatus.ACTIVE) {
      throw new BadRequestException('Активный договор нельзя отменить.');
    }

    if (!isAdmin && agreement.status === AgreementStatus.DRAFT && !isCreator) {
      throw new ForbiddenException('У вас нет прав для выполнения этого действия.');
    }

    const updated = await this.prisma.roommateAgreement.update({
      where: { id },
      data: {
        status: AgreementStatus.CANCELLED,
        cancelledAt: agreement.cancelledAt ?? new Date(),
        cancelledById: currentUser.id,
      },
      include: agreementInclude,
    });

    return this.decorateAgreement(updated, currentUser.id);
  }

  async getConversationStatus(
    conversationId: string,
    currentUser: CurrentUserPayload,
  ) {
    return this.checkConversationEligibility(conversationId, currentUser.id);
  }

  async checkConversationEligibility(
    conversationId: string,
    currentUserId: string,
  ) {
    const conversation = await this.getConversationForAgreement(
      conversationId,
      currentUserId,
    );
    const otherParticipant = this.getOtherParticipant(conversation, currentUserId);

    const [messageCount, groupedMessages, existingAgreement] = await Promise.all([
      this.prisma.message.count({
        where: { conversationId },
      }),
      this.prisma.message.groupBy({
        by: ['senderId'],
        where: {
          conversationId,
          senderId: { in: [currentUserId, otherParticipant.id] },
        },
        _count: { senderId: true },
      }),
      this.findLatestRelevantAgreement(currentUserId, otherParticipant.id),
    ]);

    const bothUsersHaveMessages = [currentUserId, otherParticipant.id].every((id) =>
      groupedMessages.some(
        (entry) => entry.senderId === id && entry._count.senderId > 0,
      ),
    );

    if (existingAgreement) {
      const reason =
        existingAgreement.status === AgreementStatus.ACTIVE ||
        existingAgreement.status === AgreementStatus.PENDING_CONFIRMATION
          ? 'С этим пользователем уже есть активный или ожидающий подтверждения договор.'
          : 'Черновик договора уже создан.';

      return {
        canCreateAgreement: false,
        reason,
        existingAgreement: this.buildAgreementSummary(existingAgreement, currentUserId),
        messageCount,
        bothUsersHaveMessages,
      };
    }

    const canCreateAgreement = messageCount >= 3 || bothUsersHaveMessages;

    return {
      canCreateAgreement,
      reason: canCreateAgreement
        ? null
        : 'Чтобы создать договор, сначала нужно обсудить условия в чате.',
      existingAgreement: null,
      messageCount,
      bothUsersHaveMessages,
    };
  }

  async ensureAgreementAccess(
    agreementId: string,
    currentUser: CurrentUserPayload,
  ) {
    const agreement = await this.prisma.roommateAgreement.findUnique({
      where: { id: agreementId },
      include: agreementInclude,
    });

    if (!agreement) {
      throw new NotFoundException('Договор не найден.');
    }

    if (this.isModeratorOrAdmin(currentUser.role)) {
      return agreement;
    }

    const isParticipant =
      agreement.firstUserId === currentUser.id ||
      agreement.secondUserId === currentUser.id;

    if (!isParticipant) {
      throw new ForbiddenException('У вас нет прав для выполнения этого действия.');
    }

    return agreement;
  }

  getOtherParticipant(
    conversation: ConversationParticipantRecord,
    currentUserId: string,
  ) {
    const otherParticipant = conversation.participants.find(
      (participant) => participant.userId !== currentUserId,
    );

    if (!otherParticipant?.user) {
      throw new BadRequestException(
        'Чтобы создать договор, сначала нужно обсудить условия в чате.',
      );
    }

    return otherParticipant.user;
  }

  private async getConversationForAgreement(
    conversationId: string,
    currentUserId: string,
  ) {
    const conversation = await this.prisma.conversation.findUnique({
      where: { id: conversationId },
      include: {
        participants: {
          include: {
            user: {
              select: agreementUserSelect,
            },
          },
        },
      },
    });

    if (!conversation) {
      throw new NotFoundException('Чат не найден.');
    }

    const isParticipant = conversation.participants.some(
      (participant) => participant.userId === currentUserId,
    );

    if (!isParticipant) {
      throw new ForbiddenException('У вас нет прав для выполнения этого действия.');
    }

    if (conversation.participants.length < 2) {
      throw new BadRequestException(
        'Чтобы создать договор, сначала нужно обсудить условия в чате.',
      );
    }

    return conversation;
  }

  private async getAgreementEntityOrThrow(id: string) {
    const agreement = await this.prisma.roommateAgreement.findUnique({
      where: { id },
      include: agreementInclude,
    });

    if (!agreement) {
      throw new NotFoundException('Договор не найден.');
    }

    return agreement;
  }

  private async findLatestRelevantAgreement(firstUserId: string, secondUserId: string) {
    return this.prisma.roommateAgreement.findFirst({
      where: {
        status: {
          in: [
            AgreementStatus.DRAFT,
            AgreementStatus.WAITING_SECOND_PARTY,
            AgreementStatus.PENDING_CONFIRMATION,
            AgreementStatus.ACTIVE,
          ],
        },
        OR: [
          {
            firstUserId,
            secondUserId,
          },
          {
            firstUserId: secondUserId,
            secondUserId: firstUserId,
          },
        ],
      },
      include: agreementInclude,
      orderBy: { updatedAt: 'desc' },
    });
  }

  private ensureParticipant(agreement: RoommateAgreement, currentUserId: string) {
    const isParticipant =
      agreement.firstUserId === currentUserId ||
      agreement.secondUserId === currentUserId;

    if (!isParticipant) {
      throw new ForbiddenException('У вас нет прав для выполнения этого действия.');
    }
  }

  private isModeratorOrAdmin(role?: UserRole) {
    return role === UserRole.ADMIN || role === UserRole.MODERATOR;
  }

  private decorateAgreement(
    agreement: AgreementWithRelations,
    currentUserId: string,
  ) {
    const otherUser =
      agreement.firstUserId === currentUserId
        ? agreement.secondUser
        : agreement.firstUser;

    return {
      ...agreement,
      otherUser,
      currentUserConfirmed:
        agreement.firstUserId === currentUserId
          ? agreement.firstUserConfirmedAt != null
          : agreement.secondUserConfirmedAt != null,
      otherUserConfirmed:
        agreement.firstUserId === currentUserId
          ? agreement.secondUserConfirmedAt != null
          : agreement.firstUserConfirmedAt != null,
    };
  }

  private buildAgreementSummary(
    agreement: AgreementWithRelations,
    currentUserId: string,
  ) {
    const decorated = this.decorateAgreement(agreement, currentUserId);
    return {
      id: decorated.id,
      status: decorated.status,
      createdAt: decorated.createdAt,
      updatedAt: decorated.updatedAt,
      otherUser: decorated.otherUser,
      currentUserConfirmed: decorated.currentUserConfirmed,
      otherUserConfirmed: decorated.otherUserConfirmed,
    };
  }

  private mapAgreementUpdate(dto: UpdateAgreementDto): Prisma.RoommateAgreementUpdateInput {
    const data: Prisma.RoommateAgreementUpdateInput = {};

    if (dto.city !== undefined) data.city = this.normalizeNullableText(dto.city);
    if (dto.address !== undefined) {
      data.address = this.normalizeNullableText(dto.address);
    }
    if (dto.moveInDate !== undefined) {
      data.moveInDate = this.parseDate(
        dto.moveInDate,
        'Дата заселения указана некорректно.',
      );
    }
    if (dto.moveOutDate !== undefined) {
      data.moveOutDate = this.parseDate(
        dto.moveOutDate,
        'Дата выезда указана некорректно.',
      );
    }
    if (dto.monthlyRent !== undefined) data.monthlyRent = dto.monthlyRent;
    if (dto.depositAmount !== undefined) data.depositAmount = dto.depositAmount;
    if (dto.housingFound !== undefined) {
      (data as Prisma.RoommateAgreementUpdateInput & { housingFound?: boolean })
        .housingFound = dto.housingFound;
    }
    if (dto.utilitySplitType !== undefined) {
      data.utilitySplitType = this.normalizeNullableText(dto.utilitySplitType);
    }
    if (dto.firstUserUtilityPercent !== undefined) {
      data.firstUserUtilityPercent = dto.firstUserUtilityPercent;
    }
    if (dto.secondUserUtilityPercent !== undefined) {
      data.secondUserUtilityPercent = dto.secondUserUtilityPercent;
    }
    if (dto.houseRules !== undefined) {
      data.houseRules = this.normalizeNullableText(dto.houseRules);
    }
    if (dto.guestPolicy !== undefined) {
      data.guestPolicy = this.normalizeNullableText(dto.guestPolicy);
    }
    if (dto.quietHours !== undefined) {
      data.quietHours = this.normalizeNullableText(dto.quietHours);
    }
    if (dto.cleaningSchedule !== undefined) {
      data.cleaningSchedule = this.normalizeNullableText(dto.cleaningSchedule);
    }
    if (dto.smokingPolicy !== undefined) {
      data.smokingPolicy = this.normalizeNullableText(dto.smokingPolicy);
    }
    if (dto.petPolicy !== undefined) {
      data.petPolicy = this.normalizeNullableText(dto.petPolicy);
    }
    if (dto.noticePeriodDays !== undefined) {
      data.noticePeriodDays = dto.noticePeriodDays;
    }
    if (dto.damageResponsibility !== undefined) {
      data.damageResponsibility = this.normalizeNullableText(dto.damageResponsibility);
    }
    if (dto.terminationTerms !== undefined) {
      data.terminationTerms = this.normalizeNullableText(dto.terminationTerms);
    }
    if (dto.disputeTerms !== undefined) {
      data.disputeTerms = this.normalizeNullableText(dto.disputeTerms);
    }

    return data;
  }

  private isAgreementReadyForConfirmation(agreement: Partial<RoommateAgreement>) {
    const hasBudget =
      (typeof agreement.monthlyRent === 'number' && agreement.monthlyRent > 0) ||
      (typeof agreement.depositAmount === 'number' && agreement.depositAmount > 0);
    const hasRules = [
      agreement.houseRules,
      agreement.guestPolicy,
      agreement.quietHours,
      agreement.cleaningSchedule,
      agreement.smokingPolicy,
      agreement.petPolicy,
      agreement.damageResponsibility,
      agreement.terminationTerms,
      agreement.utilitySplitType,
      agreement.city,
    ].some((value) => typeof value === 'string' && value.trim().length > 0);

    return Boolean(
        agreement.disputeTerms &&
        (hasBudget || hasRules),
    );
  }

  private parseDate(value: string, message: string) {
    const trimmed = value.trim();
    if (!trimmed) {
      return null;
    }

    const date = new Date(trimmed);
    if (Number.isNaN(date.getTime())) {
      throw new BadRequestException(message);
    }

    return date;
  }

  private normalizeNullableText(value: string) {
    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : null;
  }

  private async ensureAgreementActionAllowed(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        isBanned: true,
        isRestricted: true,
        restrictedUntil: true,
      },
    });

    if (!user) {
      throw new NotFoundException('Пользователь не найден.');
    }

    if (user.isBanned) {
      throw new ForbiddenException('Ваш аккаунт заблокирован.');
    }

    if (
      user.isRestricted &&
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
      return;
    }

    if (user.isRestricted) {
      const daysLeft = this.getRestrictionDaysLeft(user.restrictedUntil);
      throw new ForbiddenException(
        `Ваш аккаунт временно ограничен. Создание договоров недоступно. Доступно будет через ${daysLeft} дн.`,
      );
    }
  }

  private getRestrictionDaysLeft(restrictedUntil: Date | null) {
    if (!restrictedUntil) {
      return 1;
    }

    const diff = restrictedUntil.getTime() - Date.now();
    if (diff <= 0) {
      return 1;
    }

    return Math.max(1, Math.ceil(diff / (24 * 60 * 60 * 1000)));
  }
}
