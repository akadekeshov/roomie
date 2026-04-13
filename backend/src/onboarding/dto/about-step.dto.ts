import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsInt, IsNotEmpty, IsString, Max, Min } from 'class-validator';
import { OccupationStatus } from '@prisma/client';

export class AboutStepDto {
  @ApiProperty({ enum: OccupationStatus, example: 'STUDY' })
  @IsEnum(OccupationStatus)
  occupationStatus: OccupationStatus;

  @ApiProperty({ example: 'University Narxoz' })
  @IsString()
  @IsNotEmpty()
  university: string;

  @ApiProperty({ example: 18, minimum: 16, maximum: 99 })
  @IsInt()
  @Min(16)
  @Max(99)
  age: number;

  @ApiProperty({ example: 'Almaty' })
  @IsString()
  @IsNotEmpty()
  city: string;
}
