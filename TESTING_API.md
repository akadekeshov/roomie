# Тестирование Home + Saved (API)

## Base URL

- **Android emulator:** `http://10.0.2.2:<PORT>/api` (подставляется автоматически).
- **iOS simulator:** `http://localhost:<PORT>/api`.
- **Порт по умолчанию:** 3000. Задать свой:  
  `--dart-define=API_PORT=4000` при запуске Flutter.

Backend должен быть доступен по этому адресу (на Windows — localhost:PORT).

## Какие endpoints должны отвечать

1. **GET /api/listings**  
   Ответ: `{ "data": [ Listing, ... ], "meta": { "page", "limit", "total", "totalPages" } }`  
   Каждый Listing: id, title, description, address, city, state?, zipCode?, country, price, roomType, availableFrom?, availableTo?, amenities[], images[], ownerId, createdAt, updatedAt, owner: { id, email?, firstName?, lastName? }.

2. **GET /api/saved** (с заголовком `Authorization: Bearer <token>`)  
   Ответ: массив `{ id, userId, listingId, createdAt, listing: { ...Listing } }`.

3. **POST /api/saved/:listingId** (с JWT)  
   Сохраняет объявление для текущего пользователя.

4. **DELETE /api/saved/:listingId** (с JWT)  
   Удаляет из сохранённых.

5. **POST /api/auth/login** (или register + verify)  
   Чтобы получить токен и иметь возможность сохранять и видеть вкладку Saved.

## Что проверить в UI

- **Home:** после запуска — индикатор загрузки, затем список карточек из GET /listings. Пустой ответ — текст «Пока нет объявлений». Ошибка — текст и кнопка «Повторить».
- **Сохранение:** на карточке кнопка «Сохранить» → запрос POST /saved/:id → кнопка меняется на «Сохранено», при повторном нажатии — DELETE и снова «Сохранить».
- **Saved:** вкладка показывает объявления из GET /saved. Тап по карточке — экран детали с кнопкой «Удалить из сохранённых».
- **Навигация:** нижняя навигация только в MainShell (одна на всё приложение). После логина/завершения онбординга — переход в MainShell (shell).

## Логи Dio

При ошибках запросов в консоли выводятся: метод, URI, statusCode и data ответа — для отладки.
