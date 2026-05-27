import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class UpdateAgreementDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  address?: string;

  @ApiPropertyOptional({ example: '2026-06-01T00:00:00.000Z' })
  @IsOptional()
  @IsString()
  moveInDate?: string;

  @ApiPropertyOptional({ example: '2027-06-01T00:00:00.000Z' })
  @IsOptional()
  @IsString()
  moveOutDate?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(0)
  monthlyRent?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(0)
  depositAmount?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  housingFound?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  utilitySplitType?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  firstUserUtilityPercent?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  secondUserUtilityPercent?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  houseRules?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  guestPolicy?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  quietHours?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  cleaningSchedule?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  smokingPolicy?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  petPolicy?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(0)
  noticePeriodDays?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  damageResponsibility?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  terminationTerms?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  disputeTerms?: string;
}
