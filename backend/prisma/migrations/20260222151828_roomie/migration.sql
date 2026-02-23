-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('USER', 'MODERATOR', 'ADMIN');

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "role" "UserRole" NOT NULL DEFAULT 'USER',
ADD COLUMN     "verificationRejectReason" TEXT,
ADD COLUMN     "verificationReviewedAt" TIMESTAMP(3),
ADD COLUMN     "verificationReviewedBy" TEXT,
ADD COLUMN     "verificationSelfieUrl" TEXT,
ALTER COLUMN "photos" DROP DEFAULT;
