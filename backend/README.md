# Roomie Backend API

A NestJS backend API for a roommate matching application.

## Tech Stack

- **Framework**: NestJS
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Authentication**: JWT (Access + Refresh tokens)
- **Documentation**: Swagger/OpenAPI
- **Containerization**: Docker & Docker Compose

## Features

- User authentication (register, login, refresh, logout)
- User profile management
- Room listing CRUD operations
- Save/unsave listings
- Advanced filtering and pagination
- JWT-based authentication with refresh tokens
- Swagger API documentation

## Prerequisites

- Node.js 20+
- Docker & Docker Compose
- npm or yarn

## Getting Started

### Using Docker Compose (Recommended)

1. Clone the repository:
```bash
git clone <repository-url>
cd roomie-backend
```

2. Create a `.env` file in the root directory:
```env
PORT=3000
DATABASE_URL=postgresql://postgres:postgres@db:5432/roomie?schema=public
JWT_ACCESS_SECRET=your_access_secret_key
JWT_REFRESH_SECRET=your_refresh_secret_key
ACCESS_TOKEN_TTL=15m
REFRESH_TOKEN_TTL=7d
```

3. Start the application:
```bash
docker-compose up --build
```

The API will be available at `http://localhost:3000`
Swagger documentation will be available at `http://localhost:3000/api`

### Local Development

1. Install dependencies:
```bash
npm install
```

2. Set up environment variables (create `.env` file):
```env
PORT=3000
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/roomie?schema=public
JWT_ACCESS_SECRET=your_access_secret_key
JWT_REFRESH_SECRET=your_refresh_secret_key
ACCESS_TOKEN_TTL=15m
REFRESH_TOKEN_TTL=7d
```

3. Generate Prisma client:
```bash
npm run prisma:generate
```

4. Run database migrations:
```bash
npm run prisma:migrate
```

5. Start the development server:
```bash
npm run start:dev
```

## API Endpoints

### Authentication (`/api/auth`)
- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - Logout user
- `GET /api/auth/me` - Get current user (protected)

### Users (`/api/users`)
- `GET /api/users/:id` - Get user by ID (protected)
- `PATCH /api/users/me` - Update current user (protected)
- `PATCH /api/users/me/password` - Update password (protected)

### Listings (`/api/listings`)
- `POST /api/listings` - Create a new listing (protected)
- `GET /api/listings` - Get all listings with filters and pagination (protected)
- `GET /api/listings/:id` - Get listing by ID (protected)
- `PATCH /api/listings/:id` - Update listing (owner only, protected)
- `DELETE /api/listings/:id` - Delete listing (owner only, protected)

### Saved Listings (`/api/saved`)
- `POST /api/saved/:listingId` - Save a listing (protected)
- `DELETE /api/saved/:listingId` - Unsave a listing (protected)
- `GET /api/saved` - Get all saved listings (protected)

## Database Schema

### Models
- **User**: User accounts with profile information
- **RefreshToken**: Refresh tokens for JWT authentication
- **Listing**: Room listings with details
- **SavedListing**: User's saved listings

### Enums
- **Gender**: MALE, FEMALE, OTHER, PREFER_NOT_TO_SAY
- **RoomType**: SINGLE, DOUBLE, SHARED, ENTIRE_PLACE

## Authentication

The API uses JWT Bearer token authentication. Include the access token in the Authorization header:

```
Authorization: Bearer <access_token>
```

To get an access token:
1. Register a new user or login
2. Use the `accessToken` from the response
3. Use the `refreshToken` to get a new access token when it expires

## Swagger Documentation

Once the server is running, visit `http://localhost:3000/api` to access the Swagger UI where you can:
- View all available endpoints
- Test endpoints directly
- See request/response schemas
- Authenticate using the "Authorize" button

## Scripts

- `npm run build` - Build the application
- `npm run start:dev` - Start development server with hot reload
- `npm run start:prod` - Start production server
- `npm run lint` - Run ESLint
- `npm run test` - Run unit tests
- `npm run prisma:generate` - Generate Prisma client
- `npm run prisma:migrate` - Run database migrations
- `npm run prisma:studio` - Open Prisma Studio

## Project Structure

```
src/
├── auth/           # Authentication module
├── users/          # User management module
├── listings/       # Listing CRUD module
├── saved/          # Saved listings module
├── common/         # Shared guards and decorators
├── prisma/         # Prisma service and module
├── app.module.ts   # Root module
└── main.ts         # Application entry point
```

## License

MIT
