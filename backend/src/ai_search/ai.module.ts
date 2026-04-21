import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { UsersModule } from '../users/users.module';
import { AiController } from './ai.controller';
import { AiEmbeddingService } from './ai-embedding.service';
import { AiParserService } from './ai-parser.service';
import { AiProfileBuilderService } from './ai-profile-builder.service';
import { AiSearchService } from './ai-search.service';
import { AiService } from './ai.service';
import { AiVectorSearchService } from './ai-vector-search.service';

@Module({
  imports: [PrismaModule, UsersModule],
  controllers: [AiController],
  providers: [
    AiService,
    AiSearchService,
    AiParserService,
    AiEmbeddingService,
    AiVectorSearchService,
    AiProfileBuilderService,
  ],
  exports: [
    AiService,
    AiSearchService,
    AiParserService,
    AiEmbeddingService,
    AiVectorSearchService,
    AiProfileBuilderService,
  ],
})
export class AiSearchModule {}
