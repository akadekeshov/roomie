import { Body, Controller, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiParam, ApiQuery, ApiResponse, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ChatService } from './chat.service';
import { SendMessageDto } from './dto/send-message.dto';
import { ChatMessagesQueryDto } from './dto/chat-messages-query.dto';

@ApiTags('chat')
@Controller('chat')
@ApiBearerAuth()
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get('conversations')
  @ApiOperation({ summary: 'List current user conversations' })
  @ApiResponse({ status: 200, description: 'Conversations list' })
  async listConversations(@CurrentUser() user: any) {
    return this.chatService.listConversations(user.id);
  }

  @Post('direct/:peerUserId')
  @ApiOperation({ summary: 'Create or get direct conversation by user id' })
  @ApiParam({ name: 'peerUserId', description: 'Target user id' })
  @ApiResponse({ status: 201, description: 'Conversation created or found' })
  async getOrCreateDirect(
    @CurrentUser() user: any,
    @Param('peerUserId') peerUserId: string,
  ) {
    return this.chatService.getOrCreateDirectConversation(user.id, peerUserId);
  }

  @Get('conversations/:conversationId/messages')
  @ApiOperation({ summary: 'Get messages for conversation' })
  @ApiParam({ name: 'conversationId', description: 'Conversation id' })
  @ApiQuery({
    name: 'before',
    required: false,
    description: 'ISO datetime cursor for pagination',
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    description: 'Page size 1..100 (default 50)',
  })
  @ApiResponse({ status: 200, description: 'Messages list' })
  async listMessages(
    @CurrentUser() user: any,
    @Param('conversationId') conversationId: string,
    @Query() query: ChatMessagesQueryDto,
  ) {
    return this.chatService.listMessages(
      user.id,
      conversationId,
      query.before,
      query.limit ?? 50,
    );
  }

  @Post('conversations/:conversationId/messages')
  @ApiOperation({ summary: 'Send message to conversation' })
  @ApiParam({ name: 'conversationId', description: 'Conversation id' })
  @ApiResponse({ status: 201, description: 'Message sent' })
  async sendMessage(
    @CurrentUser() user: any,
    @Param('conversationId') conversationId: string,
    @Body() body: SendMessageDto,
  ) {
    return this.chatService.sendMessage(user.id, conversationId, body.text);
  }

  @Patch('conversations/:conversationId/read')
  @ApiOperation({ summary: 'Mark conversation as read for current user' })
  @ApiParam({ name: 'conversationId', description: 'Conversation id' })
  @ApiResponse({ status: 200, description: 'Read marker updated' })
  async markRead(
    @CurrentUser() user: any,
    @Param('conversationId') conversationId: string,
  ) {
    return this.chatService.markRead(user.id, conversationId);
  }
}
