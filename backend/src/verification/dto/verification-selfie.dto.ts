import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsUrl } from 'class-validator';

export class VerificationSelfieDto {
  @ApiProperty({
    example: 'https://cdn.example.com/selfies/selfie-with-doc.jpg',
    description: 'URL of the selfie photo with document in hand',
  })
  @IsString()
  @IsNotEmpty()
  @IsUrl()
  selfieUrl: string;
}
<<<<<<< HEAD

=======
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
