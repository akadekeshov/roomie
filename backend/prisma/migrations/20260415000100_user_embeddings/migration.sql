-- CreateTable
CREATE TABLE IF NOT EXISTS "user_embeddings" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "profileText" TEXT NOT NULL,
    "profileTextHash" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "dimensions" INTEGER NOT NULL,
    "vector" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_embeddings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "ai_recommendation_cache" (
    "id" TEXT NOT NULL,
    "currentUserId" TEXT NOT NULL,
    "candidateUserId" TEXT NOT NULL,
    "ruleScore" DOUBLE PRECISION NOT NULL,
    "embeddingScore" DOUBLE PRECISION,
    "aiScore" DOUBLE PRECISION,
    "finalScore" DOUBLE PRECISION NOT NULL,
    "reasoning" TEXT,
    "strengths" JSONB,
    "risks" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ai_recommendation_cache_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "user_embeddings_userId_key" ON "user_embeddings"("userId");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "ai_recommendation_cache_currentUserId_candidateUserId_key" ON "ai_recommendation_cache"("currentUserId", "candidateUserId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "ai_recommendation_cache_currentUserId_idx" ON "ai_recommendation_cache"("currentUserId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "ai_recommendation_cache_candidateUserId_idx" ON "ai_recommendation_cache"("candidateUserId");

-- AddForeignKey
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'user_embeddings_userId_fkey'
  ) THEN
    ALTER TABLE "user_embeddings"
    ADD CONSTRAINT "user_embeddings_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

-- AddForeignKey
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'ai_recommendation_cache_currentUserId_fkey'
  ) THEN
    ALTER TABLE "ai_recommendation_cache"
    ADD CONSTRAINT "ai_recommendation_cache_currentUserId_fkey"
    FOREIGN KEY ("currentUserId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

-- AddForeignKey
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'ai_recommendation_cache_candidateUserId_fkey'
  ) THEN
    ALTER TABLE "ai_recommendation_cache"
    ADD CONSTRAINT "ai_recommendation_cache_candidateUserId_fkey"
    FOREIGN KEY ("candidateUserId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

-- Cleanup old inline embedding storage on users if present
ALTER TABLE "users" DROP COLUMN IF EXISTS "userEmbedding";
ALTER TABLE "users" DROP COLUMN IF EXISTS "userEmbeddingUpdatedAt";
