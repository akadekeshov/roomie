<<<<<<< HEAD
=======
-- Create favorite_users table for user-to-user favorites

>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
CREATE TABLE "favorite_users" (
  "id" TEXT NOT NULL,
  "ownerId" TEXT NOT NULL,
  "targetUserId" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "favorite_users_pkey" PRIMARY KEY ("id")
);

<<<<<<< HEAD
=======
-- Owner (who favorites) relation
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
ALTER TABLE "favorite_users"
ADD CONSTRAINT "favorite_users_ownerId_fkey"
FOREIGN KEY ("ownerId") REFERENCES "users"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

<<<<<<< HEAD
=======
-- Target user (who is favorited) relation
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
ALTER TABLE "favorite_users"
ADD CONSTRAINT "favorite_users_targetUserId_fkey"
FOREIGN KEY ("targetUserId") REFERENCES "users"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

<<<<<<< HEAD
=======
-- Ensure one favorite per owner/target pair
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
CREATE UNIQUE INDEX "favorite_users_ownerId_targetUserId_key"
ON "favorite_users"("ownerId", "targetUserId");

