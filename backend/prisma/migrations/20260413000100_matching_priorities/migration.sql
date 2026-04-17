ALTER TABLE "users"
ADD COLUMN "matchingPriorities" JSONB NOT NULL DEFAULT '{"budget":"important","district":"important","noisePreference":"neutral","smokingPreference":"important","petsPreference":"important","chronotype":"neutral","personalityType":"neutral","occupationStatus":"neutral"}';
