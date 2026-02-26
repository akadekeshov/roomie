# KYC Verification Implementation Guide

## 📋 Список изменённых и созданных файлов

### Изменённые файлы:
1. `prisma/schema.prisma` - добавлены UserRole enum, role поле, KYC поля
2. `src/auth/strategies/jwt.strategy.ts` - добавлен role в select и возврат
3. `src/common/common.module.ts` - добавлен RolesGuard как глобальный guard
4. `src/common/guards/roles.guard.ts` - обновлён для поддержки @Public
5. `src/app.module.ts` - добавлены VerificationModule и AdminVerificationsModule

### Новые файлы:

#### Verification Module (для пользователей):
- `src/verification/verification.module.ts`
- `src/verification/verification.controller.ts`
- `src/verification/verification.service.ts`
- `src/verification/dto/verification-document.dto.ts`
- `src/verification/dto/verification-selfie.dto.ts`

#### Admin Verifications Module (для модераторов):
- `src/admin-verifications/admin-verifications.module.ts`
- `src/admin-verifications/admin-verifications.controller.ts`
- `src/admin-verifications/admin-verifications.service.ts`
- `src/admin-verifications/dto/reject-verification.dto.ts`

#### Common (Roles system):
- `src/common/decorators/roles.decorator.ts`
- `src/common/guards/roles.guard.ts` (обновлён)

---

## 🚀 Команды для запуска

### 1. Генерация Prisma Client и миграция БД

```bash
cd backend

# Сгенерировать Prisma Client с новыми типами
npx prisma generate

# Создать и применить миграцию
npx prisma migrate dev --name add_roles_and_kyc_selfie
```

### 2. Создание первого админа/модератора (опционально)

После миграции можно создать админа через Prisma Studio или SQL:

```bash
# Открыть Prisma Studio
npx prisma studio

# Или через SQL (в psql или через Prisma Studio SQL tab):
# UPDATE users SET role = 'ADMIN' WHERE email = 'your-admin@email.com';
```

### 3. Запуск приложения

```bash
# Development mode
npm run start:dev

# Production mode
npm run build
npm run start:prod
```

---

## 📚 API Endpoints

### User Verification Endpoints (требуют JWT)

#### `PATCH /api/verification/document`
Загрузить **URL** документа для верификации (старый/совместимый режим, без загрузки файла).

**Request Body:**
```json
{
  "documentUrl": "https://cdn.example.com/docs/passport-1.jpg"
}
```

**Response:**
```json
{
  "id": "user-id",
  "verificationDocumentUrl": "https://cdn.example.com/docs/passport-1.jpg",
  "verificationStatus": "NONE"
}
```

#### `PATCH /api/verification/document/upload`
Загрузить **файл** документа для верификации (`multipart/form-data`, поле `file`).

Разрешённые форматы:
- `image/jpeg`
- `image/png`
- `image/webp`

Лимит размера: **5MB**.

**Пример запроса (curl):**
```bash
curl -X PATCH "http://localhost:3000/api/verification/document/upload" ^
  -H "Authorization: Bearer <ACCESS_TOKEN>" ^
  -H "Content-Type: multipart/form-data" ^
  -F "file=@C:/path/to/passport.jpg"
```

**Response:**
```json
{
  "id": "user-id",
  "verificationDocumentUrl": "/uploads/kyc/documents/1730000000000-123456789.jpg",
  "verificationStatus": "NONE"
}
```

#### `PATCH /api/verification/selfie`
Загрузить **URL** селфи с документом (старый/совместимый режим, без загрузки файла).

**Request Body:**
```json
{
  "selfieUrl": "https://cdn.example.com/selfies/selfie-with-doc.jpg"
}
```

**Response:**
```json
{
  "id": "user-id",
  "verificationSelfieUrl": "https://cdn.example.com/selfies/selfie-with-doc.jpg",
  "verificationStatus": "NONE"
}
```

#### `PATCH /api/verification/selfie/upload`
Загрузить **файл** селфи (`multipart/form-data`, поле `file`).

Разрешённые форматы и лимит размера — такие же, как для документа:
- `image/jpeg`
- `image/png`
- `image/webp`
- максимум **5MB**

**Пример запроса (curl):**
```bash
curl -X PATCH "http://localhost:3000/api/verification/selfie/upload" ^
  -H "Authorization: Bearer <ACCESS_TOKEN>" ^
  -H "Content-Type: multipart/form-data" ^
  -F "file=@C:/path/to/selfie.jpg"
```

**Response:**
```json
{
  "id": "user-id",
  "verificationSelfieUrl": "/uploads/kyc/selfies/1730000000000-987654321.png",
  "verificationStatus": "NONE"
}
```

#### `POST /api/verification/submit`
Отправить заявку на проверку (требует оба фото).

**Response:**
```json
{
  "id": "user-id",
  "verificationStatus": "PENDING",
  "verificationDocumentUrl": "https://...",
  "verificationSelfieUrl": "https://..."
}
```

#### `GET /api/verification/me`
Получить статус своей верификации.

**Response:**
```json
{
  "status": "PENDING",
  "documentUrl": "https://...",
  "selfieUrl": "https://...",
  "rejectReason": null,
  "reviewedAt": null,
  "lastUpdated": "2024-01-01T00:00:00.000Z"
}
```

---

### Admin Verification Endpoints (требуют роль ADMIN или MODERATOR)

#### `GET /api/admin/verifications/pending`
Список всех пользователей со статусом PENDING.

**Response:**
```json
[
  {
    "id": "user-id",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "documentUrl": "/uploads/kyc/documents/1730000000000-123456789.jpg",
    "selfieUrl": "/uploads/kyc/selfies/1730000000000-987654321.png",
    "documentFullUrl": "http://localhost:3000/uploads/kyc/documents/1730000000000-123456789.jpg",
    "selfieFullUrl": "http://localhost:3000/uploads/kyc/selfies/1730000000000-987654321.png",
    "status": "PENDING",
    "submittedAt": "2024-01-01T00:00:00.000Z",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
]
```

#### `GET /api/admin/verifications/:userId`
Детали верификации конкретного пользователя.

**Response:**
```json
{
  "id": "user-id",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "age": 25,
  "city": "New York",
  "verificationStatus": "PENDING",
  "verificationDocumentUrl": "/uploads/kyc/documents/1730000000000-123456789.jpg",
  "verificationSelfieUrl": "/uploads/kyc/selfies/1730000000000-987654321.png",
  "documentFullUrl": "http://localhost:3000/uploads/kyc/documents/1730000000000-123456789.jpg",
  "selfieFullUrl": "http://localhost:3000/uploads/kyc/selfies/1730000000000-987654321.png",
  "verificationRejectReason": null,
  "verificationReviewedAt": null,
  "verificationReviewedBy": null,
  "submittedAt": "2024-01-01T00:00:00.000Z",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

#### `PATCH /api/admin/verifications/:userId/approve`
Одобрить верификацию пользователя.

**Response:**
```json
{
  "id": "user-id",
  "verificationStatus": "VERIFIED",
  "verificationReviewedAt": "2024-01-01T00:00:00.000Z",
  "verificationReviewedBy": "admin-user-id"
}
```

#### `PATCH /api/admin/verifications/:userId/reject`
Отклонить верификацию с причиной.

**Request Body:**
```json
{
  "reason": "Document photo is unclear or selfie does not match the document"
}
```

**Response:**
```json
{
  "id": "user-id",
  "verificationStatus": "REJECTED",
  "verificationRejectReason": "Document photo is unclear...",
  "verificationReviewedAt": "2024-01-01T00:00:00.000Z",
  "verificationReviewedBy": "admin-user-id"
}
```

---

## 🔐 Роли и права доступа

### UserRole Enum:
- `USER` - обычный пользователь (по умолчанию)
- `MODERATOR` - модератор (может проверять верификации)
- `ADMIN` - администратор (может проверять верификации)

### Защита эндпоинтов:
- **User endpoints** (`/api/verification/*`): защищены JWT, доступны всем авторизованным пользователям
- **Admin endpoints** (`/api/admin/verifications/*`): защищены JWT + требуют роль `ADMIN` или `MODERATOR`

### Использование декораторов:
```typescript
// Публичный эндпоинт (без авторизации)
@Public()
@Post('register')

// Защищённый эндпоинт (требует JWT)
@Get('me')

// Защищённый эндпоинт с ролью
@Roles(UserRole.ADMIN, UserRole.MODERATOR)
@Get('admin/verifications/pending')
```

---

## 📝 Swagger Documentation

После запуска приложения:
- Swagger UI доступен по адресу: `http://localhost:3000/api`
- Все эндпоинты документированы с примерами запросов/ответов
- Для тестирования админ-эндпоинтов используйте кнопку "Authorize" в Swagger и введите JWT токен пользователя с ролью ADMIN или MODERATOR

---

## 🔄 Логика работы

1. **Пользователь загружает документы:**
   - Вариант A (URL only, обратная совместимость):
     - Загружает URL документа → `PATCH /verification/document`
     - Загружает URL селфи → `PATCH /verification/selfie`
   - Вариант B (рекомендуемый, с загрузкой файлов):
     - Загружает файл документа → `PATCH /verification/document/upload` (`multipart/form-data`, поле `file`)
     - Загружает файл селфи → `PATCH /verification/selfie/upload` (`multipart/form-data`, поле `file`)
   - Отправляет на проверку → `POST /verification/submit` (статус → PENDING)

2. **Модератор проверяет:**
   - Просматривает список → `GET /admin/verifications/pending`
   - Смотрит детали → `GET /admin/verifications/:userId`
   - Одобряет → `PATCH /admin/verifications/:userId/approve` (статус → VERIFIED)
   - Или отклоняет → `PATCH /admin/verifications/:userId/reject` (статус → REJECTED + reason)

3. **Пользователь видит результат:**
   - Проверяет статус → `GET /verification/me`
   - Если REJECTED, может заново загрузить фото и отправить (статус снова станет PENDING)

---

## ⚠️ Важные замечания

1. **Хранение и раздача файлов (upload):**
   - Файлы KYC хранятся локально в папке `./uploads` (относительно `backend`).
   - Структура:
     - `uploads/kyc/documents`
     - `uploads/kyc/selfies`
   - При первом обращении к upload-эндпоинтам директории создаются автоматически.
   - В `AppModule` подключён `ServeStaticModule` с:
     - `rootPath = <backend>/uploads`
     - `serveRoot = /uploads`
   - Поэтому любой сохранённый путь `/uploads/...` прямо открывается в браузере:
     - `http://localhost:3000/uploads/kyc/documents/<filename>`
     - `http://localhost:3000/uploads/kyc/selfies/<filename>`

2. **Валидация файлов:**
   - Разрешённые MIME-типы:
     - `image/jpeg`
     - `image/png`
     - `image/webp`
   - Ограничение размера: максимум **5MB**.
   - При нарушении любого правила upload отвечает `400 Bad Request` с сообщением:
     - «Invalid file type. Only JPEG, PNG, and WEBP images are allowed.»
     - или «File is required»

3. **Безопасность:**
   - Все эндпоинты защищены JWT
   - Админ-эндпоинты дополнительно защищены ролями
   - Пароли никогда не возвращаются в ответах (используется `select` в Prisma)

4. **Обратная совместимость:**
   - Старые эндпоинты в `onboarding` (`/onboarding/verification/document`, `/onboarding/verification/submit`) остались для обратной совместимости.
   - Старые URL-based эндпоинты в `verification` также продолжают работать.
   - Новые upload-эндпоинты добавлены **дополнительно**, не ломая существующий контракт.
   - В БД по-прежнему хранятся строки-пути (`verificationDocumentUrl`, `verificationSelfieUrl`), только теперь это, как правило, относительные пути `/uploads/...`.

---

## 🧪 Тестирование

### Пример тестирования через Swagger:

1. **Авторизуйтесь как обычный пользователь:**
   - `POST /api/auth/login` → получите `accessToken`
   - Нажмите "Authorize" в Swagger, вставьте токен

2. **Загрузите документы:**
   - `PATCH /api/verification/document` с `{ "documentUrl": "https://example.com/doc.jpg" }`
   - `PATCH /api/verification/selfie` с `{ "selfieUrl": "https://example.com/selfie.jpg" }`
   - `POST /api/verification/submit`

3. **Авторизуйтесь как админ:**
   - Создайте пользователя с ролью ADMIN через Prisma Studio или SQL
   - Войдите под этим пользователем → получите токен
   - Обновите токен в Swagger

4. **Проверьте верификацию:**
   - `GET /api/admin/verifications/pending` → увидите список
   - `GET /api/admin/verifications/:userId` → детали
   - `PATCH /api/admin/verifications/:userId/approve` → одобрить
   - Или `PATCH /api/admin/verifications/:userId/reject` с `{ "reason": "..." }`

---

## ✅ Чеклист после внедрения

- [ ] Выполнена миграция Prisma
- [ ] Prisma Client сгенерирован
- [ ] Создан хотя бы один пользователь с ролью ADMIN или MODERATOR
- [ ] Приложение запускается без ошибок
- [ ] Swagger доступен и показывает новые эндпоинты
- [ ] Протестированы user endpoints
- [ ] Протестированы admin endpoints
- [ ] Проверена работа ролей (обычный пользователь не может зайти в админ-эндпоинты)
