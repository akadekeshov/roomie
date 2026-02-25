CREATE TYPE "OnboardingStep" AS ENUM ('NAME_AGE', 'GENDER', 'CITY', 'DONE');

ALTER TABLE "users" 
  ALTER COLUMN "firstName" DROP NOT NULL,
  ALTER COLUMN "lastName" DROP NOT NULL,
  ADD COLUMN "city" TEXT,
  ADD COLUMN "onboardingCompleted" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN "onboardingStep" "OnboardingStep" NOT NULL DEFAULT 'NAME_AGE';

