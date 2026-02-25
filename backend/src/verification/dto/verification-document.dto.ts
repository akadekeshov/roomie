import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class VerificationDocumentDto {
  @ApiProperty({
    example: '/uploads/kyc/documents/passport-1.jpg',
    description: 'Path of the uploaded verification document',
  })
  @IsString()
  @IsNotEmpty()
  documentUrl: string;
}