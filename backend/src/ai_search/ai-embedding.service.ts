import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AiEmbedding, AiEmbeddingKind, Prisma } from '@prisma/client';
import { createHash } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { AiVectorSearchService } from './ai-vector-search.service';

export type AiEmbeddingPayload = {
  model: string;
  dimensions: number;
  vector: number[];
};

type EnsureEmbeddingInput = {
  kind: AiEmbeddingKind;
  text: string;
  userId?: string;
  aiProfileId?: string;
  alwaysCreate?: boolean;
};

@Injectable()
export class AiEmbeddingService {
  private readonly logger = new Logger(AiEmbeddingService.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
    private readonly aiVectorSearchService: AiVectorSearchService,
  ) {}

  async ensureProfileEmbedding(
    userId: string,
    aiProfileId: string,
    profileText: string,
  ): Promise<AiEmbedding> {
    return this.ensureAndStore({
      kind: AiEmbeddingKind.USER_PROFILE,
      text: profileText,
      userId,
      aiProfileId,
      alwaysCreate: false,
    });
  }

  async ensurePreferencesEmbedding(
    userId: string,
    aiProfileId: string,
    preferencesText: string,
  ): Promise<AiEmbedding> {
    return this.ensureAndStore({
      kind: AiEmbeddingKind.USER_PREFERENCES,
      text: preferencesText,
      userId,
      aiProfileId,
      alwaysCreate: false,
    });
  }

  async createQueryEmbedding(
    userId: string,
    queryText: string,
  ): Promise<AiEmbedding> {
    return this.ensureAndStore({
      kind: AiEmbeddingKind.SEARCH_QUERY,
      text: queryText,
      userId,
      alwaysCreate: true,
    });
  }

  async createEmbedding(input: string): Promise<AiEmbeddingPayload> {
    const model =
      this.configService.get<string>('OPENAI_EMBEDDING_MODEL') ??
      'text-embedding-3-small';
    const apiKey = this.configService.get<string>('OPENAI_API_KEY');
    const timeoutMs = Number(
      this.configService.get<string>('OPENAI_TIMEOUT_MS') ?? '15000',
    );

    if (!apiKey) {
      this.logger.warn(
        'OPENAI_API_KEY is missing. AI embedding service will use deterministic local vectors.',
      );
      return this.buildFallbackEmbedding(input, model);
    }

    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);

    try {
      const response = await fetch('https://api.openai.com/v1/embeddings', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model,
          input,
        }),
        signal: controller.signal,
      });

      if (!response.ok) {
        const text = await response.text();
        throw new Error(`OpenAI embeddings failed: ${response.status} ${text}`);
      }

      const payload = (await response.json()) as {
        data?: Array<{ embedding?: number[] }>;
      };
      const vector = payload.data?.[0]?.embedding;
      if (!Array.isArray(vector) || vector.length === 0) {
        throw new Error('OpenAI embedding response did not contain a vector');
      }

      return {
        model,
        dimensions: vector.length,
        vector,
      };
    } finally {
      clearTimeout(timer);
    }
  }

  private async ensureAndStore(
    input: EnsureEmbeddingInput,
  ): Promise<AiEmbedding> {
    const normalizedText = input.text.trim();
    const textHash = this.hashText(normalizedText);

    if (!input.alwaysCreate) {
      const existing = await this.prisma.aiEmbedding.findFirst({
        where: {
          kind: input.kind,
          userId: input.userId,
          aiProfileId: input.aiProfileId,
          queryHash: textHash,
        },
        orderBy: { generatedAt: 'desc' },
      });

      if (existing) {
        return existing;
      }
    }

    const embedding = await this.createEmbedding(normalizedText);

    const created = await this.prisma.aiEmbedding.create({
      data: {
        kind: input.kind,
        userId: input.userId,
        aiProfileId: input.aiProfileId,
        queryText: normalizedText,
        queryHash: textHash,
        model: embedding.model,
        dimensions: embedding.dimensions,
        vector: embedding.vector as Prisma.InputJsonValue,
      },
    });

    await this.aiVectorSearchService.syncVectorColumn(
      created.id,
      embedding.vector,
      embedding.dimensions,
    );

    return created;
  }

  private hashText(text: string): string {
    return createHash('sha256').update(text).digest('hex');
  }

  private buildFallbackEmbedding(
    text: string,
    model: string,
  ): AiEmbeddingPayload {
    const dimensions = Number(
      this.configService.get<string>('LOCAL_EMBEDDING_DIMENSIONS') ?? '256',
    );

    const hash = createHash('sha256').update(text).digest('hex');
    const vector: number[] = [];

    for (let i = 0; i < dimensions; i++) {
      const start = (i * 2) % (hash.length - 2);
      const chunk = hash.substring(start, start + 2);
      const value = parseInt(chunk, 16);
      vector.push((value / 255) * 2 - 1);
    }

    return {
      model: `${model}:fallback-local`,
      dimensions,
      vector,
    };
  }
}
