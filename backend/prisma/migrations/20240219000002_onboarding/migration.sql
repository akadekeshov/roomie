<<<<<<< HEAD
CREATE TYPE "OnboardingStep" AS ENUM ('NAME_AGE', 'GENDER', 'CITY', 'DONE');

=======
-- CreateEnum
CREATE TYPE "OnboardingStep" AS ENUM ('NAME_AGE', 'GENDER', 'CITY', 'DONE');

-- AlterTable
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
ALTER TABLE "users" 
  ALTER COLUMN "firstName" DROP NOT NULL,
  ALTER COLUMN "lastName" DROP NOT NULL,
  ADD COLUMN "city" TEXT,
  ADD COLUMN "onboardingCompleted" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN "onboardingStep" "OnboardingStep" NOT NULL DEFAULT 'NAME_AGE';
<<<<<<< HEAD

=======
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
