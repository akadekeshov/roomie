import { Injectable } from '@nestjs/common';
import {
  Chronotype,
  Gender,
  NoisePreference,
  PersonalityType,
  PetsPreference,
  SmokingPreference,
} from '@prisma/client';
import { ParsedAiQuery } from './ai.types';

const NON_SMOKER_PATTERNS = [
  /\bnon[\s-]?smok(?:er|ing)\b/u,
  /\bno smoking\b/u,
  /\bdoesn'?t smoke\b/u,
  /не\s*кур/u,
  /некур/u,
  /без\s*кур/u,
];

const SMOKER_PATTERNS = [/\bsmok(?:er|ing)\b/u, /курящ/u, /курит/u];

const NO_PETS_PATTERNS = [
  /\bno pets?\b/u,
  /\bwithout pets?\b/u,
  /без\s*живот/u,
];

const WITH_PETS_PATTERNS = [
  /\bwith pets?\b/u,
  /\bpets? friendly\b/u,
  /с\s*живот/u,
  /любит\s*живот/u,
];

const QUIET_PATTERNS = [
  /\bquiet\b/u,
  /\bcalm\b/u,
  /\bsilent\b/u,
  /тих/u,
  /спокой/u,
];

const SOCIAL_PATTERNS = [
  /\bsocial\b/u,
  /\boutgoing\b/u,
  /\bparty\b/u,
  /общител/u,
  /шумн/u,
];

const LARK_PATTERNS = [
  /\bearly riser\b/u,
  /\bmorning person\b/u,
  /жаворон/u,
  /рано\s*вста/u,
];

const OWL_PATTERNS = [
  /\bnight owl\b/u,
  /\blate sleeper\b/u,
  /сова/u,
  /поздно\s*лож/u,
  /ночн/u,
];

const INTROVERT_PATTERNS = [/\bintrovert\b/u, /интроверт/u];
const EXTROVERT_PATTERNS = [/\bextrovert\b/u, /экстраверт/u];

const FEMALE_PATTERNS = [
  /\bfemale\b/u,
  /\bwoman\b/u,
  /\bgirl\b/u,
  /соседк/u,
  /девушк/u,
  /женщин/u,
];

const MALE_PATTERNS = [
  /\bmale\b/u,
  /\bman\b/u,
  /\bguy\b/u,
  /сосед(?:а)?/u,
  /парн/u,
  /мужчин/u,
];

const CLEAN_LIFESTYLE_PATTERNS = [
  /\bclean\b/u,
  /\borganized\b/u,
  /\btidy\b/u,
  /\bneat\b/u,
  /чистот/u,
  /аккурат/u,
  /порядок/u,
];

@Injectable()
export class AiParserService {
  parse(rawQuery: string): ParsedAiQuery {
    const normalizedQuery = this.normalize(rawQuery);
    const tokens = normalizedQuery.split(' ').filter(Boolean);

    const filters: ParsedAiQuery['filters'] = {};
    const lifestyleSignals = new Set<string>();
    const personalityHints = new Set<string>();

    if (this.hasPattern(normalizedQuery, NON_SMOKER_PATTERNS)) {
      filters.smokingPreference = SmokingPreference.NON_SMOKER;
    } else if (this.hasPattern(normalizedQuery, SMOKER_PATTERNS)) {
      filters.smokingPreference = SmokingPreference.SMOKER;
    }

    if (this.hasPattern(normalizedQuery, NO_PETS_PATTERNS)) {
      filters.petsPreference = PetsPreference.NO_PETS;
    } else if (this.hasPattern(normalizedQuery, WITH_PETS_PATTERNS)) {
      filters.petsPreference = PetsPreference.WITH_PETS;
    }

    if (this.hasPattern(normalizedQuery, QUIET_PATTERNS)) {
      filters.noisePreference = NoisePreference.QUIET;
      lifestyleSignals.add('quiet');
    } else if (this.hasPattern(normalizedQuery, SOCIAL_PATTERNS)) {
      filters.noisePreference = NoisePreference.SOCIAL;
      lifestyleSignals.add('social');
    }

    if (this.hasPattern(normalizedQuery, LARK_PATTERNS)) {
      filters.chronotype = Chronotype.LARK;
      lifestyleSignals.add('morning-routine');
    } else if (this.hasPattern(normalizedQuery, OWL_PATTERNS)) {
      filters.chronotype = Chronotype.OWL;
      lifestyleSignals.add('late-routine');
    }

    if (this.hasPattern(normalizedQuery, INTROVERT_PATTERNS)) {
      filters.personalityType = PersonalityType.INTROVERT;
      personalityHints.add('introvert');
    } else if (this.hasPattern(normalizedQuery, EXTROVERT_PATTERNS)) {
      filters.personalityType = PersonalityType.EXTROVERT;
      personalityHints.add('extrovert');
    }

    if (this.hasPattern(normalizedQuery, FEMALE_PATTERNS)) {
      filters.preferredGender = Gender.FEMALE;
    } else if (this.hasPattern(normalizedQuery, MALE_PATTERNS)) {
      filters.preferredGender = Gender.MALE;
    }

    if (this.hasPattern(normalizedQuery, CLEAN_LIFESTYLE_PATTERNS)) {
      filters.requiresCleanLifestyle = true;
      lifestyleSignals.add('cleanliness');
    }

    return {
      rawQuery,
      normalizedQuery,
      filters,
      lifestyleSignals: Array.from(lifestyleSignals),
      personalityHints: Array.from(personalityHints),
      tokens,
    };
  }

  private normalize(value: string): string {
    return value
      .toLowerCase()
      .replace(/[\s\n\r\t]+/g, ' ')
      .trim();
  }

  private hasPattern(input: string, patterns: RegExp[]): boolean {
    return patterns.some((pattern) => pattern.test(input));
  }
}
