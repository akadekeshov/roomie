import { ApiProperty } from '@nestjs/swagger';
import { RoommateGenderPreference } from '@prisma/client';
import {
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { MatchingPrioritiesDto } from '../../users/dto/matching-priorities.dto';

export class SearchStepDto {
  @ApiProperty({ example: 100000, minimum: 0 })
  @IsInt()
  @Min(0)
  budgetMin: number;

  @ApiProperty({ example: 250000, minimum: 0 })
  @IsInt()
  @Min(0)
  budgetMax: number;

  @ApiProperty({ example: 'Все районы' })
  @IsString()
  @IsNotEmpty()
  district: string;

  @ApiProperty({ enum: RoommateGenderPreference, example: 'ANY' })
  @IsEnum(RoommateGenderPreference)
  roommateGenderPreference: RoommateGenderPreference;

  @ApiProperty({ example: '1-3 месяца' })
  @IsString()
  @IsNotEmpty()
  stayTerm: string;

  @ApiProperty({
    required: false,
    example: { budget: 'required', district: 'important' },
  })
  @IsOptional()
  @ValidateNested()
  @Type(() => MatchingPrioritiesDto)
  matchingPriorities?: MatchingPrioritiesDto;
}
