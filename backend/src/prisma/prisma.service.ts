import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  constructor() {
<<<<<<< HEAD
    super(); 
=======
    super(); // Prisma сам берёт DATABASE_URL из env
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
