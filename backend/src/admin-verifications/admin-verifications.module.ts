import { Module } from '@nestjs/common';
import { AdminVerificationsService } from './admin-verifications.service';
import { AdminVerificationsController } from './admin-verifications.controller';

@Module({
  controllers: [AdminVerificationsController],
  providers: [AdminVerificationsService],
  exports: [AdminVerificationsService],
})
export class AdminVerificationsModule {}
<<<<<<< HEAD

=======
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
