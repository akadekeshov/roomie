DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_type
    WHERE typname = 'AiEmbeddingKind'
  ) THEN
    CREATE TYPE "AiEmbeddingKind" AS ENUM (
      'USER_PROFILE',
      'USER_PREFERENCES',
      'SEARCH_QUERY'
    );
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_type
    WHERE typname = 'AiSearchStatus'
  ) THEN
    CREATE TYPE "AiSearchStatus" AS ENUM ('COMPLETED', 'FAILED');
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS "ai_unified_profiles" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "profileText" TEXT NOT NULL,
  "profileJson" JSONB NOT NULL,
  "profileHash" TEXT NOT NULL,
  "completeness" DOUBLE PRECISION NOT NULL,
  "sourceVersion" INTEGER NOT NULL,
  "builtAt" TIMESTAMP(3) NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "ai_unified_profiles_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ai_embeddings" (
  "id" TEXT NOT NULL,
  "kind" "AiEmbeddingKind" NOT NULL,
  "userId" TEXT,
  "aiProfileId" TEXT,
  "queryText" TEXT NOT NULL,
  "queryHash" TEXT NOT NULL,
  "model" TEXT NOT NULL,
  "dimensions" INTEGER NOT NULL,
  "vector" JSONB NOT NULL,
  "generatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "ai_embeddings_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ai_search_sessions" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "query" TEXT NOT NULL,
  "normalizedQuery" TEXT,
  "parsedFilters" JSONB,
  "queryEmbeddingId" TEXT,
  "status" "AiSearchStatus" NOT NULL,
  "errorMessage" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "ai_search_sessions_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "ai_search_results" (
  "id" TEXT NOT NULL,
  "sessionId" TEXT NOT NULL,
  "targetUserId" TEXT NOT NULL,
  "semanticSimilarity" DOUBLE PRECISION NOT NULL,
  "lifestyleMatch" DOUBLE PRECISION NOT NULL,
  "preferenceMatch" DOUBLE PRECISION NOT NULL,
  "behavioralMatch" DOUBLE PRECISION NOT NULL,
  "profileQuality" DOUBLE PRECISION NOT NULL,
  "finalScore" DOUBLE PRECISION NOT NULL,
  "matchedFields" TEXT[],
  "explanation" JSONB,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "ai_search_results_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "ai_unified_profiles_userId_key"
  ON "ai_unified_profiles"("userId");

CREATE INDEX IF NOT EXISTS "ai_unified_profiles_profileHash_idx"
  ON "ai_unified_profiles"("profileHash");

CREATE INDEX IF NOT EXISTS "ai_embeddings_kind_userId_generatedAt_idx"
  ON "ai_embeddings"("kind", "userId", "generatedAt");

CREATE INDEX IF NOT EXISTS "ai_embeddings_aiProfileId_idx"
  ON "ai_embeddings"("aiProfileId");

CREATE INDEX IF NOT EXISTS "ai_embeddings_queryHash_idx"
  ON "ai_embeddings"("queryHash");

CREATE INDEX IF NOT EXISTS "ai_search_sessions_userId_createdAt_idx"
  ON "ai_search_sessions"("userId", "createdAt");

CREATE INDEX IF NOT EXISTS "ai_search_sessions_queryEmbeddingId_idx"
  ON "ai_search_sessions"("queryEmbeddingId");

CREATE INDEX IF NOT EXISTS "ai_search_results_targetUserId_idx"
  ON "ai_search_results"("targetUserId");

CREATE INDEX IF NOT EXISTS "ai_search_results_sessionId_finalScore_idx"
  ON "ai_search_results"("sessionId", "finalScore");

CREATE UNIQUE INDEX IF NOT EXISTS "ai_search_results_sessionId_targetUserId_key"
  ON "ai_search_results"("sessionId", "targetUserId");

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'ai_unified_profiles_userId_fkey'
  ) THEN
    ALTER TABLE "ai_unified_profiles"
    ADD CONSTRAINT "ai_unified_profiles_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "users"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'ai_embeddings_userId_fkey'
  ) THEN
    ALTER TABLE "ai_embeddings"
    ADD CONSTRAINT "ai_embeddings_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "users"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'ai_embeddings_aiProfileId_fkey'
  ) THEN
    ALTER TABLE "ai_embeddings"
    ADD CONSTRAINT "ai_embeddings_aiProfileId_fkey"
    FOREIGN KEY ("aiProfileId") REFERENCES "ai_unified_profiles"("id")
    ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'ai_search_sessions_userId_fkey'
  ) THEN
    ALTER TABLE "ai_search_sessions"
    ADD CONSTRAINT "ai_search_sessions_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "users"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'ai_search_sessions_queryEmbeddingId_fkey'
  ) THEN
    ALTER TABLE "ai_search_sessions"
    ADD CONSTRAINT "ai_search_sessions_queryEmbeddingId_fkey"
    FOREIGN KEY ("queryEmbeddingId") REFERENCES "ai_embeddings"("id")
    ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'ai_search_results_sessionId_fkey'
  ) THEN
    ALTER TABLE "ai_search_results"
    ADD CONSTRAINT "ai_search_results_sessionId_fkey"
    FOREIGN KEY ("sessionId") REFERENCES "ai_search_sessions"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'ai_search_results_targetUserId_fkey'
  ) THEN
    ALTER TABLE "ai_search_results"
    ADD CONSTRAINT "ai_search_results_targetUserId_fkey"
    FOREIGN KEY ("targetUserId") REFERENCES "users"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;
