# Discover Users API (with filters)

## 📋 Endpoint

### `GET /api/users/discover`

Требует JWT (`@CurrentUser()`), возвращает список пользователей с пагинацией и фильтрами.

**Базовые условия:**
- `role = USER`
- `onboardingCompleted = true`
- `verificationStatus = VERIFIED`
- `id != currentUser.id`

**Query параметры:**
- `page?: number` — номер страницы (default: 1, min: 1)
- `limit?: number` — элементов на странице (default: 10, max: 50)
- `budgetMax?: number` — фильтр бюджета «до X тг/мес»
- `district?: string` — район; `"Все районы"` или пусто → фильтр игнорируется
- `gender?: 'MALE' | 'FEMALE' | 'OTHER'` — предпочитаемый пол соседа
- `ageRange?: '18-25' | '25+'` — возрастной диапазон

**Фильтры:**

- **District**
  - Если `district` передан и после `trim()` не пустой и не `"Все районы"`, то:
    - `where.searchDistrict = district`
  - Пользователи с `searchDistrict = null` отфильтровываются, когда фильтр активен.

- **Gender**
  - Если `gender` передан:
    - `where.gender = gender`
  - Пользователи с `gender = null` не попадают в выборку при активном фильтре.

- **Age**
  - `ageRange = '18-25'` → `where.age: { gte: 18, lte: 25 }`
  - `ageRange = '25+'` → `where.age: { gte: 25 }`
  - Пользователи с `age = null` не попадают в выборку при активном фильтре.

- **Budget (до X)**
  - Если `budgetMax` задан:
    - Добавляется:
      ```ts
      AND: [
        {
          OR: [
            { searchBudgetMin: { lte: budgetMax } },
            { searchBudgetMin: null },
          ],
        },
      ]
      ```
  - Таким образом:
    - Если у пользователя **оба** `searchBudgetMin` и `searchBudgetMax` `null` — он **не** отсекается.
    - Пользователи с заданным `searchBudgetMin <= budgetMax` также проходят.

**Рандомизация:**
- После получения страницы (`findMany` + `skip/take`) массив пользователей перемешивается in-memory (Fisher–Yates shuffle).

**Возвращаемая структура:**

```json
{
  "data": [
    {
      "id": "user-id",
      "firstName": "John",
      "lastName": "Doe",
      "age": 25,
      "city": "Almaty",
      "bio": "Easy-going roommate",
      "photos": ["https://..."],
      "gender": "MALE",
      "occupationStatus": "STUDENT",
      "university": "KBTU",
      "chronotype": "EARLY_BIRD",
      "noisePreference": "LOW",
      "personalityType": "EXTROVERT",
      "smokingPreference": "NON_SMOKER",
      "petsPreference": "OK_WITH_PETS",
      "searchDistrict": "Алмалинский р-н",
      "verificationStatus": "VERIFIED",
      "createdAt": "2026-02-23T12:00:00.000Z",
      "compatibility": null,
      "compatibilityReasons": []
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 42,
    "totalPages": 5
  }
}
```

Поля `compatibility` и `compatibilityReasons` зарезервированы под будущее подключение ИИ:
- сейчас всегда `compatibility: null`
- `compatibilityReasons: []`

---

## 🔍 Примеры запросов

### 1. Базовый discover (пагинация)

```bash
curl -X GET "http://localhost:3000/api/users/discover?page=1&limit=10" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### 2. Discover с фильтрами района, пола, возраста и бюджета

```bash
curl -X GET "http://localhost:3000/api/users/discover \
  ?page=1&limit=10 \
  &district=Алмалинский%20р-н \
  &gender=FEMALE \
  &ageRange=18-25 \
  &budgetMax=150000" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### 3. Игнорирование района ("Все районы")

```bash
curl -X GET "http://localhost:3000/api/users/discover?district=Все%20районы" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

---

## 🧪 Тестирование через Swagger

1. Запустить backend: `npm run start:dev`
2. Открыть Swagger: `http://localhost:3000/api`
3. Нажать **Authorize** и вставить `Bearer <ACCESS_TOKEN>`
4. Найти `GET /users/discover`:
   - Указать `page`, `limit`
   - При необходимости задать `budgetMax`, `district`, `gender`, `ageRange`
5. Убедиться, что:
   - фильтры по району, полу и возрасту исключают пользователей с `null` в соответствующих полях
   - фильтр по бюджету не отбрасывает пользователей без указанных бюджетов (оба поля null)
   - ответ содержит `compatibility: null` и `compatibilityReasons: []`

