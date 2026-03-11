import { ApiProperty } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { IsEnum } from 'class-validator';

export class UpdateUserRoleDto {
  @ApiProperty({
    enum: UserRole,
    example: UserRole.MODERATOR,
    description: 'New role for the target user',
  })
  @IsEnum(UserRole)
  role: UserRole;
}
