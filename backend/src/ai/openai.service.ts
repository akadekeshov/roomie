import { Injectable } from '@nestjs/common';
import OpenAI from 'openai';

type RoommateAiResult = {
  compatibilityScore: number;
  reasoning: string;
  strengths: string[];
  risks: string[];
};

@Injectable()
export class OpenAIService {
  private readonly apiKey = process.env.OPENAI_API_KEY ?? '';
  private readonly model =
    process.env.OPENAI_COMPATIBILITY_MODEL ||
    process.env.AI_COMPAT_MODEL ||
    'gpt-4o-mini';
  private readonly embeddingModel =
    process.env.OPENAI_EMBEDDING_MODEL || 'text-embedding-3-small';
  private readonly timeoutMs = Number(
    process.env.AI_COMPAT_TIMEOUT_MS || '5000',
  );
  private readonly embeddingTimeoutMs = Number(
    process.env.OPENAI_EMBEDDING_TIMEOUT_MS || '4000',
  );
  private readonly client = this.apiKey
    ? new OpenAI({
        apiKey: this.apiKey,
      })
    : null;

  private hasRussianContent(value: string | null | undefined): boolean {
    if (!value) return false;
    return /[\u0410-\u042f\u0430-\u044f\u0401\u0451]/.test(value);
  }

  private isRussianAiPayload(result: {
    reasoning: string;
    strengths: string[];
    risks: string[];
  }): boolean {
    return (
      this.hasRussianContent(result.reasoning) &&
      result.strengths.length > 0 &&
      result.strengths.every((value) => this.hasRussianContent(value)) &&
      result.risks.length > 0 &&
      result.risks.every((value) => this.hasRussianContent(value))
    );
  }

  private async withTimeout<T>(
    task: Promise<T>,
    timeoutMs: number,
    errorMessage: string,
  ): Promise<T> {
    let timer: NodeJS.Timeout | null = null;
    try {
      return await Promise.race([
        task,
        new Promise<never>((_, reject) => {
          timer = setTimeout(() => reject(new Error(errorMessage)), timeoutMs);
        }),
      ]);
    } finally {
      if (timer) {
        clearTimeout(timer);
      }
    }
  }

  isEnabled(): boolean {
    const raw = (process.env.AI_COMPAT_ENABLED || 'true').toLowerCase();
    return (
      this.client !== null && raw !== 'false' && raw !== '0' && raw !== 'no'
    );
  }

  async testChat() {
    if (!this.client) {
      throw new Error('OPENAI_API_KEY is not configured');
    }

    const response = await this.client.responses.create({
      model: 'gpt-5.4',
      input: 'Привет, ответь одним словом: работает',
    });

    return response.output_text;
  }

  async createEmbedding(text: string) {
    if (!this.client) {
      throw new Error('OPENAI_API_KEY is not configured');
    }

    const result = await this.withTimeout(
      this.client.embeddings.create({
        model: this.embeddingModel,
        input: text.slice(0, 4000),
      }),
      this.embeddingTimeoutMs,
      'Embedding request timeout',
    );

    return result.data[0].embedding;
  }

  async createEmbeddings(texts: string[]): Promise<number[][]> {
    if (!this.client) {
      throw new Error('OPENAI_API_KEY is not configured');
    }
    if (texts.length === 0) return [];

    const sanitized = texts.map((text) => text.slice(0, 4000));
    const result = await this.withTimeout(
      this.client.embeddings.create({
        model: this.embeddingModel,
        input: sanitized,
      }),
      this.embeddingTimeoutMs,
      'Embedding batch request timeout',
    );

    return result.data
      .sort((a, b) => a.index - b.index)
      .map((item) => item.embedding);
  }

  async evaluateRoommateCompatibility(payload: {
    me: Record<string, unknown>;
    candidate: Record<string, unknown>;
  }): Promise<RoommateAiResult | null> {
    if (!this.isEnabled() || !this.client) return null;

    const systemPrompt = `Ты оцениваешь совместимость соседей по жилью.
Твоя задача — практично оценить, насколько двум пользователям будет комфортно жить вместе.

Учитывай только факторы совместного проживания:
- бюджет
- район и локацию
- отношение к шуму
- отношение к курению
- отношение к животным
- режим сна и хронотип
- формат работы и учебы
- бытовые привычки
- границы и распорядок дня, если они указаны

Жесткие правила:
- Отвечай строго на русском языке.
- Все JSON string fields must be in Russian.
- Не оценивай внешность, мораль, престиж, популярность или социальный статус.
- Не давай советы в стиле знакомств или отношений.
- Не придумывай факты, которых нет в профилях.
- Опирайся только на переданные структурированные поля и текст профиля.
- Будь сдержанным, конкретным и практичным.

Верни только JSON в точном формате:
{
  "compatibility_score": 0,
  "reasoning": "",
  "strengths": [],
  "risks": []
}`;

    const response = await this.withTimeout(
      this.client.responses.create({
        model: this.model,
        input: [
          {
            role: 'system',
            content: systemPrompt,
          },
          {
            role: 'user',
            content: JSON.stringify(payload),
          },
        ],
        max_output_tokens: 300,
        text: {
          format: {
            type: 'json_object',
          },
        },
      }),
      this.timeoutMs,
      'AI compatibility timeout',
    ).catch(() => null);

    if (!response) return null;

    try {
      const parsed = JSON.parse(response.output_text || '{}') as Record<
        string,
        unknown
      >;
      const scoreRaw = Number(parsed.compatibility_score);
      const compatibilityScore = Number.isFinite(scoreRaw)
        ? Math.max(0, Math.min(100, scoreRaw))
        : 0;

      const reasoning =
        typeof parsed.reasoning === 'string' ? parsed.reasoning.trim() : '';
      const strengths = Array.isArray(parsed.strengths)
        ? parsed.strengths
            .filter((value): value is string => typeof value === 'string')
            .map((value) => value.trim())
            .filter(Boolean)
        : [];
      const risks = Array.isArray(parsed.risks)
        ? parsed.risks
            .filter((value): value is string => typeof value === 'string')
            .map((value) => value.trim())
            .filter(Boolean)
        : [];

      const result: RoommateAiResult = {
        compatibilityScore,
        reasoning,
        strengths,
        risks,
      };

      return this.isRussianAiPayload(result) ? result : null;
    } catch {
      return null;
    }
  }
}
