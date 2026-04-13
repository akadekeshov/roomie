import { IsDateString, IsInt, IsOptional, Max, Min } from 'class-validator';

export class ChatMessagesQueryDto {
  @IsOptional()
  @IsDateString()
  before?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}
