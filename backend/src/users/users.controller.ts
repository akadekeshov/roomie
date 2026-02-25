<<<<<<< HEAD
import {
  BadRequestException,
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Query,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiConsumes,
  ApiOperation,
  ApiQuery,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import * as fs from 'fs';
import type { Express } from 'express';
=======
import { Controller, Get, Patch, Body, Param, Query } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
  ApiParam,
} from '@nestjs/swagger';
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { UpdatePasswordDto } from './dto/update-password.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
<<<<<<< HEAD

const MAX_AVATAR_SIZE = 5 * 1024 * 1024;
const ALLOWED_AVATAR_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp'];

function ensureDirExists(dir: string) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function createAvatarMulterOptions() {
  const uploadPath = join(__dirname, '..', '..', 'uploads', 'avatars');
  ensureDirExists(uploadPath);

  return {
    storage: diskStorage({
      destination: (req, file, cb) => {
        try {
          ensureDirExists(uploadPath);
          cb(null, uploadPath);
        } catch (error) {
          cb(error as Error, uploadPath);
        }
      },
      filename: (req, file, cb) => {
        const timestamp = Date.now();
        const random = Math.round(Math.random() * 1e9);
        const ext = extname(file.originalname || '').toLowerCase();
        const safeExt = ['.jpg', '.jpeg', '.png', '.webp'].includes(ext)
          ? ext
          : '';
        const filename = `${timestamp}-${random}${safeExt}`;
        cb(null, filename);
      },
    }),
    fileFilter: (req: any, file: Express.Multer.File, cb: any) => {
      if (!ALLOWED_AVATAR_MIME_TYPES.includes(file.mimetype)) {
        return cb(
          new BadRequestException(
            'Invalid file type. Only JPEG, PNG, and WEBP images are allowed.',
          ),
          false,
        );
      }
      cb(null, true);
    },
    limits: {
      fileSize: MAX_AVATAR_SIZE,
    },
  };
}

@ApiTags('users')
=======
import { DiscoverUsersQueryDto } from './dto/discover-users-query.dto';

@ApiTags('users', 'user-profile')
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
@Controller('users')
@ApiBearerAuth()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

<<<<<<< HEAD
  @Get('recommendations')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get recommended users for current user' })
=======
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
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
<<<<<<< HEAD
    example: 20,
    description: 'Items per page (max 50)',
  })
  @ApiResponse({
    status: 200,
    description:
      'Recommended users retrieved successfully (onboardingCompleted + verified only, excluding current user)',
  })
  async getRecommendations(
    @CurrentUser() user: any,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const pageNum = Number(page) || 1;
    const limitNum = Number(limit) || 20;
    return this.usersService.getRecommendations(user.id, pageNum, limitNum);
=======
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
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
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
<<<<<<< HEAD

  @Patch('me/avatar/upload')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Upload avatar image for current user' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Avatar uploaded and user profile updated successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid file or user not found' })
  @UseInterceptors(FileInterceptor('file', createAvatarMulterOptions()))
  async uploadAvatar(
    @CurrentUser() user: any,
    @UploadedFile() file: Express.Multer.File,
  ) {
    if (!file) {
      throw new BadRequestException('File is required');
    }
    return this.usersService.updateAvatarFile(user.id, file);
  }
=======
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
}
