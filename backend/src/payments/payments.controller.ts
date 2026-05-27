import { Controller, Delete, Get, Param, Post, Body } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { PaymentsService } from './payments.service';
import { BindMockCardDto } from './dto/bind-mock-card.dto';
import { CreateAgreementPaymentDto } from './dto/create-agreement-payment.dto';

@ApiTags('payments')
@ApiBearerAuth()
@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post('cards/bind')
  @ApiOperation({ summary: 'Bind a mock card for MVP demo payments' })
  @ApiResponse({ status: 201, description: 'Mock card bound successfully' })
  bindMockCard(@CurrentUser() user: any, @Body() dto: BindMockCardDto) {
    return this.paymentsService.bindMockCard(user.id, dto);
  }

  @Get('cards/my')
  @ApiOperation({ summary: 'Get current user active cards' })
  getMyCards(@CurrentUser() user: any) {
    return this.paymentsService.getMyCards(user.id);
  }

  @Delete('cards/:id')
  @ApiOperation({ summary: 'Remove current user mock card' })
  removeCard(@CurrentUser() user: any, @Param('id') id: string) {
    return this.paymentsService.removeCard(id, user.id);
  }

  @Post('agreement-payment')
  @ApiOperation({ summary: 'Create agreement payment record' })
  createAgreementPayment(
    @CurrentUser() user: any,
    @Body() dto: CreateAgreementPaymentDto,
  ) {
    return this.paymentsService.createAgreementPayment(dto, user);
  }

  @Get('agreement/:agreementId')
  @ApiOperation({ summary: 'Get agreement payments' })
  getAgreementPayments(
    @CurrentUser() user: any,
    @Param('agreementId') agreementId: string,
  ) {
    return this.paymentsService.getAgreementPayments(agreementId, user);
  }

  @Post(':paymentId/mock-pay')
  @ApiOperation({ summary: 'Run mock payment without charging real money' })
  mockPay(@CurrentUser() user: any, @Param('paymentId') paymentId: string) {
    return this.paymentsService.mockPay(paymentId, user.id);
  }

  @Get('my-reminders')
  @ApiOperation({ summary: 'Get pending payment reminders for current user' })
  getMyReminders(@CurrentUser() user: any) {
    return this.paymentsService.getMyReminders(user.id);
  }
}
