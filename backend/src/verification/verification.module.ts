import { Module } from '@nestjs/common';
import { VerificationService } from './verification.service';
import { VerificationController } from './verification.controller';
<<<<<<< HEAD
import { AdminVerificationController } from './dto/admin-verification.controller';

@Module({
  controllers: [VerificationController, AdminVerificationController],
  providers: [VerificationService],
  exports: [VerificationService],
})
export class VerificationModule {}
=======

@Module({
  controllers: [VerificationController],
  providers: [VerificationService],
  exports: [VerificationService],
})
export class VerificationModule {}
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
