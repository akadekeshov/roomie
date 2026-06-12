ALTER TABLE "users"
  ADD COLUMN IF NOT EXISTS "googleId" TEXT,
  ADD COLUMN IF NOT EXISTS "facebookId" TEXT;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_indexes
    WHERE schemaname = 'public'
      AND indexname = 'users_googleId_key'
  ) THEN
    CREATE UNIQUE INDEX "users_googleId_key"
      ON "users"("googleId");
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_indexes
    WHERE schemaname = 'public'
      AND indexname = 'users_facebookId_key'
  ) THEN
    CREATE UNIQUE INDEX "users_facebookId_key"
      ON "users"("facebookId");
  END IF;
END
$$;
