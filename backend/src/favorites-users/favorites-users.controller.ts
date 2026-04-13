import { Controller, Post, Delete, Get, Param, Query } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiQuery,
} from '@nestjs/swagger';
import { FavoritesUsersService } from './favorites-users.service';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { FavoritesUsersQueryDto } from './dto/favorites-users-query.dto';

@ApiTags('favorites-users')
@Controller('favorites/users')
@ApiBearerAuth()
export class FavoritesUsersController {
  constructor(private readonly favoritesUsersService: FavoritesUsersService) {}

  @Post(':targetUserId')
  @ApiOperation({ summary: 'Add user to favorites' })
  @ApiParam({
    name: 'targetUserId',
    description: 'ID of the user to favorite',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({ status: 201, description: 'User added to favorites' })
  @ApiResponse({ status: 400, description: 'Cannot favorite yourself' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async addFavorite(
    @CurrentUser() user: any,
    @Param('targetUserId') targetUserId: string,
  ) {
    return this.favoritesUsersService.addFavorite(user.id, targetUserId);
  }

  @Delete(':targetUserId')
  @ApiOperation({ summary: 'Remove user from favorites' })
  @ApiParam({
    name: 'targetUserId',
    description: 'ID of the user to remove from favorites',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'User removed from favorites (idempotent)',
  })
  async removeFavorite(
    @CurrentUser() user: any,
    @Param('targetUserId') targetUserId: string,
  ) {
    return this.favoritesUsersService.removeFavorite(user.id, targetUserId);
  }

  @Get()
  @ApiOperation({ summary: 'Get favorite users list' })
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
    description: 'Favorite users retrieved successfully',
  })
  async listFavorites(
    @CurrentUser() user: any,
    @Query() query: FavoritesUsersQueryDto,
  ) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 10;
    return this.favoritesUsersService.listFavorites(user.id, page, limit);
  }
}

