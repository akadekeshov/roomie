
CREATE TYPE "OccupationStatus" AS ENUM ('STUDY', 'WORK', 'STUDY_WORK');
CREATE TYPE "Chronotype" AS ENUM ('OWL', 'LARK');
CREATE TYPE "NoisePreference" AS ENUM ('QUIET', 'SOCIAL');
CREATE TYPE "PersonalityType" AS ENUM ('INTROVERT', 'EXTROVERT');
CREATE TYPE "SmokingPreference" AS ENUM ('SMOKER', 'NON_SMOKER');
CREATE TYPE "PetsPreference" AS ENUM ('WITH_PETS', 'NO_PETS');
CREATE TYPE "RoommateGenderPreference" AS ENUM ('MALE', 'FEMALE', 'ANY');
CREATE TYPE "VerificationStatus" AS ENUM ('NONE', 'PENDING', 'VERIFIED', 'REJECTED');

-- CreateEnum
CREATE TYPE "OccupationStatus" AS ENUM ('STUDY', 'WORK', 'STUDY_WORK');

-- CreateEnum
CREATE TYPE "Chronotype" AS ENUM ('OWL', 'LARK');

-- CreateEnum
CREATE TYPE "NoisePreference" AS ENUM ('QUIET', 'SOCIAL');

-- CreateEnum
CREATE TYPE "PersonalityType" AS ENUM ('INTROVERT', 'EXTROVERT');

-- CreateEnum
CREATE TYPE "SmokingPreference" AS ENUM ('SMOKER', 'NON_SMOKER');

-- CreateEnum
CREATE TYPE "PetsPreference" AS ENUM ('WITH_PETS', 'NO_PETS');

-- CreateEnum
CREATE TYPE "RoommateGenderPreference" AS ENUM ('MALE', 'FEMALE', 'ANY');

-- CreateEnum
CREATE TYPE "VerificationStatus" AS ENUM ('NONE', 'PENDING', 'VERIFIED', 'REJECTED');

-- Alter existing enum OnboardingStep

ALTER TYPE "OnboardingStep" ADD VALUE IF NOT EXISTS 'ABOUT';
ALTER TYPE "OnboardingStep" ADD VALUE IF NOT EXISTS 'LIFESTYLE';
ALTER TYPE "OnboardingStep" ADD VALUE IF NOT EXISTS 'SEARCH';
ALTER TYPE "OnboardingStep" ADD VALUE IF NOT EXISTS 'FINALIZE';


ALTER TABLE "users"
  ADD COLUMN "occupationStatus" "OccupationStatus",
  ADD COLUMN "university" TEXT,
  ADD COLUMN "chronotype" "Chronotype",
  ADD COLUMN "noisePreference" "NoisePreference",
  ADD COLUMN "personalityType" "PersonalityType",
  ADD COLUMN "smokingPreference" "SmokingPreference",
  ADD COLUMN "petsPreference" "PetsPreference",
  ADD COLUMN "searchBudgetMin" INTEGER,
  ADD COLUMN "searchBudgetMax" INTEGER,
  ADD COLUMN "searchDistrict" TEXT,
  ADD COLUMN "roommateGenderPreference" "RoommateGenderPreference",
  ADD COLUMN "stayTerm" TEXT,
  ADD COLUMN "photos" TEXT[] DEFAULT ARRAY[]::TEXT[],
  ADD COLUMN "verificationStatus" "VerificationStatus" NOT NULL DEFAULT 'NONE',
  ADD COLUMN "verificationDocumentUrl" TEXT;

