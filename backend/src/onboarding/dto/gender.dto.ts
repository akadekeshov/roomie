import { IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Gender } from '@prisma/client';

export class GenderDto {
  @ApiProperty({ enum: Gender, example: 'MALE' })
  @IsEnum(Gender)
  gender: Gender;
}
