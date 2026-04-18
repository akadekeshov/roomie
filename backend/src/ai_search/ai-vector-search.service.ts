import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';

type VectorSearchRow = {
  embeddingId: string;
  userId: string;
  similarity: number;
};

@Injectable()
export class AiVectorSearchService {
  private readonly logger = new Logger(AiVectorSearchService.name);
  private vectorSearchAvailable = true;

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {}

  get vectorDimensions(): number {
    return Number(
      this.configService.get<string>('AI_VECTOR_DIMENSIONS') ?? '1536',
    );
  }

  isEnabled(): boolean {
    const flag = (
      this.configService.get<string>('AI_VECTOR_SEARCH_ENABLED') ?? 'true'
    ).toLowerCase();
    return flag !== '0' && flag !== 'false' && flag !== 'off';
  }

  async syncVectorColumn(
    embeddingId: string,
    vector: number[],
    dimensions: number,
  ): Promise<boolean> {
    if (!this.isEnabled() || !this.vectorSearchAvailable) {
      return false;
    }

    if (dimensions !== this.vectorDimensions || vector.length !== dimensions) {
      return false;
    }

    const literal = this.toVectorLiteral(vector);

    try {
      await this.prisma.$executeRaw`
        UPDATE "ai_embeddings"
        SET "vector_v1" = ${literal}::vector
        WHERE "id" = ${embeddingId}
      `;
      return true;
    } catch (error) {
      this.disableVectorSearch(
        error,
        'Failed to sync vector_v1 column. Falling back to JSON vector search.',
      );
      return false;
    }
  }

  async findNearestProfileEmbeddings(
    queryVector: number[],
    options: {
      limit: number;
      excludeUserId?: string;
    },
  ): Promise<VectorSearchRow[]> {
    if (!this.isEnabled() || !this.vectorSearchAvailable) {
      return [];
    }
    if (queryVector.length !== this.vectorDimensions) {
      return [];
    }

    const safeLimit = Math.min(Math.max(options.limit, 1), 500);
    const literal = this.toVectorLiteral(queryVector);

    try {
      const rows = options.excludeUserId
        ? await this.prisma.$queryRaw<VectorSearchRow[]>`
            SELECT
              e."id" AS "embeddingId",
              e."userId" AS "userId",
              GREATEST(
                0,
                LEAST(1, 1 - (e."vector_v1" <=> ${literal}::vector))
              )::double precision AS "similarity"
            FROM "ai_embeddings" e
            WHERE e."kind" = 'USER_PROFILE'
              AND e."vector_v1" IS NOT NULL
              AND e."userId" IS NOT NULL
              AND e."userId" <> ${options.excludeUserId}
            ORDER BY e."vector_v1" <=> ${literal}::vector
            LIMIT ${safeLimit}
          `
        : await this.prisma.$queryRaw<VectorSearchRow[]>`
            SELECT
              e."id" AS "embeddingId",
              e."userId" AS "userId",
              GREATEST(
                0,
                LEAST(1, 1 - (e."vector_v1" <=> ${literal}::vector))
              )::double precision AS "similarity"
            FROM "ai_embeddings" e
            WHERE e."kind" = 'USER_PROFILE'
              AND e."vector_v1" IS NOT NULL
              AND e."userId" IS NOT NULL
            ORDER BY e."vector_v1" <=> ${literal}::vector
            LIMIT ${safeLimit}
          `;

      const byUser = new Map<string, VectorSearchRow>();
      for (const row of rows) {
        if (!row.userId || byUser.has(row.userId)) {
          continue;
        }
        byUser.set(row.userId, {
          embeddingId: row.embeddingId,
          userId: row.userId,
          similarity: this.clamp01(row.similarity),
        });
      }

      return Array.from(byUser.values());
    } catch (error) {
      this.disableVectorSearch(
        error,
        'Vector search query failed. Switching to JSON cosine fallback.',
      );
      return [];
    }
  }

  private disableVectorSearch(error: unknown, message: string): void {
    if (!this.vectorSearchAvailable) {
      return;
    }
    this.vectorSearchAvailable = false;
    const details = error instanceof Error ? error.message : String(error);
    this.logger.warn(`${message} ${details}`);
  }

  private toVectorLiteral(vector: number[]): string {
    return `[${vector
      .map((value) => {
        const num = Number(value);
        if (!Number.isFinite(num)) {
          return '0';
        }
        return num.toFixed(8);
      })
      .join(',')}]`;
  }

  private clamp01(value: number): number {
    if (!Number.isFinite(value)) {
      return 0;
    }
    if (value < 0) {
      return 0;
    }
    if (value > 1) {
      return 1;
    }
    return Number(value.toFixed(6));
  }
}
