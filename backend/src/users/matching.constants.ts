export const MATCHING_CRITERIA = [
  'budget',
  'district',
  'noisePreference',
  'smokingPreference',
  'petsPreference',
  'chronotype',
  'personalityType',
  'occupationStatus',
] as const;

export type MatchingCriterion = (typeof MATCHING_CRITERIA)[number];

export const MATCHING_PRIORITY_LEVELS = ['required', 'important', 'neutral'] as const;
export type MatchingPriorityLevel = (typeof MATCHING_PRIORITY_LEVELS)[number];

export const MATCHING_PRIORITY_WEIGHTS: Record<MatchingPriorityLevel, number> = {
  required: 1.0,
  important: 0.6,
  neutral: 0.2,
};

export const DEFAULT_MATCHING_PRIORITIES: Record<MatchingCriterion, MatchingPriorityLevel> =
  {
    budget: 'important',
    district: 'important',
    noisePreference: 'neutral',
    smokingPreference: 'important',
    petsPreference: 'important',
    chronotype: 'neutral',
    personalityType: 'neutral',
    occupationStatus: 'neutral',
  };
