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
  @ApiOperation({ summary: 'Discover users with filters' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    example: 10,
    description: 'Items per page (max 50)',
  })
  @ApiQuery({
    name: 'budgetMax',
    required: false,
    type: Number,
    example: 150000,
    description: 'Max budget per month (до X)',
  })
  @ApiQuery({
    name: 'district',
    required: false,
    type: String,
    example: 'Алмалинский р-н',
    description: 'District; use "Все районы" or empty to ignore',
  })
  @ApiQuery({
    name: 'gender',
    required: false,
    enum: ['MALE', 'FEMALE', 'OTHER'],
    example: 'FEMALE',
    description: 'Preferred roommate gender',
  })
  @ApiQuery({
    name: 'ageRange',
    required: false,
    enum: ['18-25', '25+'],
    example: '18-25',
    description: 'Age range filter',
  })
  @ApiResponse({
    status: 200,
    description: 'List of discoverable users with pagination meta',
  })
  async discover(
    @CurrentUser() user: any,
    @Query() query: DiscoverUsersQueryDto,
  ) {
    return this.usersService.discoverUsers(user.id, query);
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
