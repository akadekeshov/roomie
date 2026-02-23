import { Controller, Get, Patch, Body, Param, Query } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
  ApiParam,
} from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { UpdatePasswordDto } from './dto/update-password.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { DiscoverUsersQueryDto } from './dto/discover-users-query.dto';

@ApiTags('users', 'user-profile')
@Controller('users')
@ApiBearerAuth()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get(':id/profile')
  @ApiOperation({ summary: 'Get public user profile' })
  @ApiParam({
    name: 'id',
    description: 'User ID',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({ status: 200, description: 'Public profile retrieved' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getProfile(
    @CurrentUser() currentUser: any,
    @Param('id') id: string,
  ) {
    return this.usersService.getPublicProfile(currentUser.id, id);
  }

  @Get('discover')
  @ApiOperation({ summary: 'Discover verified users for home page' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    example: 10,
    description: 'Items per page (max 50)',
  })
  @ApiResponse({
    status: 200,
    description: 'List of discoverable users with pagination meta',
  })
  async discover(
    @CurrentUser() user: any,
    @Query() query: DiscoverUsersQueryDto,
  ) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 10;
    return this.usersService.discoverUsers(user.id, page, limit);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID' })
  @ApiResponse({ status: 200, description: 'User found' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Patch('me')
  @ApiOperation({ summary: 'Update current user' })
  @ApiResponse({ status: 200, description: 'User updated successfully' })
  async updateMe(
    @CurrentUser() user: any,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    return this.usersService.updateMe(user.id, updateUserDto);
  }

  @Patch('me/password')
  @ApiOperation({ summary: 'Update current user password' })
  @ApiResponse({ status: 200, description: 'Password updated successfully' })
  @ApiResponse({ status: 401, description: 'Current password is incorrect' })
  async updatePassword(
    @CurrentUser() user: any,
    @Body() updatePasswordDto: UpdatePasswordDto,
  ) {
    return this.usersService.updatePassword(user.id, updatePasswordDto);
  }
}
