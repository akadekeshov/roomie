import {
  Controller,
  Get,
  Patch,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiConsumes,
  ApiBody,
} from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import * as fs from 'fs';
import type { Express } from 'express';

import { VerificationService } from './verification.service';
import { VerificationDocumentDto } from './dto/verification-document.dto';
import { VerificationSelfieDto } from './dto/verification-selfie.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';

const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp'];

function ensureDirExists(dir: string) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function createKycMulterOptions(folder: 'documents' | 'selfies') {
  const uploadPath = join(__dirname, '..', '..', 'uploads', 'kyc', folder);
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
        cb(null, `${timestamp}-${random}${safeExt}`);
      },
    }),
    fileFilter: (req: any, file: Express.Multer.File, cb: any) => {
      if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
        return cb(
          new BadRequestException(
            'Invalid file type. Only JPEG, PNG, and WEBP images are allowed.',
          ),
          false,
        );
      }
      cb(null, true);
    },
    limits: { fileSize: MAX_FILE_SIZE },
  };
}

@ApiTags('verification')
@Controller('verification')
@ApiBearerAuth()
export class VerificationController {
  constructor(private readonly verificationService: VerificationService) {}

  @Patch('document')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Upload verification document URL' })
  @ApiResponse({
    status: 200,
    description: 'Verification document URL saved successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid input or user not found' })
  async uploadDocument(
    @CurrentUser() user: any,
    @Body() dto: VerificationDocumentDto,
  ) {
    return this.verificationService.uploadDocument(user.id, dto);
  }

  @Patch('document/upload')
  @HttpCode(HttpStatus.OK)
  @UseInterceptors(FileInterceptor('file', createKycMulterOptions('documents')))
  @ApiOperation({ summary: 'Upload verification document file' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: { type: 'string', format: 'binary' },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Verification document file saved successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid file or user not found' })
  async uploadDocumentFile(
    @CurrentUser() user: any,
    @UploadedFile() file: Express.Multer.File,
  ) {
    if (!file) throw new BadRequestException('File is required');
    return this.verificationService.uploadDocumentFile(user.id, file);
  }

  @Patch('selfie')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Upload verification selfie URL' })
  @ApiResponse({
    status: 200,
    description: 'Verification selfie URL saved successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid input or user not found' })
  async uploadSelfie(
    @CurrentUser() user: any,
    @Body() dto: VerificationSelfieDto,
  ) {
    return this.verificationService.uploadSelfie(user.id, dto);
  }

  @Patch('selfie/upload')
  @HttpCode(HttpStatus.OK)
  @UseInterceptors(FileInterceptor('file', createKycMulterOptions('selfies')))
  @ApiOperation({ summary: 'Upload verification selfie file' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: { type: 'string', format: 'binary' },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Verification selfie file saved successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid file or user not found' })
  async uploadSelfieFile(
    @CurrentUser() user: any,
    @UploadedFile() file: Express.Multer.File,
  ) {
    if (!file) throw new BadRequestException('File is required');
    return this.verificationService.uploadSelfieFile(user.id, file);
  }

  @Post('submit')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Submit verification request for review' })
  @ApiResponse({
    status: 200,
    description: 'Verification request submitted successfully',
  })
  @ApiResponse({
    status: 400,
    description: 'Missing document or selfie, or user not found',
  })
  @ApiResponse({
    status: 409,
    description: 'Verification already approved',
  })
  async submitVerification(@CurrentUser() user: any) {
    return this.verificationService.submitVerification(user.id);
  }

  @Get('me')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get current user verification status' })
  @ApiResponse({
    status: 200,
    description: 'Verification status retrieved successfully',
  })
  @ApiResponse({ status: 400, description: 'User not found' })
  async getMyVerification(@CurrentUser() user: any) {
    return this.verificationService.getMyVerification(user.id);
  }
}