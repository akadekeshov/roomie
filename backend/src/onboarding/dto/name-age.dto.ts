import { IsString, IsInt, Min, Max, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class NameAgeDto {
  @ApiProperty({ example: 'Aruzhan' })
  @IsString()
  @IsNotEmpty()
  firstName: string;

  @ApiProperty({ example: 21, minimum: 16, maximum: 99 })
  @IsInt()
  @Min(16)
  @Max(99)
  age: number;
}
