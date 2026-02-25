import {
  Controller,
  Get,
  Patch,
  Param,
  Body,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { VerificationService } from '../verification.service';
@ApiTags('admin-verification')
@ApiBearerAuth()
@Controller('admin/verifications')
export class AdminVerificationController {
  constructor(private readonly verificationService: VerificationService) {}

  @Get('pending')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'List pending verifications' })
  async pending() {
    return this.verificationService.adminListPending();
  }

  @Patch(':userId/approve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve verification' })
  async approve(@Param('userId') userId: string) {
    return this.verificationService.adminApprove(userId);
  }

  @Patch(':userId/reject')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reject verification' })
  @ApiResponse({ status: 200, description: 'Rejected' })
  async reject(
    @Param('userId') userId: string,
    @Body() body: { reason?: string },
  ) {
    return this.verificationService.adminReject(userId, body?.reason);
  }
}