import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { createHash } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { AI_PROFILE_SOURCE_VERSION } from './ai.constants';
import { UnifiedAiProfile } from './ai.types';

const PROFILE_COMPLETENESS_FIELDS = [
  'firstName',
  'age',
  'gender',
  'city',
  'bio',
  'occupationStatus',
  'chronotype',
  'noisePreference',
  'personalityType',
  'smokingPreference',
  'petsPreference',
  'searchBudgetMin',
  'searchBudgetMax',
  'searchDistrict',
  'roommateGenderPreference',
  'stayTerm',
] as const;

export type AiUserProfileRecord = Prisma.UserGetPayload<{
  select: {
    id: true;
    firstName: true;
    lastName: true;
    gender: true;
    age: true;
    city: true;
    bio: true;
    occupationStatus: true;
    university: true;
    chronotype: true;
    noisePreference: true;
    personalityType: true;
    smokingPreference: true;
    petsPreference: true;
    searchBudgetMin: true;
    searchBudgetMax: true;
    searchDistrict: true;
    roommateGenderPreference: true;
    stayTerm: true;
    onboardingCompleted: true;
    onboardingStep: true;
    verificationStatus: true;
    emailVerified: true;
    phoneVerified: true;
    photos: true;
    createdAt: true;
    updatedAt: true;
  };
}>;

export const AI_PROFILE_USER_SELECT = {
  id: true,
  firstName: true,
  lastName: true,
  gender: true,
  age: true,
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
  onboardingCompleted: true,
  onboardingStep: true,
  verificationStatus: true,
  emailVerified: true,
  phoneVerified: true,
  photos: true,
  createdAt: true,
  updatedAt: true,
} as const satisfies Prisma.UserSelect;

export type BuiltAiProfileContext = {
  user: AiUserProfileRecord;
  unified: UnifiedAiProfile & {
    profileHash: string;
  };
  unifiedProfileId: string;
  preferencesText: string;
};

@Injectable()
export class AiProfileBuilderService {
  constructor(private readonly prisma: PrismaService) {}

  async buildAndPersistForUser(userId: string): Promise<BuiltAiProfileContext> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: AI_PROFILE_USER_SELECT,
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.buildAndPersistFromRecord(user);
  }

  async buildAndPersistFromRecord(
    user: AiUserProfileRecord,
  ): Promise<BuiltAiProfileContext> {
    const unified = this.buildUnifiedProfile(user);
    const profileHash = this.hashText(unified.profileText);
    const preferencesText = this.buildPreferencesText(user);

    const persisted = await this.prisma.aiUnifiedProfile.upsert({
      where: { userId: user.id },
      create: {
        userId: user.id,
        profileText: unified.profileText,
        profileJson: unified.profileJson as Prisma.InputJsonValue,
        profileHash,
        completeness: unified.completeness,
        sourceVersion: unified.sourceVersion,
        builtAt: new Date(),
      },
      update: {
        profileText: unified.profileText,
        profileJson: unified.profileJson as Prisma.InputJsonValue,
        profileHash,
        completeness: unified.completeness,
        sourceVersion: unified.sourceVersion,
        builtAt: new Date(),
      },
      select: { id: true },
    });

    return {
      user,
      unified: {
        ...unified,
        profileHash,
      },
      unifiedProfileId: persisted.id,
      preferencesText,
    };
  }

  buildUnifiedProfile(user: AiUserProfileRecord): UnifiedAiProfile {
    const missingFields = PROFILE_COMPLETENESS_FIELDS.filter((field) =>
      this.isMissing(user[field]),
    );
    const completeness =
      (PROFILE_COMPLETENESS_FIELDS.length - missingFields.length) /
      PROFILE_COMPLETENESS_FIELDS.length;

    const profileJson: Record<string, unknown> = {
      id: user.id,
      fullName:
        `${this.stringOrUnknown(user.firstName)} ${this.stringOrUnknown(user.lastName)}`.trim(),
      demographics: {
        gender: this.stringOrUnknown(user.gender),
        age: user.age ?? 'unknown',
        city: this.stringOrUnknown(user.city),
      },
      bio: this.stringOrUnknown(user.bio),
      lifestyle: {
        occupationStatus: this.stringOrUnknown(user.occupationStatus),
        university: this.stringOrUnknown(user.university),
        chronotype: this.stringOrUnknown(user.chronotype),
        noisePreference: this.stringOrUnknown(user.noisePreference),
        personalityType: this.stringOrUnknown(user.personalityType),
        smokingPreference: this.stringOrUnknown(user.smokingPreference),
        petsPreference: this.stringOrUnknown(user.petsPreference),
      },
      searchPreferences: {
        budgetMin: user.searchBudgetMin ?? 'unknown',
        budgetMax: user.searchBudgetMax ?? 'unknown',
        district: this.stringOrUnknown(user.searchDistrict),
        roommateGenderPreference: this.stringOrUnknown(
          user.roommateGenderPreference,
        ),
        stayTerm: this.stringOrUnknown(user.stayTerm),
      },
      profileSignals: {
        onboardingCompleted: user.onboardingCompleted,
        onboardingStep: user.onboardingStep,
        verificationStatus: user.verificationStatus,
        emailVerified: user.emailVerified,
        phoneVerified: user.phoneVerified,
        photosCount: user.photos.length,
        accountAgeDays: Math.max(
          0,
          Math.floor((Date.now() - user.createdAt.getTime()) / 86_400_000),
        ),
      },
    };

    const profileText = [
      'FULL_PROFILE_DOCUMENT',
      `user_id: ${user.id}`,
      `name: ${this.stringOrUnknown(user.firstName)} ${this.stringOrUnknown(user.lastName)}`.trim(),
      `gender: ${this.stringOrUnknown(user.gender)}`,
      `age: ${user.age ?? 'unknown'}`,
      `city: ${this.stringOrUnknown(user.city)}`,
      `district: ${this.stringOrUnknown(user.searchDistrict)}`,
      `about_me: ${this.stringOrUnknown(user.bio)}`,
      `occupation_status: ${this.stringOrUnknown(user.occupationStatus)}`,
      `university: ${this.stringOrUnknown(user.university)}`,
      `chronotype: ${this.stringOrUnknown(user.chronotype)}`,
      `noise_preference: ${this.stringOrUnknown(user.noisePreference)}`,
      `personality_type: ${this.stringOrUnknown(user.personalityType)}`,
      `smoking_preference: ${this.stringOrUnknown(user.smokingPreference)}`,
      `pets_preference: ${this.stringOrUnknown(user.petsPreference)}`,
      `search_budget_min: ${user.searchBudgetMin ?? 'unknown'}`,
      `search_budget_max: ${user.searchBudgetMax ?? 'unknown'}`,
      `roommate_gender_preference: ${this.stringOrUnknown(
        user.roommateGenderPreference,
      )}`,
      `stay_term: ${this.stringOrUnknown(user.stayTerm)}`,
      `photos_count: ${user.photos.length}`,
      `verification_status: ${this.stringOrUnknown(user.verificationStatus)}`,
      `email_verified: ${user.emailVerified}`,
      `phone_verified: ${user.phoneVerified}`,
      `onboarding_completed: ${user.onboardingCompleted}`,
      `onboarding_step: ${user.onboardingStep}`,
      `profile_completeness: ${(completeness * 100).toFixed(2)}%`,
    ].join('\n');

    return {
      profileText,
      profileJson,
      completeness,
      missingFields: missingFields.map((field) => field.toString()),
      sourceVersion: AI_PROFILE_SOURCE_VERSION,
    };
  }

  buildPreferencesText(user: AiUserProfileRecord): string {
    const min = user.searchBudgetMin ?? 'unknown';
    const max = user.searchBudgetMax ?? 'unknown';

    return [
      'PREFERENCES_DOCUMENT',
      `preferred_city: ${this.stringOrUnknown(user.city)}`,
      `preferred_district: ${this.stringOrUnknown(user.searchDistrict)}`,
      `budget_range: ${min}-${max}`,
      `roommate_gender_preference: ${this.stringOrUnknown(
        user.roommateGenderPreference,
      )}`,
      `stay_term: ${this.stringOrUnknown(user.stayTerm)}`,
      `preferred_noise_level: ${this.stringOrUnknown(user.noisePreference)}`,
      `preferred_smoking: ${this.stringOrUnknown(user.smokingPreference)}`,
      `preferred_pets: ${this.stringOrUnknown(user.petsPreference)}`,
      `chronotype: ${this.stringOrUnknown(user.chronotype)}`,
      `personality: ${this.stringOrUnknown(user.personalityType)}`,
    ].join('\n');
  }

  private hashText(input: string): string {
    return createHash('sha256').update(input).digest('hex');
  }

  private isMissing(value: unknown): boolean {
    if (value === null || value === undefined) {
      return true;
    }
    if (typeof value === 'string') {
      return value.trim().length === 0;
    }
    return false;
  }

  private stringOrUnknown(value: unknown): string {
    if (value === null || value === undefined) {
      return 'unknown';
    }
    const str = String(value).trim();
    if (!str) {
      return 'unknown';
    }
    return str;
  }
}
