-- CreateEnum
CREATE TYPE "AgreementStatus" AS ENUM ('DRAFT', 'WAITING_SECOND_PARTY', 'PENDING_CONFIRMATION', 'ACTIVE', 'CANCELLED', 'COMPLETED', 'REJECTED');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'PAID', 'FAILED', 'CANCELLED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "PaymentType" AS ENUM ('DEPOSIT', 'MONTHLY_RENT', 'UTILITIES', 'OTHER');

-- CreateEnum
CREATE TYPE "CardBindingStatus" AS ENUM ('ACTIVE', 'REMOVED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "DisputeStatus" AS ENUM ('OPEN', 'IN_REVIEW', 'RESOLVED', 'REJECTED', 'CLOSED');

-- CreateEnum
CREATE TYPE "DisputeReason" AS ENUM ('PAYMENT_NOT_PAID', 'AGREEMENT_VIOLATION', 'PROPERTY_DAMAGE', 'FAKE_INFORMATION', 'RUDE_BEHAVIOR', 'SAFETY_CONCERN', 'OTHER');

-- CreateTable
CREATE TABLE "roommate_agreements" (
    "id" TEXT NOT NULL,
    "conversationId" TEXT,
    "creatorId" TEXT NOT NULL,
    "firstUserId" TEXT NOT NULL,
    "secondUserId" TEXT NOT NULL,
    "status" "AgreementStatus" NOT NULL DEFAULT 'DRAFT',
    "city" TEXT,
    "address" TEXT,
    "moveInDate" TIMESTAMP(3),
    "moveOutDate" TIMESTAMP(3),
    "monthlyRent" INTEGER,
    "depositAmount" INTEGER,
    "utilitySplitType" TEXT,
    "firstUserUtilityPercent" INTEGER,
    "secondUserUtilityPercent" INTEGER,
    "houseRules" TEXT,
    "guestPolicy" TEXT,
    "quietHours" TEXT,
    "cleaningSchedule" TEXT,
    "smokingPolicy" TEXT,
    "petPolicy" TEXT,
    "noticePeriodDays" INTEGER DEFAULT 30,
    "damageResponsibility" TEXT,
    "terminationTerms" TEXT,
    "disputeTerms" TEXT,
    "firstUserConfirmedAt" TIMESTAMP(3),
    "secondUserConfirmedAt" TIMESTAMP(3),
    "cancelledAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "pdfUrl" TEXT,
    "digitalSignatureStatus" TEXT,
    "notaryStatus" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "roommate_agreements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_payment_cards" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "provider" TEXT,
    "maskedPan" TEXT NOT NULL,
    "cardBrand" TEXT,
    "status" "CardBindingStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_payment_cards_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "agreement_payments" (
    "id" TEXT NOT NULL,
    "agreementId" TEXT NOT NULL,
    "payerId" TEXT NOT NULL,
    "type" "PaymentType" NOT NULL,
    "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "amount" INTEGER NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'KZT',
    "dueDate" TIMESTAMP(3),
    "paidAt" TIMESTAMP(3),
    "description" TEXT,
    "mockReceiptNo" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "agreement_payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "disputes" (
    "id" TEXT NOT NULL,
    "agreementId" TEXT,
    "conversationId" TEXT,
    "reporterId" TEXT NOT NULL,
    "accusedId" TEXT,
    "reason" "DisputeReason" NOT NULL,
    "status" "DisputeStatus" NOT NULL DEFAULT 'OPEN',
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "evidenceUrls" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "adminComment" TEXT,
    "reviewedById" TEXT,
    "reviewedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "disputes_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "roommate_agreements_conversationId_idx" ON "roommate_agreements"("conversationId");

-- CreateIndex
CREATE INDEX "roommate_agreements_firstUserId_idx" ON "roommate_agreements"("firstUserId");

-- CreateIndex
CREATE INDEX "roommate_agreements_secondUserId_idx" ON "roommate_agreements"("secondUserId");

-- CreateIndex
CREATE INDEX "roommate_agreements_status_idx" ON "roommate_agreements"("status");

-- CreateIndex
CREATE INDEX "user_payment_cards_userId_idx" ON "user_payment_cards"("userId");

-- CreateIndex
CREATE INDEX "agreement_payments_agreementId_idx" ON "agreement_payments"("agreementId");

-- CreateIndex
CREATE INDEX "agreement_payments_payerId_idx" ON "agreement_payments"("payerId");

-- CreateIndex
CREATE INDEX "agreement_payments_status_idx" ON "agreement_payments"("status");

-- CreateIndex
CREATE INDEX "agreement_payments_type_idx" ON "agreement_payments"("type");

-- CreateIndex
CREATE INDEX "disputes_agreementId_idx" ON "disputes"("agreementId");

-- CreateIndex
CREATE INDEX "disputes_conversationId_idx" ON "disputes"("conversationId");

-- CreateIndex
CREATE INDEX "disputes_reporterId_idx" ON "disputes"("reporterId");

-- CreateIndex
CREATE INDEX "disputes_accusedId_idx" ON "disputes"("accusedId");

-- CreateIndex
CREATE INDEX "disputes_status_idx" ON "disputes"("status");

-- AddForeignKey
ALTER TABLE "roommate_agreements" ADD CONSTRAINT "roommate_agreements_conversationId_fkey" FOREIGN KEY ("conversationId") REFERENCES "conversations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "roommate_agreements" ADD CONSTRAINT "roommate_agreements_creatorId_fkey" FOREIGN KEY ("creatorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "roommate_agreements" ADD CONSTRAINT "roommate_agreements_firstUserId_fkey" FOREIGN KEY ("firstUserId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "roommate_agreements" ADD CONSTRAINT "roommate_agreements_secondUserId_fkey" FOREIGN KEY ("secondUserId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_payment_cards" ADD CONSTRAINT "user_payment_cards_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agreement_payments" ADD CONSTRAINT "agreement_payments_agreementId_fkey" FOREIGN KEY ("agreementId") REFERENCES "roommate_agreements"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agreement_payments" ADD CONSTRAINT "agreement_payments_payerId_fkey" FOREIGN KEY ("payerId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "disputes" ADD CONSTRAINT "disputes_agreementId_fkey" FOREIGN KEY ("agreementId") REFERENCES "roommate_agreements"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "disputes" ADD CONSTRAINT "disputes_conversationId_fkey" FOREIGN KEY ("conversationId") REFERENCES "conversations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "disputes" ADD CONSTRAINT "disputes_reporterId_fkey" FOREIGN KEY ("reporterId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "disputes" ADD CONSTRAINT "disputes_accusedId_fkey" FOREIGN KEY ("accusedId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "disputes" ADD CONSTRAINT "disputes_reviewedById_fkey" FOREIGN KEY ("reviewedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
