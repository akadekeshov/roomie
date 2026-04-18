import { Injectable } from '@nestjs/common';
import {
  Gender,
  RoommateGenderPreference,
  VerificationStatus,
} from '@prisma/client';
import { AI_SCORING_WEIGHTS } from './ai.constants';
import { AiUserProfileRecord } from './ai-profile-builder.service';
import { AiQueryFilters, AiScoreBreakdown } from './ai.types';

type ScoreInputs = {
  semanticSimilarity: number;
  lifestyleMatch: number;
  preferenceMatch: number;
  behavioralMatch: number;
  profileQuality: number;
};

export type MatchSignal = {
  score: number;
  matchedFields: string[];
  conflicts: string[];
  notes: string[];
};

@Injectable()
export class AiScoringService {
  calculateBreakdown(input: ScoreInputs): AiScoreBreakdown {
    const semanticSimilarity = this.clamp01(input.semanticSimilarity);
    const lifestyleMatch = this.clamp01(input.lifestyleMatch);
    const preferenceMatch = this.clamp01(input.preferenceMatch);
    const behavioralMatch = this.clamp01(input.behavioralMatch);
    const profileQuality = this.clamp01(input.profileQuality);

    const finalScore =
      AI_SCORING_WEIGHTS.semantic * semanticSimilarity +
      AI_SCORING_WEIGHTS.lifestyle * lifestyleMatch +
      AI_SCORING_WEIGHTS.preference * preferenceMatch +
      AI_SCORING_WEIGHTS.behavioral * behavioralMatch +
      AI_SCORING_WEIGHTS.profileQuality * profileQuality;

    return {
      semanticSimilarity,
      lifestyleMatch,
      preferenceMatch,
      behavioralMatch,
      profileQuality,
      finalScore: this.clamp01(finalScore),
      weights: {
        semantic: AI_SCORING_WEIGHTS.semantic,
        lifestyle: AI_SCORING_WEIGHTS.lifestyle,
        preference: AI_SCORING_WEIGHTS.preference,
        behavioral: AI_SCORING_WEIGHTS.behavioral,
        profileQuality: AI_SCORING_WEIGHTS.profileQuality,
      },
    };
  }

  semanticSimilarity(queryVector: number[], profileVector: number[]): number {
    if (queryVector.length === 0 || profileVector.length === 0) {
      return 0;
    }

    const cosine = this.cosineSimilarity(queryVector, profileVector);
    const normalized = (cosine + 1) / 2;
    return this.clamp01(normalized);
  }

  calculateLifestyleMatch(
    source: AiUserProfileRecord,
    candidate: AiUserProfileRecord,
    queryFilters: AiQueryFilters,
  ): MatchSignal {
    const scores: number[] = [];
    const matchedFields: string[] = [];
    const conflicts: string[] = [];
    const notes: string[] = [];

    this.compareTrait(
      'smokingPreference',
      queryFilters.smokingPreference ?? source.smokingPreference,
      candidate.smokingPreference,
      scores,
      matchedFields,
      conflicts,
    );
    this.compareTrait(
      'petsPreference',
      queryFilters.petsPreference ?? source.petsPreference,
      candidate.petsPreference,
      scores,
      matchedFields,
      conflicts,
    );
    this.compareTrait(
      'noisePreference',
      queryFilters.noisePreference ?? source.noisePreference,
      candidate.noisePreference,
      scores,
      matchedFields,
      conflicts,
    );
    this.compareTrait(
      'chronotype',
      queryFilters.chronotype ?? source.chronotype,
      candidate.chronotype,
      scores,
      matchedFields,
      conflicts,
    );
    this.compareTrait(
      'personalityType',
      queryFilters.personalityType ?? source.personalityType,
      candidate.personalityType,
      scores,
      matchedFields,
      conflicts,
    );

    if (queryFilters.requiresCleanLifestyle) {
      if (
        candidate.noisePreference &&
        candidate.noisePreference === source.noisePreference
      ) {
        scores.push(1);
        matchedFields.push('cleanLifestyleSignal');
      } else {
        scores.push(0.6);
      }
      notes.push('Query contains clean/organized lifestyle signal');
    }

    return {
      score: this.average(scores, 0.5),
      matchedFields: this.unique(matchedFields),
      conflicts: this.unique(conflicts),
      notes,
    };
  }

  calculatePreferenceMatch(
    source: AiUserProfileRecord,
    candidate: AiUserProfileRecord,
    queryFilters: AiQueryFilters,
  ): MatchSignal {
    const scores: number[] = [];
    const matchedFields: string[] = [];
    const conflicts: string[] = [];
    const notes: string[] = [];

    const budgetScore = this.calculateBudgetOverlapScore(source, candidate);
    scores.push(budgetScore);
    if (budgetScore >= 0.65) {
      matchedFields.push('budget');
    } else if (budgetScore <= 0.3) {
      conflicts.push('budget');
    }

    const districtScore = this.calculateDistrictScore(source, candidate);
    scores.push(districtScore);
    if (districtScore >= 0.8) {
      matchedFields.push('district');
    }

    const cityScore = this.calculateCityScore(source, candidate);
    scores.push(cityScore);
    if (cityScore >= 0.8) {
      matchedFields.push('city');
    } else if (cityScore <= 0.2) {
      conflicts.push('city');
    }

    const directGenderFilterScore = this.calculateDirectGenderFilterScore(
      queryFilters.preferredGender,
      candidate.gender,
    );
    scores.push(directGenderFilterScore);
    if (directGenderFilterScore === 1) {
      matchedFields.push('queryPreferredGender');
    } else if (directGenderFilterScore === 0) {
      conflicts.push('queryPreferredGender');
    }

    const sourceToCandidateScore = this.calculateGenderPreferenceFit(
      source.roommateGenderPreference,
      candidate.gender,
    );
    scores.push(sourceToCandidateScore);
    if (sourceToCandidateScore === 1) {
      matchedFields.push('sourceRoommateGenderPreference');
    } else if (sourceToCandidateScore === 0) {
      conflicts.push('sourceRoommateGenderPreference');
    }

    const candidateToSourceScore = this.calculateGenderPreferenceFit(
      candidate.roommateGenderPreference,
      source.gender,
    );
    scores.push(candidateToSourceScore);
    if (candidateToSourceScore === 1) {
      matchedFields.push('candidateRoommateGenderPreference');
    } else if (candidateToSourceScore === 0) {
      conflicts.push('candidateRoommateGenderPreference');
    }

    notes.push(
      'Preference layer includes budget, city/district and two-way gender compatibility.',
    );

    return {
      score: this.average(scores, 0.5),
      matchedFields: this.unique(matchedFields),
      conflicts: this.unique(conflicts),
      notes,
    };
  }

  calculateBehavioralMatch(candidate: AiUserProfileRecord): number {
    const signals: number[] = [];

    const verificationScore =
      candidate.verificationStatus === VerificationStatus.VERIFIED ? 1 : 0.55;
    signals.push(verificationScore);

    const onboardingScore = candidate.onboardingCompleted ? 1 : 0.35;
    signals.push(onboardingScore);

    const contactScore =
      candidate.emailVerified || candidate.phoneVerified ? 1 : 0.5;
    signals.push(contactScore);

    const recencyDays = Math.max(
      0,
      Math.floor((Date.now() - candidate.updatedAt.getTime()) / 86_400_000),
    );
    const recencyScore = recencyDays <= 7 ? 1 : recencyDays <= 30 ? 0.8 : 0.55;
    signals.push(recencyScore);

    return this.average(signals, 0.55);
  }

  calculateProfileQuality(
    completeness: number,
    bio: string | null,
    photos: string[],
  ): number {
    const completenessScore = this.clamp01(completeness);
    const bioScore =
      bio && bio.trim().length >= 100
        ? 1
        : bio && bio.trim().length >= 30
          ? 0.7
          : 0.3;
    const photoScore = photos.length >= 3 ? 1 : photos.length >= 1 ? 0.7 : 0.2;

    return this.clamp01(
      0.7 * completenessScore + 0.2 * photoScore + 0.1 * bioScore,
    );
  }

  private calculateBudgetOverlapScore(
    source: AiUserProfileRecord,
    candidate: AiUserProfileRecord,
  ): number {
    if (
      source.searchBudgetMin == null ||
      source.searchBudgetMax == null ||
      candidate.searchBudgetMin == null ||
      candidate.searchBudgetMax == null
    ) {
      return 0.5;
    }

    const min = Math.max(source.searchBudgetMin, candidate.searchBudgetMin);
    const max = Math.min(source.searchBudgetMax, candidate.searchBudgetMax);
    if (max < min) {
      return 0;
    }

    const sourceRange = Math.max(
      1,
      source.searchBudgetMax - source.searchBudgetMin,
    );
    const candidateRange = Math.max(
      1,
      candidate.searchBudgetMax - candidate.searchBudgetMin,
    );
    const overlapRange = max - min;
    const denominator = Math.max(sourceRange, candidateRange);
    return this.clamp01(overlapRange / denominator);
  }

  private calculateDistrictScore(
    source: AiUserProfileRecord,
    candidate: AiUserProfileRecord,
  ): number {
    if (!source.searchDistrict || !candidate.searchDistrict) {
      return 0.5;
    }
    return this.normalizeText(source.searchDistrict) ===
      this.normalizeText(candidate.searchDistrict)
      ? 1
      : 0.35;
  }

  private calculateCityScore(
    source: AiUserProfileRecord,
    candidate: AiUserProfileRecord,
  ): number {
    if (!source.city || !candidate.city) {
      return 0.5;
    }
    return this.normalizeText(source.city) ===
      this.normalizeText(candidate.city)
      ? 1
      : 0;
  }

  private calculateDirectGenderFilterScore(
    preferredGender: Gender | undefined,
    candidateGender: Gender | null,
  ): number {
    if (!preferredGender) {
      return 0.5;
    }
    if (!candidateGender) {
      return 0.5;
    }
    return preferredGender === candidateGender ? 1 : 0;
  }

  private calculateGenderPreferenceFit(
    preference: RoommateGenderPreference | null,
    targetGender: Gender | null,
  ): number {
    if (!preference || !targetGender) {
      return 0.5;
    }
    if (preference === RoommateGenderPreference.ANY) {
      return 1;
    }
    if (preference === RoommateGenderPreference.FEMALE) {
      return targetGender === Gender.FEMALE ? 1 : 0;
    }
    if (preference === RoommateGenderPreference.MALE) {
      return targetGender === Gender.MALE ? 1 : 0;
    }
    return 0.5;
  }

  private compareTrait(
    key: string,
    expected: string | null | undefined,
    actual: string | null | undefined,
    scores: number[],
    matchedFields: string[],
    conflicts: string[],
  ): void {
    if (!expected || !actual) {
      scores.push(0.5);
      return;
    }
    if (expected === actual) {
      scores.push(1);
      matchedFields.push(key);
      return;
    }
    scores.push(0);
    conflicts.push(key);
  }

  private cosineSimilarity(vectorA: number[], vectorB: number[]): number {
    const length = Math.min(vectorA.length, vectorB.length);
    if (length === 0) {
      return 0;
    }

    let dot = 0;
    let normA = 0;
    let normB = 0;

    for (let i = 0; i < length; i++) {
      const a = vectorA[i] ?? 0;
      const b = vectorB[i] ?? 0;
      dot += a * b;
      normA += a * a;
      normB += b * b;
    }

    const denom = Math.sqrt(normA) * Math.sqrt(normB);
    if (!denom || !Number.isFinite(denom)) {
      return 0;
    }

    return dot / denom;
  }

  private average(values: number[], fallback: number): number {
    if (values.length === 0) {
      return this.clamp01(fallback);
    }
    const sum = values.reduce((acc, value) => acc + value, 0);
    return this.clamp01(sum / values.length);
  }

  private normalizeText(value: string): string {
    return value.trim().toLowerCase();
  }

  private unique(items: string[]): string[] {
    return Array.from(new Set(items));
  }

  private clamp01(value: number): number {
    if (Number.isNaN(value)) {
      return 0;
    }
    if (value < 0) {
      return 0;
    }
    if (value > 1) {
      return 1;
    }
    return Number(value.toFixed(4));
  }
}
