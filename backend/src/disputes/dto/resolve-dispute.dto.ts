import { ApiPropertyOptional } from '@nestjs/swagger';
import { DisputeAction, DisputeDecision, DisputeStatus } from '@prisma/client';
import {
  IsEnum,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export const adminDecisionValues = [
  'CONFIRMED',
  'REJECTED',
  'NEEDS_REVIEW',
] as const;

export const adminActionTypeValues = [
  'NONE',
  'WARNING',
  'TEMP_BAN',
  'PERMANENT_BAN',
] as const;

export type AdminDecisionValue = (typeof adminDecisionValues)[number];
export type AdminActionTypeValue = (typeof adminActionTypeValues)[number];

export class ResolveDisputeDto {
  @ApiPropertyOptional({ enum: DisputeDecision })
  @IsOptional()
  @IsEnum(DisputeDecision)
  decision?: DisputeDecision;

  @ApiPropertyOptional({ enum: DisputeStatus })
  @IsOptional()
  @IsEnum(DisputeStatus)
  status?: DisputeStatus;

  @ApiPropertyOptional({
    enum: adminDecisionValues,
    description: 'UI alias for dispute decision',
  })
  @IsOptional()
  @IsIn(adminDecisionValues)
  adminDecision?: AdminDecisionValue;

  @ApiPropertyOptional({ enum: DisputeAction, default: DisputeAction.NONE })
  @IsOptional()
  @IsEnum(DisputeAction)
  action?: DisputeAction;

  @ApiPropertyOptional({
    enum: adminActionTypeValues,
    description: 'UI alias for moderation action type',
  })
  @IsOptional()
  @IsIn(adminActionTypeValues)
  actionType?: AdminActionTypeValue;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  adminComment?: string;

  @ApiPropertyOptional({
    description: 'Restriction period in days',
    default: 7,
  })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(30)
  restrictionDays?: number;
}
