import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ChatService {
  constructor(private readonly prisma: PrismaService) {}

  async getOrCreateDirectConversation(
    currentUserId: string,
    peerUserId: string,
  ) {
    if (currentUserId === peerUserId) {
      throw new BadRequestException('Cannot create chat with yourself');
    }

    const peer = await this.prisma.user.findFirst({
      where: {
        id: peerUserId,
        role: UserRole.USER,
      },
      select: { id: true },
    });

    if (!peer) {
      throw new NotFoundException('User not found');
    }

    const existing = await this.prisma.conversation.findFirst({
      where: {
        AND: [
          {
            participants: {
              every: {
                userId: { in: [currentUserId, peerUserId] },
              },
            },
          },
          {
            participants: {
              some: {
                userId: currentUserId,
              },
            },
          },
          {
            participants: {
              some: {
                userId: peerUserId,
              },
            },
          },
        ],
      },
      select: { id: true },
    });

    if (existing) {
      return { conversationId: existing.id };
    }

    const created = await this.prisma.conversation.create({
      data: {
        participants: {
          create: [{ userId: currentUserId }, { userId: peerUserId }],
        },
      },
      select: { id: true },
    });

    return { conversationId: created.id };
  }

  async listConversations(currentUserId: string) {
    const rows = await this.prisma.conversationParticipant.findMany({
      where: { userId: currentUserId },
      orderBy: { conversation: { updatedAt: 'desc' } },
      include: {
        conversation: {
          include: {
            participants: {
              include: {
                user: {
                  select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                    photos: true,
                  },
                },
              },
            },
            messages: {
              orderBy: { createdAt: 'desc' },
              take: 1,
              select: {
                id: true,
                text: true,
                senderId: true,
                createdAt: true,
              },
            },
          },
        },
      },
    });

    const data = await Promise.all(
      rows.map(async (row) => {
        const peer = row.conversation.participants.find(
          (p) => p.userId !== currentUserId,
        )?.user;

        const peerName =
          [peer?.firstName, peer?.lastName]
            .filter((v) => !!v && v.trim().length > 0)
            .join(' ')
            .trim() || 'User';

        const avatarPath = peer?.photos?.[0] ?? null;
        const lastMessage = row.conversation.messages[0] ?? null;
        const unreadCount = await this.prisma.message.count({
          where: {
            conversationId: row.conversationId,
            senderId: { not: currentUserId },
            createdAt: {
              gt: row.lastReadAt ?? new Date(0),
            },
          },
        });

        return {
          conversationId: row.conversationId,
          peer: {
            id: peer?.id ?? null,
            name: peerName,
            avatarUrl: avatarPath,
          },
          lastMessage: lastMessage
            ? {
                id: lastMessage.id,
                text: lastMessage.text,
                senderId: lastMessage.senderId,
                createdAt: lastMessage.createdAt,
              }
            : null,
          unreadCount,
          updatedAt: row.conversation.updatedAt,
        };
      }),
    );

    return { data };
  }

  async listMessages(
    currentUserId: string,
    conversationId: string,
    before?: string,
    limit = 50,
  ) {
    await this.ensureParticipant(currentUserId, conversationId);

    const safeLimit = Math.min(Math.max(limit, 1), 100);
    const beforeDate = before ? new Date(before) : null;

    const where = beforeDate
      ? { conversationId, createdAt: { lt: beforeDate } }
      : { conversationId };

    const messages = await this.prisma.message.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: safeLimit,
      select: {
        id: true,
        text: true,
        senderId: true,
        createdAt: true,
      },
    });

    await this.prisma.conversationParticipant.updateMany({
      where: { conversationId, userId: currentUserId },
      data: { lastReadAt: new Date() },
    });

    const data = [...messages].reverse();
    const nextBefore =
      messages.length > 0 ? messages[messages.length - 1].createdAt : null;

    return {
      data,
      meta: {
        limit: safeLimit,
        hasMore: messages.length === safeLimit,
        nextBefore,
      },
    };
  }

  async sendMessage(
    currentUserId: string,
    conversationId: string,
    text: string,
  ) {
    await this.ensureParticipant(currentUserId, conversationId);

    const normalizedText = text.trim();
    if (!normalizedText) {
      throw new BadRequestException('Message text is required');
    }

    const message = await this.prisma.message.create({
      data: {
        conversationId,
        senderId: currentUserId,
        text: normalizedText,
      },
      select: {
        id: true,
        text: true,
        senderId: true,
        createdAt: true,
      },
    });

    await this.prisma.$transaction([
      this.prisma.conversation.update({
        where: { id: conversationId },
        data: { updatedAt: new Date() },
      }),
      this.prisma.conversationParticipant.updateMany({
        where: { conversationId, userId: currentUserId },
        data: { lastReadAt: new Date() },
      }),
    ]);

    return message;
  }

  async markRead(currentUserId: string, conversationId: string) {
    await this.ensureParticipant(currentUserId, conversationId);

    await this.prisma.conversationParticipant.updateMany({
      where: { conversationId, userId: currentUserId },
      data: { lastReadAt: new Date() },
    });

    return { success: true };
  }

  private async ensureParticipant(
    currentUserId: string,
    conversationId: string,
  ) {
    const participant = await this.prisma.conversationParticipant.findFirst({
      where: { conversationId, userId: currentUserId },
      select: { id: true },
    });

    if (!participant) {
      throw new ForbiddenException('No access to this conversation');
    }
  }
}
