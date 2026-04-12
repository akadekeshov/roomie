import { Gender, OnboardingStep, UserRole } from '@prisma/client';

export interface AuthenticatedUser {
  id: string;
  email?: string | null;
  phone?: string | null;
  role: UserRole;
  isBanned?: boolean;
  firstName?: string | null;
  lastName?: string | null;
  gender?: Gender | null;
  age?: number | null;
  city?: string | null;
  bio?: string | null;
  emailVerified?: boolean;
  phoneVerified?: boolean;
  onboardingStep?: OnboardingStep;
  onboardingCompleted?: boolean;
}
