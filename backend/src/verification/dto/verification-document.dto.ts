import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsUrl } from 'class-validator';

export class VerificationDocumentDto {
  @ApiProperty({
    example: 'https://cdn.example.com/docs/passport-1.jpg',
    description: 'URL of the verification document photo',
  })
  @IsString()
  @IsNotEmpty()
  @IsUrl()
  documentUrl: string;
}
