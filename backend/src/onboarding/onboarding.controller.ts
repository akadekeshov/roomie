import { Controller, Get, Patch, Body } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { OnboardingService } from './onboarding.service';
import { NameAgeDto } from './dto/name-age.dto';
import { GenderDto } from './dto/gender.dto';
import { CityDto } from './dto/city.dto';
import { AboutStepDto } from './dto/about-step.dto';
import { LifestyleStepDto } from './dto/lifestyle-step.dto';
import { SearchStepDto } from './dto/search-step.dto';
import { FinalizeStepDto } from './dto/finalize-step.dto';
import { VerificationDocumentDto } from './dto/verification-document.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('onboarding')
@Controller('onboarding')
@ApiBearerAuth()
export class OnboardingController {
  constructor(private readonly onboardingService: OnboardingService) {}

  @Patch('name-age')
  @ApiOperation({ summary: 'Set name and age (onboarding step 1)' })
  @ApiResponse({
    status: 200,
    description: 'Name and age updated successfully',
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid input or step validation failed',
  })
  async setNameAge(@CurrentUser() user: any, @Body() nameAgeDto: NameAgeDto) {
    return this.onboardingService.setNameAge(user.id, nameAgeDto);
  }

  @Patch('gender')
  @ApiOperation({ summary: 'Set gender (onboarding step 2)' })
  @ApiResponse({ status: 200, description: 'Gender updated successfully' })
  @ApiResponse({
    status: 400,
    description: 'Invalid input or step validation failed',
  })
  async setGender(@CurrentUser() user: any, @Body() genderDto: GenderDto) {
    return this.onboardingService.setGender(user.id, genderDto);
  }

  @Patch('city')
  @ApiOperation({ summary: 'Set city (onboarding step 3)' })
  @ApiResponse({
    status: 200,
    description: 'City updated and onboarding completed',
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid input or step validation failed',
  })
  async setCity(@CurrentUser() user: any, @Body() cityDto: CityDto) {
    return this.onboardingService.setCity(user.id, cityDto);
  }

  @Patch('about')
  @ApiOperation({ summary: 'Set about step (status, university, age, city)' })
  @ApiResponse({ status: 200, description: 'About step updated successfully' })
  async setAbout(@CurrentUser() user: any, @Body() aboutDto: AboutStepDto) {
    return this.onboardingService.setAbout(user.id, aboutDto);
  }

  @Patch('lifestyle')
  @ApiOperation({ summary: 'Set lifestyle step (5 paired preferences)' })
  @ApiResponse({
    status: 200,
    description: 'Lifestyle step updated successfully',
  })
  async setLifestyle(
    @CurrentUser() user: any,
    @Body() lifestyleDto: LifestyleStepDto,
  ) {
    return this.onboardingService.setLifestyle(user.id, lifestyleDto);
  }

  @Patch('search')
  @ApiOperation({ summary: 'Set search preferences step' })
  @ApiResponse({
    status: 200,
    description: 'Search preferences updated successfully',
  })
  async setSearch(@CurrentUser() user: any, @Body() searchDto: SearchStepDto) {
    return this.onboardingService.setSearch(user.id, searchDto);
  }

  @Patch('finalize')
  @ApiOperation({ summary: 'Set finalize step (bio + photos)' })
  @ApiResponse({ status: 200, description: 'Profile finalize step completed' })
  async finalize(
    @CurrentUser() user: any,
    @Body() finalizeDto: FinalizeStepDto,
  ) {
    return this.onboardingService.finalize(user.id, finalizeDto);
  }

  @Patch('verification/document')
  @ApiOperation({ summary: 'Upload verification document URL' })
  @ApiResponse({ status: 200, description: 'Verification document attached' })
  async uploadVerificationDocument(
    @CurrentUser() user: any,
    @Body() dto: VerificationDocumentDto,
  ) {
    return this.onboardingService.uploadVerificationDocument(user.id, dto);
  }

  @Patch('verification/submit')
  @ApiOperation({ summary: 'Submit identity verification request' })
  @ApiResponse({ status: 200, description: 'Verification request submitted' })
  async submitVerification(@CurrentUser() user: any) {
    return this.onboardingService.submitVerification(user.id);
  }

  @Get('status')
  @ApiOperation({ summary: 'Get onboarding status' })
  @ApiResponse({
    status: 200,
    description: 'Onboarding status retrieved successfully',
  })
  async getStatus(@CurrentUser() user: any) {
    return this.onboardingService.getStatus(user.id);
  }
}
