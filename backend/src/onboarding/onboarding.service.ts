import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NameAgeDto } from './dto/name-age.dto';
import { GenderDto } from './dto/gender.dto';
import { CityDto } from './dto/city.dto';
import { OnboardingStep } from '@prisma/client';

@Injectable()
export class OnboardingService {
  constructor(private prisma: PrismaService) {}

  async setNameAge(userId: string, nameAgeDto: NameAgeDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { onboardingStep: true },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    // Can update if on NAME_AGE step or already passed it (allows re-editing)

    const updateData: any = {
      firstName: nameAgeDto.firstName,
      age: nameAgeDto.age,
    };

    // Only update onboardingStep if still on NAME_AGE step
    if (user.onboardingStep === OnboardingStep.NAME_AGE) {
      updateData.onboardingStep = OnboardingStep.GENDER;
    }

    const updatedUser = await this.prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        firstName: true,
        age: true,
        onboardingStep: true,
        onboardingCompleted: true,
      },
    });

    return {
      ...updatedUser,
      nextStep: updatedUser.onboardingStep === OnboardingStep.DONE ? null : updatedUser.onboardingStep,
    };
  }

  async setGender(userId: string, genderDto: GenderDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { onboardingStep: true },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    // Can only update if past NAME_AGE step
    if (user.onboardingStep === OnboardingStep.NAME_AGE) {
      throw new BadRequestException('Complete previous step');
    }

    const updateData: any = {
      gender: genderDto.gender,
    };

    // Only update onboardingStep if still on GENDER step
    if (user.onboardingStep === OnboardingStep.GENDER) {
      updateData.onboardingStep = OnboardingStep.CITY;
    }

    const updatedUser = await this.prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        gender: true,
        onboardingStep: true,
        onboardingCompleted: true,
      },
    });

    return {
      ...updatedUser,
      nextStep: updatedUser.onboardingStep === OnboardingStep.DONE ? null : updatedUser.onboardingStep,
    };
  }

  async setCity(userId: string, cityDto: CityDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { onboardingStep: true },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    // Can only update if past GENDER step
    if (user.onboardingStep === OnboardingStep.NAME_AGE || user.onboardingStep === OnboardingStep.GENDER) {
      throw new BadRequestException('Complete previous step');
    }

    const updateData: any = {
      city: cityDto.city,
    };

    // Only update onboardingStep and onboardingCompleted if still on CITY step
    if (user.onboardingStep === OnboardingStep.CITY) {
      updateData.onboardingStep = OnboardingStep.DONE;
      updateData.onboardingCompleted = true;
    }

    const updatedUser = await this.prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        city: true,
        onboardingStep: true,
        onboardingCompleted: true,
      },
    });

    return {
      ...updatedUser,
      nextStep: null,
    };
  }

  async getStatus(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        onboardingStep: true,
        onboardingCompleted: true,
        firstName: true,
        age: true,
        gender: true,
        city: true,
      },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    return {
      onboardingStep: user.onboardingStep,
      onboardingCompleted: user.onboardingCompleted,
      missing: {
        firstName: !user.firstName,
        age: !user.age,
        gender: !user.gender,
        city: !user.city,
      },
    };
  }
}
