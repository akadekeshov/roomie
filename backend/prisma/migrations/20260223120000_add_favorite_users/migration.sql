-- Create favorite_users table for user-to-user favorites

CREATE TABLE "favorite_users" (
  "id" TEXT NOT NULL,
  "ownerId" TEXT NOT NULL,
  "targetUserId" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "favorite_users_pkey" PRIMARY KEY ("id")
);

-- Owner (who favorites) relation
ALTER TABLE "favorite_users"
ADD CONSTRAINT "favorite_users_ownerId_fkey"
FOREIGN KEY ("ownerId") REFERENCES "users"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

-- Target user (who is favorited) relation
ALTER TABLE "favorite_users"
ADD CONSTRAINT "favorite_users_targetUserId_fkey"
FOREIGN KEY ("targetUserId") REFERENCES "users"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

-- Ensure one favorite per owner/target pair
CREATE UNIQUE INDEX "favorite_users_ownerId_targetUserId_key"
ON "favorite_users"("ownerId", "targetUserId");

