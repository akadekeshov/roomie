import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { AiController } from './ai.controller';
import { AiEmbeddingService } from './ai-embedding.service';
import { AiParserService } from './ai-parser.service';
import { AiProfileBuilderService } from './ai-profile-builder.service';
import { AiScoringService } from './ai-scoring.service';
import { AiSearchService } from './ai-search.service';
import { AiService } from './ai.service';
import { AiVectorSearchService } from './ai-vector-search.service';

@Module({
  imports: [PrismaModule],
  controllers: [AiController],
  providers: [
    AiService,
    AiSearchService,
    AiParserService,
    AiEmbeddingService,
    AiVectorSearchService,
    AiProfileBuilderService,
    AiScoringService,
  ],
  exports: [
    AiService,
    AiSearchService,
    AiParserService,
    AiEmbeddingService,
    AiVectorSearchService,
    AiProfileBuilderService,
    AiScoringService,
  ],
})
export class AiSearchModule {}
