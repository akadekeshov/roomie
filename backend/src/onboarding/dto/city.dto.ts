import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CityDto {
  @ApiProperty({ example: 'Almaty' })
  @IsString()
  @IsNotEmpty()
  city: string;
}
