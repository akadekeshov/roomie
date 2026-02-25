import { Module } from '@nestjs/common';
import { FavoritesUsersService } from './favorites-users.service';
import { FavoritesUsersController } from './favorites-users.controller';

@Module({
  controllers: [FavoritesUsersController],
  providers: [FavoritesUsersService],
  exports: [FavoritesUsersService],
})
export class FavoritesUsersModule {}

