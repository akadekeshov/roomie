import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean } from 'class-validator';

export class SetUserBanDto {
  @ApiProperty({
    example: true,
    description: 'Ban status. true = banned, false = active',
  })
  @IsBoolean()
  isBanned: boolean;
}
