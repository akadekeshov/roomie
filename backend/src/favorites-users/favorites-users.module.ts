import { Module } from '@nestjs/common';

import { UsersModule } from '../users/users.module';
import { FavoritesUsersService } from './favorites-users.service';
import { FavoritesUsersController } from './favorites-users.controller';

@Module({
  imports: [UsersModule],
  controllers: [FavoritesUsersController],
  providers: [FavoritesUsersService],
  exports: [FavoritesUsersService],
})
export class FavoritesUsersModule {}
