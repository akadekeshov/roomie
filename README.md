# roommate_app

A new Flutter project.

## Backend Commands

The backend lives in the `backend` folder. To run Prisma and NestJS commands from the project root, use:

```bash
npm run prisma:generate
npm run prisma:migrate
npm run start:dev
```

If backend dependencies are not installed yet, run:

```bash
npm run backend:install
```

Note: `npx prisma generate` from the Flutter root can pull a different Prisma CLI version than the backend uses. Prefer `npm run prisma:generate` from the root or run commands directly inside `backend`.
The root `prisma:generate` command uses the backend safe script and stops conflicting local Prisma/Node processes before regenerating the client.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
