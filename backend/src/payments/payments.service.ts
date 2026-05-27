import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  AgreementPayment,
  AgreementStatus,
  CardBindingStatus,
  PaymentStatus,
  PaymentType,
  RoommateAgreement,
  UserRole,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { BindMockCardDto } from './dto/bind-mock-card.dto';
import { CreateAgreementPaymentDto } from './dto/create-agreement-payment.dto';

type CurrentUserPayload = {
  id: string;
  role?: UserRole;
};

@Injectable()
export class PaymentsService {
  constructor(private readonly prisma: PrismaService) {}

  async bindMockCard(userId: string, dto: BindMockCardDto) {
    const card = await this.prisma.userPaymentCard.create({
      data: {
        userId,
        provider: 'MOCK',
        maskedPan: `**** **** **** ${dto.cardLast4}`,
        cardBrand: dto.cardBrand?.trim() || 'UNKNOWN',
        status: CardBindingStatus.ACTIVE,
      },
    });

    return {
      ...card,
      message: 'Это тестовая привязка карты. Реальные деньги не списываются.',
    };
  }

  async getMyCards(userId: string) {
    return this.prisma.userPaymentCard.findMany({
      where: {
        userId,
        status: CardBindingStatus.ACTIVE,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async removeCard(cardId: string, userId: string) {
    const card = await this.prisma.userPaymentCard.findUnique({
      where: { id: cardId },
    });

    if (!card) {
      throw new NotFoundException('Карта не найдена.');
    }

    if (card.userId !== userId) {
      throw new ForbiddenException('У вас нет прав для выполнения этого действия.');
    }

    await this.prisma.userPaymentCard.update({
      where: { id: cardId },
      data: { status: CardBindingStatus.REMOVED },
    });

    return { success: true, message: 'Карта удалена.' };
  }

  async createAgreementPayment(
    dto: CreateAgreementPaymentDto,
    currentUser: CurrentUserPayload,
  ) {
    const agreement = await this.ensureAgreementPaymentAccess(
      dto.agreementId,
      currentUser,
    );

    if (agreement.status !== AgreementStatus.ACTIVE) {
      throw new BadRequestException(
        'Создавать платежи можно только для активного договора.',
      );
    }

    const payerId = dto.payerId ?? currentUser.id;
    if (![agreement.firstUserId, agreement.secondUserId].includes(payerId)) {
      throw new BadRequestException('Плательщик должен быть участником договора.');
    }

    return this.prisma.agreementPayment.create({
      data: {
        agreementId: dto.agreementId,
        payerId,
        type: dto.type,
        amount: dto.amount,
        dueDate: this.parseOptionalDate(
          dto.dueDate,
          'Срок оплаты указан некорректно.',
        ),
        description: dto.description?.trim() || null,
      },
    });
  }

  async getAgreementPayments(
    agreementId: string,
    currentUser: CurrentUserPayload,
  ) {
    await this.ensureAgreementPaymentAccess(agreementId, currentUser);

    return this.prisma.agreementPayment.findMany({
      where: { agreementId },
      include: {
        payer: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            photos: true,
          },
        },
      },
      orderBy: [{ dueDate: 'asc' }, { createdAt: 'desc' }],
    });
  }

  async mockPay(paymentId: string, currentUserId: string) {
    const payment = await this.prisma.agreementPayment.findUnique({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new NotFoundException('Платеж не найден.');
    }

    if (payment.payerId !== currentUserId) {
      throw new ForbiddenException('У вас нет прав для выполнения этого действия.');
    }

    if (payment.status !== PaymentStatus.PENDING) {
      throw new BadRequestException('Этот платеж уже обработан.');
    }

    const updated = await this.prisma.agreementPayment.update({
      where: { id: paymentId },
      data: {
        status: PaymentStatus.PAID,
        paidAt: new Date(),
        mockReceiptNo: this.generateMockReceiptNo(payment),
      },
    });

    return {
      ...updated,
      message:
        'Тестовый платеж успешно выполнен. Реальные деньги не списывались.',
    };
  }

  async getMyReminders(userId: string) {
    return this.prisma.agreementPayment.findMany({
      where: {
        payerId: userId,
        status: PaymentStatus.PENDING,
      },
      orderBy: [{ dueDate: 'asc' }, { createdAt: 'desc' }],
    });
  }

  async createInitialAgreementPayments(
    agreement: Pick<
      RoommateAgreement,
      | 'id'
      | 'depositAmount'
      | 'moveInDate'
      | 'firstUserId'
      | 'secondUserId'
      | 'status'
    >,
  ) {
    if (
      agreement.status !== AgreementStatus.ACTIVE ||
      !agreement.depositAmount ||
      agreement.depositAmount <= 0
    ) {
      return [];
    }

    const existingCount = await this.prisma.agreementPayment.count({
      where: {
        agreementId: agreement.id,
        type: PaymentType.DEPOSIT,
      },
    });

    if (existingCount > 0) {
      return this.prisma.agreementPayment.findMany({
        where: {
          agreementId: agreement.id,
          type: PaymentType.DEPOSIT,
        },
        orderBy: { createdAt: 'asc' },
      });
    }

    const firstUserAmount = Math.ceil(agreement.depositAmount / 2);
    const secondUserAmount = agreement.depositAmount - firstUserAmount;
    const dueDate = agreement.moveInDate ?? new Date();

    await this.prisma.agreementPayment.createMany({
      data: [
        {
          agreementId: agreement.id,
          payerId: agreement.firstUserId,
          type: PaymentType.DEPOSIT,
          amount: firstUserAmount,
          dueDate,
          description: 'Депозит по договору',
        },
        {
          agreementId: agreement.id,
          payerId: agreement.secondUserId,
          type: PaymentType.DEPOSIT,
          amount: secondUserAmount,
          dueDate,
          description: 'Депозит по договору',
        },
      ],
    });

    return this.prisma.agreementPayment.findMany({
      where: {
        agreementId: agreement.id,
        type: PaymentType.DEPOSIT,
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  private async ensureAgreementPaymentAccess(
    agreementId: string,
    currentUser: CurrentUserPayload,
  ) {
    const agreement = await this.prisma.roommateAgreement.findUnique({
      where: { id: agreementId },
      select: {
        id: true,
        firstUserId: true,
        secondUserId: true,
        status: true,
      },
    });

    if (!agreement) {
      throw new NotFoundException('Договор не найден.');
    }

    if (
      currentUser.role !== UserRole.ADMIN &&
      currentUser.role !== UserRole.MODERATOR &&
      ![agreement.firstUserId, agreement.secondUserId].includes(currentUser.id)
    ) {
      throw new ForbiddenException('У вас нет прав для выполнения этого действия.');
    }

    return agreement;
  }

  private parseOptionalDate(value?: string, message?: string) {
    if (!value) {
      return null;
    }

    const date = new Date(value);
    if (Number.isNaN(date.getTime())) {
      throw new BadRequestException(message ?? 'Дата указана некорректно.');
    }

    return date;
  }

  private generateMockReceiptNo(payment: AgreementPayment) {
    const suffix = payment.id.replace(/-/g, '').slice(0, 8).toUpperCase();
    return `MOCK-${Date.now()}-${suffix}`;
  }
}
