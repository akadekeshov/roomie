import { ApiProperty } from '@nestjs/swagger';
<<<<<<< HEAD
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
=======
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
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
