import { Module } from '@nestjs/common';
import { AdminVerificationsService } from './admin-verifications.service';
import { AdminVerificationsController } from './admin-verifications.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [AdminVerificationsController],
  providers: [AdminVerificationsService],
  exports: [AdminVerificationsService],
})
export class AdminVerificationsModule {}