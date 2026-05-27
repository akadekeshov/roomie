import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsOptional } from 'class-validator';

export class ConfirmAgreementDto {
  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  confirm?: boolean;
}
