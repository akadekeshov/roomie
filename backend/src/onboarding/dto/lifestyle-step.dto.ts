import { ApiProperty } from '@nestjs/swagger';
import {
  Chronotype,
  NoisePreference,
  PersonalityType,
  PetsPreference,
  SmokingPreference,
} from '@prisma/client';
import { IsEnum } from 'class-validator';

export class LifestyleStepDto {
  @ApiProperty({ enum: Chronotype, example: 'OWL' })
  @IsEnum(Chronotype)
  chronotype: Chronotype;

  @ApiProperty({ enum: NoisePreference, example: 'QUIET' })
  @IsEnum(NoisePreference)
  noisePreference: NoisePreference;

  @ApiProperty({ enum: PersonalityType, example: 'INTROVERT' })
  @IsEnum(PersonalityType)
  personalityType: PersonalityType;

  @ApiProperty({ enum: SmokingPreference, example: 'NON_SMOKER' })
  @IsEnum(SmokingPreference)
  smokingPreference: SmokingPreference;

  @ApiProperty({ enum: PetsPreference, example: 'NO_PETS' })
  @IsEnum(PetsPreference)
  petsPreference: PetsPreference;
}
