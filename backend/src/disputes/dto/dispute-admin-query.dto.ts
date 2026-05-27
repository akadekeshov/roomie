import { ApiPropertyOptional } from '@nestjs/swagger';
import { DisputeReason, DisputeStatus } from '@prisma/client';
import { IsEnum, IsOptional } from 'class-validator';

export class DisputeAdminQueryDto {
  @ApiPropertyOptional({ enum: DisputeStatus })
  @IsOptional()
  @IsEnum(DisputeStatus)
  status?: DisputeStatus;

  @ApiPropertyOptional({ enum: DisputeReason })
  @IsOptional()
  @IsEnum(DisputeReason)
  reason?: DisputeReason;
}
