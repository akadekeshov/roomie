import { Controller, Get, Patch, Body } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { OnboardingService } from './onboarding.service';
import { NameAgeDto } from './dto/name-age.dto';
import { GenderDto } from './dto/gender.dto';
import { CityDto } from './dto/city.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('onboarding')
@Controller('onboarding')
@ApiBearerAuth()
export class OnboardingController {
  constructor(private readonly onboardingService: OnboardingService) {}

  @Patch('name-age')
  @ApiOperation({ summary: 'Set name and age (onboarding step 1)' })
  @ApiResponse({ status: 200, description: 'Name and age updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input or step validation failed' })
  async setNameAge(@CurrentUser() user: any, @Body() nameAgeDto: NameAgeDto) {
    return this.onboardingService.setNameAge(user.id, nameAgeDto);
  }

  @Patch('gender')
  @ApiOperation({ summary: 'Set gender (onboarding step 2)' })
  @ApiResponse({ status: 200, description: 'Gender updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input or step validation failed' })
  async setGender(@CurrentUser() user: any, @Body() genderDto: GenderDto) {
    return this.onboardingService.setGender(user.id, genderDto);
  }

  @Patch('city')
  @ApiOperation({ summary: 'Set city (onboarding step 3)' })
  @ApiResponse({ status: 200, description: 'City updated and onboarding completed' })
  @ApiResponse({ status: 400, description: 'Invalid input or step validation failed' })
  async setCity(@CurrentUser() user: any, @Body() cityDto: CityDto) {
    return this.onboardingService.setCity(user.id, cityDto);
  }

  @Get('status')
  @ApiOperation({ summary: 'Get onboarding status' })
  @ApiResponse({ status: 200, description: 'Onboarding status retrieved successfully' })
  async getStatus(@CurrentUser() user: any) {
    return this.onboardingService.getStatus(user.id);
  }
}
