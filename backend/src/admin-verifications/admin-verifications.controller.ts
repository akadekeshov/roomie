import {
  Controller,
  Get,
  Patch,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
} from '@nestjs/swagger';
import { AdminVerificationsService } from './admin-verifications.service';
import { RejectVerificationDto } from './dto/reject-verification.dto';
import { UpdateUserRoleDto } from './dto/update-user-role.dto';
import { SetUserBanDto } from './dto/set-user-ban.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { UserRole } from '@prisma/client';

@ApiTags('admin-verifications')
@Controller('admin/verifications')
@ApiBearerAuth()
@Roles(UserRole.ADMIN, UserRole.MODERATOR)
export class AdminVerificationsController {
  constructor(
    private readonly adminVerificationsService: AdminVerificationsService,
  ) {}

  @Get('pending')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of pending verification requests' })
  @ApiResponse({
    status: 200,
    description: 'List of pending verifications retrieved successfully',
  })
  @ApiResponse({ status: 403, description: 'Insufficient permissions' })
  async getPendingVerifications() {
    return this.adminVerificationsService.getPendingVerifications();
  }

  @Get('users')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get users list for admin management' })
  @ApiResponse({
    status: 200,
    description: 'Users list retrieved successfully',
  })
  async getUsers(@Query('q') q?: string) {
    return this.adminVerificationsService.getUsers(q);
  }

  @Patch('users/:userId/role')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update user role' })
  @ApiResponse({
    status: 200,
    description: 'User role updated successfully',
  })
  async updateUserRole(
    @Param('userId') userId: string,
    @Body() dto: UpdateUserRoleDto,
    @CurrentUser() admin: any,
  ) {
    return this.adminVerificationsService.updateUserRole(userId, dto, admin.id);
  }

  @Patch('users/:userId/ban')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Set user ban status' })
  @ApiResponse({
    status: 200,
    description: 'User ban status updated successfully',
  })
  async setUserBan(
    @Param('userId') userId: string,
    @Body() dto: SetUserBanDto,
    @CurrentUser() admin: any,
  ) {
    return this.adminVerificationsService.setUserBanStatus(userId, dto, admin.id);
  }

  @Get(':userId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get verification details for a specific user' })
  @ApiParam({
    name: 'userId',
    description: 'User ID',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'Verification details retrieved successfully',
  })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 403, description: 'Insufficient permissions' })
  async getVerificationDetails(@Param('userId') userId: string) {
    return this.adminVerificationsService.getVerificationDetails(userId);
  }

  @Patch(':userId/approve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve user verification' })
  @ApiParam({
    name: 'userId',
    description: 'User ID',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'Verification approved successfully',
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid verification status or missing documents',
  })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 403, description: 'Insufficient permissions' })
  async approveVerification(
    @Param('userId') userId: string,
    @CurrentUser() reviewer: any,
  ) {
    return this.adminVerificationsService.approveVerification(
      userId,
      reviewer.id,
    );
  }

  @Patch(':userId/reject')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reject user verification with reason' })
  @ApiParam({
    name: 'userId',
    description: 'User ID',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'Verification rejected successfully',
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid verification status or invalid reason',
  })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 403, description: 'Insufficient permissions' })
  async rejectVerification(
    @Param('userId') userId: string,
    @CurrentUser() reviewer: any,
    @Body() dto: RejectVerificationDto,
  ) {
    return this.adminVerificationsService.rejectVerification(
      userId,
      reviewer.id,
      dto,
    );
  }
}
