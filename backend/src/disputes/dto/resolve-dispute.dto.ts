import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { DisputeAction, DisputeDecision } from '@prisma/client';
import { IsEnum, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export class ResolveDisputeDto {
  @ApiProperty({ enum: DisputeDecision })
  @IsEnum(DisputeDecision)
  decision!: DisputeDecision;

  @ApiPropertyOptional({ enum: DisputeAction, default: DisputeAction.NONE })
  @IsOptional()
  @IsEnum(DisputeAction)
  action?: DisputeAction;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  adminComment?: string;

  @ApiPropertyOptional({ description: 'Срок ограничения в днях', default: 7 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(365)
  restrictionDays?: number;
}
