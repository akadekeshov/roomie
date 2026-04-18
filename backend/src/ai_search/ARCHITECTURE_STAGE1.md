# AI Search Stage 1

## Цель
Подготовить расширяемый backend-контур для AI roommate matching без поломки существующего API и экранов.

## Новый модуль
`src/ai`:
- `ai.module.ts`
- `ai.controller.ts`
- `ai.service.ts`
- `ai-search.service.ts`
- `ai-parser.service.ts`
- `ai-embedding.service.ts`
- `ai-profile-builder.service.ts`
- `ai-scoring.service.ts`
- `dto/ai-search-request.dto.ts`
- `dto/ai-search-response.dto.ts`
- `ai.types.ts`
- `ai.constants.ts`

## Endpoint contract
- `POST /api/ai/search`
- body:
```json
{
  "query": "Найди спокойную некурящую соседку",
  "limit": 20
}
```
- stage 1 response:
```json
{
  "results": [],
  "meta": {
    "status": "stage_1_architecture_ready",
    "limit": 20
  }
}
```

## Stage 2 (implemented)
- `AiProfileBuilderService`:
  - собирает full user profile из `users`
  - нормализует в unified profile document
  - считает completeness
  - сохраняет/обновляет `ai_unified_profiles`
- `AiParserService`:
  - извлекает `smokingPreference`, `preferredGender`, `petsPreference`, `noisePreference`, `chronotype`, `personalityType`
  - поддерживает русские и английские синонимы (`не курит`, `тихий/спокойный`, `любит чистоту`, etc.)
- `AiEmbeddingService`:
  - строит OpenAI embeddings (или deterministic local fallback)
  - сохраняет в `ai_embeddings`
  - создает 3 типа векторов: `USER_PROFILE`, `USER_PREFERENCES`, `SEARCH_QUERY`
- `AiSearchService`:
  - выполняет pipeline: parse query -> build unified profile -> generate/store embeddings -> log `ai_search_sessions`
  - сохраняет `parsedFilters` и `queryEmbeddingId` в сессии

## Stage 3 (implemented)
- `AiScoringService`:
  - `semanticSimilarity` через cosine similarity по embedding векторам
  - `lifestyleMatch` по smoking/pets/noise/chronotype/personality + clean-lifestyle signal
  - `preferenceMatch` по budget overlap, city/district, двусторонней gender compatibility
  - `behavioralMatch` по verification/onboarding/contact verification/activity recency
  - `profileQuality` по completeness + photos + bio quality
- формула:
```text
final_score =
0.5 * semantic_similarity +
0.2 * lifestyle_match +
0.15 * preference_match +
0.1 * behavioral_match +
0.05 * profile_quality
```
- `AiSearchService`:
  - выбирает кандидатов из `users`
  - считает hybrid score + explanation
  - сохраняет top results в `ai_search_results`
  - возвращает breakdown/explanation в response

## Stage 4 (implemented)
- endpoint `POST /api/ai/search` стабилизирован как production-like API контракт:
  - strict validation (`query` trim + non-empty + min/max length)
  - typed response DTO for results/meta
  - swagger error contracts for `400/401/500`
  - safe exception handling:
    - fallback session logging in `ai_search_sessions` even on failures
    - normalized HTTP errors (`503` for upstream embedding provider issues, `500` otherwise)

## Stage 6 (implemented)
- `pgvector` upgrade:
  - migration creates extension `vector`
  - adds `ai_embeddings.vector_v1 vector(1536)`
  - backfills `vector_v1` from JSON vectors when dimensions are 1536
- ANN index:
  - IVFFlat index on `ai_embeddings.vector_v1` with cosine ops
  - selective for `USER_PROFILE` vectors
- runtime vector sync:
  - `AiEmbeddingService` now writes JSON vector and also syncs `vector_v1`
  - if pgvector is unavailable, system falls back to JSON cosine search
- performance changes in ranking:
  - indexed nearest-neighbor preselection via `AiVectorSearchService`
  - batch fetch of candidate embeddings (no per-candidate N+1 reads)
  - limited rebuild for missing vectors only
  - preserved structured scoring/explainability flow from previous stages

## Prisma foundation (добавлено)
- `AiUnifiedProfile`: единая full-profile репрезентация пользователя
- `AiEmbedding`: хранилище векторов (profile/preference/query)
- `AiSearchSession`: лог AI запроса + parsed filters
- `AiSearchResult`: результаты с breakdown/explanation

## Embedding storage variants

### Вариант 1: простой (текущий Stage 1)
- хранение вектора в `JSONB` поле `ai_embeddings.vector`
- совместимо с любым PostgreSQL без расширений
- применяется для небольших объемов и постепенного rollout

### Вариант 2: production-ready (Stage 6)
- `pgvector` + ANN index
- пример SQL:
```sql
CREATE EXTENSION IF NOT EXISTS vector;

ALTER TABLE ai_embeddings
ADD COLUMN vector_v1 vector(1536);

CREATE INDEX ai_embeddings_vector_v1_ivfflat_idx
ON ai_embeddings
USING ivfflat (vector_v1 vector_cosine_ops)
WITH (lists = 100);
```
- поиск:
```sql
SELECT id, user_id
FROM ai_embeddings
WHERE kind = 'USER_PROFILE'
ORDER BY vector_v1 <=> $1
LIMIT 100;
```

## Env variables (foundation)
- `OPENAI_API_KEY`
- `OPENAI_EMBEDDING_MODEL=text-embedding-3-small`
- `OPENAI_TIMEOUT_MS=15000`
- `LOCAL_EMBEDDING_DIMENSIONS=256`
- `AI_SEARCH_DEFAULT_LIMIT=20`
- `AI_SEARCH_MAX_LIMIT=50`
- `AI_VECTOR_SEARCH_ENABLED=true`
- `AI_VECTOR_DIMENSIONS=1536`
