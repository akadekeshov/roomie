import { IsString, IsNumber, IsEnum, IsOptional, IsArray, IsDateString, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { RoomType } from '@prisma/client';

export class UpdateListingDto {
  @ApiPropertyOptional({ example: 'Cozy room in downtown apartment' })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional({ example: 'Beautiful room available for rent...' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: '123 Main St' })
  @IsOptional()
  @IsString()
  address?: string;

  @ApiPropertyOptional({ example: 'New York' })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional({ example: 'NY' })
  @IsOptional()
  @IsString()
  state?: string;

  @ApiPropertyOptional({ example: '10001' })
  @IsOptional()
  @IsString()
  zipCode?: string;

  @ApiPropertyOptional({ example: 'USA' })
  @IsOptional()
  @IsString()
  country?: string;

  @ApiPropertyOptional({ example: 1200.0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  price?: number;

  @ApiPropertyOptional({ enum: RoomType })
  @IsOptional()
  @IsEnum(RoomType)
  roomType?: RoomType;

  @ApiPropertyOptional({ example: '2024-03-01T00:00:00Z' })
  @IsOptional()
  @IsDateString()
  availableFrom?: string;

  @ApiPropertyOptional({ example: '2024-12-31T00:00:00Z' })
  @IsOptional()
  @IsDateString()
  availableTo?: string;

  @ApiPropertyOptional({ example: ['WiFi', 'Parking', 'Gym'], type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  amenities?: string[];

  @ApiPropertyOptional({ example: ['https://example.com/image1.jpg'], type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  images?: string[];
}
