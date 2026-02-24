import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { CommonModule } from './common/common.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { ListingsModule } from './listings/listings.module';
import { SavedModule } from './saved/saved.module';
import { OnboardingModule } from './onboarding/onboarding.module';
import { VerificationModule } from './verification/verification.module';
import { AdminVerificationsModule } from './admin-verifications/admin-verifications.module';
import { FavoritesUsersModule } from './favorites-users/favorites-users.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', 'uploads'),
      serveRoot: '/uploads',
    }),
    PrismaModule,
    CommonModule,
    AuthModule,
    UsersModule,
    ListingsModule,
    SavedModule,
    OnboardingModule,
    VerificationModule,
    AdminVerificationsModule,
    FavoritesUsersModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
