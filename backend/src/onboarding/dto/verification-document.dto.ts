import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class VerificationDocumentDto {
  @ApiProperty({ example: 'https://cdn.example.com/docs/passport-1.jpg' })
  @IsString()
  @IsNotEmpty()
  documentUrl: string;
}
