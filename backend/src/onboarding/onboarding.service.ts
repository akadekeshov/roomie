import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NameAgeDto } from './dto/name-age.dto';
import { GenderDto } from './dto/gender.dto';
import { CityDto } from './dto/city.dto';
import { OnboardingStep, VerificationStatus } from '@prisma/client';
import { AboutStepDto } from './dto/about-step.dto';
import { LifestyleStepDto } from './dto/lifestyle-step.dto';
import { SearchStepDto } from './dto/search-step.dto';
import { FinalizeStepDto } from './dto/finalize-step.dto';
import { VerificationDocumentDto } from './dto/verification-document.dto';

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
      nextStep:
        updatedUser.onboardingStep === OnboardingStep.DONE
          ? null
          : updatedUser.onboardingStep,
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
      nextStep:
        updatedUser.onboardingStep === OnboardingStep.DONE
          ? null
          : updatedUser.onboardingStep,
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
    if (
      user.onboardingStep === OnboardingStep.NAME_AGE ||
      user.onboardingStep === OnboardingStep.GENDER
    ) {
      throw new BadRequestException('Complete previous step');
    }

    const updateData: any = {
      city: cityDto.city,
    };

    // Finish mandatory registration flow at CITY step.
    // Extended questionnaire is optional and opened from Profile screen.
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
      nextStep:
        updatedUser.onboardingStep === OnboardingStep.DONE
          ? null
          : updatedUser.onboardingStep,
    };
  }

  async setAbout(userId: string, dto: AboutStepDto) {
    const updateData: any = {
      occupationStatus: dto.occupationStatus,
      university: dto.university,
      age: dto.age,
      city: dto.city,
    };

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { onboardingStep: true },
    });

    if (!user) throw new BadRequestException('User not found');

    if (
      user.onboardingStep === OnboardingStep.ABOUT ||
      user.onboardingStep === OnboardingStep.CITY
    ) {
      updateData.onboardingStep = OnboardingStep.LIFESTYLE;
    }

    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        occupationStatus: true,
        university: true,
        age: true,
        city: true,
        onboardingStep: true,
      },
    });

    const nextStep =
      user.onboardingStep === OnboardingStep.DONE
        ? OnboardingStep.LIFESTYLE
        : updated.onboardingStep === OnboardingStep.DONE
          ? null
          : updated.onboardingStep;

    return {
      ...updated,
      nextStep,
    };
  }

  async setLifestyle(userId: string, dto: LifestyleStepDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { onboardingStep: true },
    });

    if (!user) throw new BadRequestException('User not found');

    const updateData: any = {
      chronotype: dto.chronotype,
      noisePreference: dto.noisePreference,
      personalityType: dto.personalityType,
      smokingPreference: dto.smokingPreference,
      petsPreference: dto.petsPreference,
    };

    if (user.onboardingStep === OnboardingStep.LIFESTYLE) {
      updateData.onboardingStep = OnboardingStep.SEARCH;
    }

    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        chronotype: true,
        noisePreference: true,
        personalityType: true,
        smokingPreference: true,
        petsPreference: true,
        onboardingStep: true,
      },
    });

    const nextStep =
      user.onboardingStep === OnboardingStep.DONE
        ? OnboardingStep.SEARCH
        : updated.onboardingStep === OnboardingStep.DONE
          ? null
          : updated.onboardingStep;

    return {
      ...updated,
      nextStep,
    };
  }

  async setSearch(userId: string, dto: SearchStepDto) {
    if (dto.budgetMin > dto.budgetMax) {
      throw new BadRequestException(
        'budgetMin cannot be greater than budgetMax',
      );
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { onboardingStep: true },
    });

    if (!user) throw new BadRequestException('User not found');

    const updateData: any = {
      searchBudgetMin: dto.budgetMin,
      searchBudgetMax: dto.budgetMax,
      searchDistrict: dto.district,
      roommateGenderPreference: dto.roommateGenderPreference,
      stayTerm: dto.stayTerm,
    };

    if (user.onboardingStep === OnboardingStep.SEARCH) {
      updateData.onboardingStep = OnboardingStep.FINALIZE;
    }

    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        searchBudgetMin: true,
        searchBudgetMax: true,
        searchDistrict: true,
        roommateGenderPreference: true,
        stayTerm: true,
        onboardingStep: true,
      },
    });

    const nextStep =
      user.onboardingStep === OnboardingStep.DONE
        ? OnboardingStep.FINALIZE
        : updated.onboardingStep === OnboardingStep.DONE
          ? null
          : updated.onboardingStep;

    return {
      ...updated,
      nextStep,
    };
  }

  async finalize(userId: string, dto: FinalizeStepDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { onboardingStep: true },
    });

    if (!user) throw new BadRequestException('User not found');

    const updateData: any = {
      bio: dto.bio,
      photos: dto.photos,
      onboardingCompleted: true,
      onboardingStep: OnboardingStep.DONE,
    };

    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        bio: true,
        photos: true,
        onboardingStep: true,
        onboardingCompleted: true,
      },
    });

    return { ...updated, nextStep: null };
  }

  async uploadVerificationDocument(
    userId: string,
    dto: VerificationDocumentDto,
  ) {
    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: {
        verificationDocumentUrl: dto.documentUrl,
      },
      select: {
        id: true,
        verificationDocumentUrl: true,
        verificationStatus: true,
      },
    });

    return updated;
  }

  async submitVerification(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { verificationDocumentUrl: true },
    });

    if (!user) throw new BadRequestException('User not found');
    if (!user.verificationDocumentUrl) {
      throw new BadRequestException('Upload document first');
    }

    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: { verificationStatus: VerificationStatus.PENDING },
      select: {
        id: true,
        verificationStatus: true,
      },
    });

    return updated;
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
        bio: true,
        occupationStatus: true,
        university: true,
        chronotype: true,
        noisePreference: true,
        personalityType: true,
        smokingPreference: true,
        petsPreference: true,
        searchBudgetMin: true,
        searchBudgetMax: true,
        searchDistrict: true,
        roommateGenderPreference: true,
        stayTerm: true,
        photos: true,
        verificationStatus: true,
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
        occupationStatus: !user.occupationStatus,
        university: !user.university,
        lifestyle:
          !user.chronotype ||
          !user.noisePreference ||
          !user.personalityType ||
          !user.smokingPreference ||
          !user.petsPreference,
        search:
          user.searchBudgetMin == null ||
          user.searchBudgetMax == null ||
          !user.searchDistrict ||
          !user.roommateGenderPreference ||
          !user.stayTerm,
        photos: (user.photos?.length ?? 0) < 1,
      },
      profile: {
        age: user.age,
        city: user.city,
        bio: user.bio,
        occupationStatus: user.occupationStatus,
        university: user.university,
        lifestyle: {
          chronotype: user.chronotype,
          noisePreference: user.noisePreference,
          personalityType: user.personalityType,
          smokingPreference: user.smokingPreference,
          petsPreference: user.petsPreference,
        },
        search: {
          budgetMin: user.searchBudgetMin,
          budgetMax: user.searchBudgetMax,
          district: user.searchDistrict,
          roommateGenderPreference: user.roommateGenderPreference,
          stayTerm: user.stayTerm,
        },
        photos: user.photos,
        verificationStatus: user.verificationStatus,
      },
    };
  }
}
