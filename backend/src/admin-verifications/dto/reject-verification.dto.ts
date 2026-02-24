import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class RejectVerificationDto {
  @ApiProperty({
    example: 'Document photo is unclear or selfie does not match',
    description: 'Reason for rejecting the verification',
    minLength: 10,
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(10, { message: 'Rejection reason must be at least 10 characters' })
  reason: string;
}
