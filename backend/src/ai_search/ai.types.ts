import {
  Chronotype,
  Gender,
  NoisePreference,
  OccupationStatus,
  PersonalityType,
  PetsPreference,
  RoommateGenderPreference,
  SmokingPreference,
} from '@prisma/client';

export type AiQueryFilters = {
  smokingPreference?: SmokingPreference;
  preferredGender?: Gender;
  petsPreference?: PetsPreference;
  noisePreference?: NoisePreference;
  chronotype?: Chronotype;
  personalityType?: PersonalityType;
  roommateGenderPreference?: RoommateGenderPreference;
  occupationStatus?: OccupationStatus;
  requiresCleanLifestyle?: boolean;
};

export type ParsedAiQuery = {
  rawQuery: string;
  normalizedQuery: string;
  filters: AiQueryFilters;
  lifestyleSignals: string[];
  personalityHints: string[];
  tokens: string[];
};

export type UnifiedAiProfile = {
  profileText: string;
  profileJson: Record<string, unknown>;
  completeness: number;
  missingFields: string[];
  sourceVersion: number;
};

export type AiScoreBreakdown = {
  semanticSimilarity: number;
  lifestyleMatch: number;
  preferenceMatch: number;
  behavioralMatch: number;
  profileQuality: number;
  finalScore: number;
  weights: {
    semantic: number;
    lifestyle: number;
    preference: number;
    behavioral: number;
    profileQuality: number;
  };
};
