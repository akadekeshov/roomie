import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class CreateAgreementFromConversationDto {
  @ApiProperty({
    description: 'Conversation identifier used to start the agreement flow',
  })
  @IsString()
  @IsNotEmpty()
  conversationId!: string;
}
