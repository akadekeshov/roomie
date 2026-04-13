# Favorites Users & Public Profile API

## 📋 Новые и изменённые файлы

### Prisma
- `prisma/schema.prisma` — добавлена модель `FavoriteUser` и связи в `User`
- `prisma/migrations/20260223120000_add_favorite_users/migration.sql` — миграция для таблицы `favorite_users`

### Backend (NestJS)
- `src/app.module.ts` — добавлен `FavoritesUsersModule`
- `src/users/users.service.ts` — метод `getPublicProfile`
- `src/users/users.controller.ts` — endpoint `GET /api/users/:id/profile`
- `src/favorites-users/favorites-users.module.ts`
- `src/favorites-users/favorites-users.controller.ts`
- `src/favorites-users/favorites-users.service.ts`
- `src/favorites-users/dto/favorites-users-query.dto.ts`

---

## 🧩 Prisma schema (FavoriteUser)

```prisma
model User {
  // ...
  savedListings SavedListing[]

  favoriteUsers FavoriteUser[] @relation("FavoriteOwner")
  favoritedBy   FavoriteUser[] @relation("FavoriteTarget")
}

model FavoriteUser {
  id           String   @id @default(uuid())
  ownerId      String
  targetUserId String
  createdAt    DateTime @default(now())

  owner  User @relation("FavoriteOwner", fields: [ownerId], references: [id], onDelete: Cascade)
  target User @relation("FavoriteTarget", fields: [targetUserId], references: [id], onDelete: Cascade)

  @@unique([ownerId, targetUserId])
  @@map("favorite_users")
}
```

---

## 🚀 Команды миграции и запуска

Из папки `backend`:

```bash
# Применить миграции
npx prisma migrate dev --name add_favorite_users

# Обновить Prisma Client
npx prisma generate

# Запустить backend
npm run start:dev
```

---

## 👤 Public Profile API

### `GET /api/users/:id/profile`

Требует JWT (`@CurrentUser()`).

**Фильтры доступа:**
- `role = USER`
- `onboardingCompleted = true`
- `verificationStatus = VERIFIED`
Иначе: `404 User not found`.

**Response пример:**

```json
{
  "id": "user-id",
  "firstName": "John",
  "lastName": "Doe",
  "age": 25,
  "city": "New York",
  "bio": "Easy-going roommate",
  "photos": [
    "https://cdn.example.com/photos/1.jpg",
    "https://cdn.example.com/photos/2.jpg"
  ],
  "occupationStatus": "STUDENT",
  "university": "NYU",
  "chronotype": "EARLY_BIRD",
  "noisePreference": "LOW",
  "personalityType": "INTROVERT",
  "smokingPreference": "NON_SMOKER",
  "petsPreference": "OK_WITH_PETS",
  "searchBudgetMin": 800,
  "searchBudgetMax": 1200,
  "searchDistrict": "Brooklyn",
  "roommateGenderPreference": "ANY",
  "stayTerm": "LONG_TERM",
  "createdAt": "2026-02-23T12:00:00.000Z",
  "isSaved": true
}
```

**Пример curl:**

```bash
curl -X GET "http://localhost:3000/api/users/<USER_ID>/profile" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

---

## ⭐ Favorites Users API

Все endpoints требуют JWT, работают с текущим пользователем (`@CurrentUser()`).
Нельзя добавлять в избранное самого себя и пользователей, которые не прошли onboarding/verification.

### 1. `POST /api/favorites/users/:targetUserId`

Добавить пользователя в избранное (idempotent).

- 400 — если `targetUserId` совпадает с текущим пользователем
- 404 — если пользователь не найден или не прошёл фильтры (role/verification/onboarding)

**Response (успех):**

```json
{
  "message": "User added to favorites"
}
```

**Пример curl:**

```bash
curl -X POST "http://localhost:3000/api/favorites/users/<TARGET_USER_ID>" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

---

### 2. `DELETE /api/favorites/users/:targetUserId`

Удалить пользователя из избранного. Операция idempotent — если записи не было, всё равно вернёт 200.

**Response:**

```json
{
  "message": "User removed from favorites"
}
```

**Пример curl:**

```bash
curl -X DELETE "http://localhost:3000/api/favorites/users/<TARGET_USER_ID>" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

---

### 3. `GET /api/favorites/users`

Получить список избранных пользователей текущего пользователя.

**Query параметры:**
- `page` — номер страницы (default 1)
- `limit` — элементов на странице (default 10, max 50)

**Response:**

```json
{
  "data": [
    {
      "id": "user-id",
      "firstName": "John",
      "age": 25,
      "city": "New York",
      "searchDistrict": "Brooklyn",
      "photos": [
        "https://cdn.example.com/photos/1.jpg"
      ],
      "createdAt": "2026-02-23T12:00:00.000Z",
      "isSaved": true
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 1,
    "totalPages": 1
  }
}
```

**Пример curl:**

```bash
curl -X GET "http://localhost:3000/api/favorites/users?page=1&limit=10" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

---

## 🧪 Проверка через Swagger

1. Запустить backend: `npm run start:dev`
2. Открыть Swagger: `http://localhost:3000/api`
3. Нажать **Authorize** и вставить `Bearer <ACCESS_TOKEN>`
4. Протестировать:
   - `GET /users/{id}/profile` (tag `user-profile`)
   - `POST /favorites/users/{targetUserId}`
   - `DELETE /favorites/users/{targetUserId}`
   - `GET /favorites/users` (tag `favorites-users`)

