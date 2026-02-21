import { ApiProperty } from '@nestjs/swagger';
import {
  ArrayMinSize,
  IsArray,
  IsNotEmpty,
  IsString,
  MaxLength,
} from 'class-validator';

export class FinalizeStepDto {
  @ApiProperty({
    example: 'Люблю порядок и спокойную атмосферу. Работаю и учусь.',
    maxLength: 300,
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(300)
  bio: string;

  @ApiProperty({
    type: [String],
    example: ['https://cdn.example.com/photos/user-1.jpg'],
    minItems: 1,
  })
  @IsArray()
  @ArrayMinSize(1)
  @IsString({ each: true })
  photos: string[];
}
