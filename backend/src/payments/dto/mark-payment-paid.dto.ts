import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class MarkPaymentPaidDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  paymentId!: string;
}
