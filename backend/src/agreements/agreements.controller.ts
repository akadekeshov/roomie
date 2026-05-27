import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AgreementsService } from './agreements.service';
import { CreateAgreementFromConversationDto } from './dto/create-agreement-from-conversation.dto';
import { UpdateAgreementDto } from './dto/update-agreement.dto';
import { ConfirmAgreementDto } from './dto/confirm-agreement.dto';
import { SendAgreementForConfirmationDto } from './dto/send-agreement-for-confirmation.dto';
import { RejectAgreementDto } from './dto/reject-agreement.dto';

@ApiTags('agreements')
@ApiBearerAuth()
@Controller('agreements')
export class AgreementsController {
  constructor(private readonly agreementsService: AgreementsService) {}

  @Post('from-conversation')
  @ApiOperation({ summary: 'Create or restore agreement draft from chat conversation' })
  @ApiResponse({ status: 201, description: 'Agreement draft returned successfully' })
  createFromConversation(
    @CurrentUser() user: any,
    @Body() dto: CreateAgreementFromConversationDto,
  ) {
    return this.agreementsService.createFromConversation(dto, user);
  }

  @Get('my')
  @ApiOperation({ summary: 'Get current user agreements' })
  getMy(@CurrentUser() user: any) {
    return this.agreementsService.getMyAgreements(user.id);
  }

  @Get('conversation/:conversationId/status')
  @ApiOperation({ summary: 'Check if agreement can be created from a conversation' })
  getConversationStatus(
    @CurrentUser() user: any,
    @Param('conversationId') conversationId: string,
  ) {
    return this.agreementsService.getConversationStatus(conversationId, user);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get agreement details' })
  getById(@CurrentUser() user: any, @Param('id') id: string) {
    return this.agreementsService.getAgreementById(id, user);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update agreement draft' })
  update(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() dto: UpdateAgreementDto,
  ) {
    return this.agreementsService.updateAgreement(id, dto, user);
  }

  @Post(':id/send-for-confirmation')
  @ApiOperation({ summary: 'Send agreement to the second participant for confirmation' })
  sendForConfirmation(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() _dto: SendAgreementForConfirmationDto,
  ) {
    return this.agreementsService.sendForConfirmation(id, user);
  }

  @Post(':id/confirm')
  @ApiOperation({ summary: 'Confirm agreement by current participant' })
  confirm(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() dto: ConfirmAgreementDto,
    ) {
    return this.agreementsService.confirmAgreement(id, dto, user);
  }

  @Post(':id/reject')
  @ApiOperation({ summary: 'Reject agreement while waiting for confirmation' })
  reject(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() _dto: RejectAgreementDto,
  ) {
    return this.agreementsService.rejectAgreement(id, user);
  }

  @Post(':id/cancel')
  @ApiOperation({ summary: 'Cancel agreement' })
  cancel(@CurrentUser() user: any, @Param('id') id: string) {
    return this.agreementsService.cancelAgreement(id, user);
  }
}
