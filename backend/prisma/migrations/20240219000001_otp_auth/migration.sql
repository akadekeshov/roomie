-- CreateEnum
CREATE TYPE "OTPChannel" AS ENUM ('EMAIL', 'PHONE');

-- CreateEnum
CREATE TYPE "OTPPurpose" AS ENUM ('REGISTER');

-- AlterTable
-- Drop existing unique index
DROP INDEX IF EXISTS "users_email_key";

-- Make email nullable
ALTER TABLE "users" ALTER COLUMN "email" DROP NOT NULL;

-- Add new columns
ALTER TABLE "users" ADD COLUMN "phone" TEXT;
ALTER TABLE "users" ADD COLUMN "emailVerified" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "users" ADD COLUMN "phoneVerified" BOOLEAN NOT NULL DEFAULT false;

-- Create partial unique indexes (NULL values are ignored in unique constraints)
DROP INDEX IF EXISTS "users_phone_key";
CREATE UNIQUE INDEX "users_email_key" ON "users"("email") WHERE "email" IS NOT NULL;
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone") WHERE "phone" IS NOT NULL;

-- CreateTable
CREATE TABLE "otp_codes" (
    "id" TEXT NOT NULL,
    "channel" "OTPChannel" NOT NULL,
    "purpose" "OTPPurpose" NOT NULL,
    "target" TEXT NOT NULL,
    "codeHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "lastSentAt" TIMESTAMP(3) NOT NULL,
    "consumedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "otp_codes_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "otp_codes_channel_purpose_target_key" ON "otp_codes"("channel", "purpose", "target");

-- CreateIndex
CREATE INDEX "otp_codes_channel_purpose_target_idx" ON "otp_codes"("channel", "purpose", "target");
