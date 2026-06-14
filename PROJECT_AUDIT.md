# Roomie Project Audit

## Executive summary

Roomie is already beyond a prototype in scope: the repository contains a Flutter mobile client, a NestJS backend, Prisma/PostgreSQL persistence, an admin web panel, hybrid roommate matching, chat, agreements, disputes, KYC verification, social auth, and localization infrastructure. The project architecture is understandable, modules are separated at a high level, and the main user flows are present end to end.

At the same time, the project is not production-ready yet. The biggest blockers are in security and operational maturity rather than basic feature presence. The most serious issues are committed secrets, public exposure of uploaded KYC files, weak administrative verification rules, missing rate limiting for auth/OTP endpoints, raw refresh token storage, and the fact that test coverage is still very small compared to the project size. On the product side, localization is only partially completed, multiple screens still contain hardcoded or broken mojibake text, some profile/settings menu items are placeholders, chat uses periodic polling instead of realtime delivery, and several features exposed in UI are not fully implemented behind the scenes.

If this project is being prepared for diploma defense, it is defendable as an MVP-plus academic product with a broad feature set, but not yet as a secure production service. The strongest positioning is: "a working end-to-end roommate platform with AI-assisted search, agreements, moderation, and bilingual support in progress." The weakest point is operational/security hardening.

Issue summary:

- P0: 3
- P1: 14
- P2: 21
- P3: 6

## Project architecture

High-level structure:

- Mobile app: Flutter + Riverpod + Dio + SharedPreferences + flutter_secure_storage.
- Backend: NestJS 11 + Prisma + PostgreSQL.
- Admin panel: static web app served by backend from `backend/admin-web`.
- Auth: email/phone OTP, Google Sign-In, Facebook auth.
- Matching: weighted rule-based compatibility with optional OpenAI embedding enhancement.
- Agreements/payments/disputes: present in both backend and Flutter UI.

Observed architectural strengths:

- `backend/src/app.module.ts` keeps major domains modular.
- `lib/app/app.dart` already connects Flutter localization delegates and Riverpod locale state.
- `lib/core/localization/locale_provider.dart` persists selected language and resolves the initial locale from system language.
- Flutter auth tokens are stored with `flutter_secure_storage` in `lib/core/storage/auth_token_storage.dart`.

Observed architectural weaknesses:

- The `User` model in `backend/prisma/schema.prisma:10-85` is overloaded with account, profile, matching, moderation, and KYC fields.
- Backend business logic is concentrated in very large services, especially `backend/src/users/users.service.ts` and `backend/src/auth/auth.service.ts`.
- The admin panel is tightly coupled to the same backend runtime and stores admin JWT in browser `localStorage` (`backend/admin-web/index.html:974`, `1221`).
- There is no visible CI pipeline in `.github/workflows` or `backend/.github/workflows`.

## Feature status matrix

| Feature | Status | Evidence |
| --- | --- | --- |
| Email/phone auth with OTP | works | `backend/src/auth/auth.controller.ts`, `backend/src/auth/auth.service.ts` |
| Google/Facebook social auth | works | `backend/src/auth/auth.service.ts`, `lib/features/auth/data/social_auth_service.dart` |
| Token persistence on mobile | works | `lib/core/storage/auth_token_storage.dart` |
| Onboarding flow | partially works | present in routes and profile pages, but texts/localization are incomplete |
| Main recommendation feed | works | `lib/features/home/data/home_providers.dart`, `backend/src/users/users.service.ts` |
| AI search | partially works | hybrid scoring works, but semantics and copy overstate "AI"; route is `/ai`, not `/ai_search` |
| Saved users / favorites | works | `favorite_users` functionality present in backend and Flutter |
| Direct chat | partially works | works functionally, but uses polling and lacks uniqueness guarantee for direct threads |
| Agreements | works | backend + Flutter pages present |
| Payment reminders | partially works | reminder/payment models exist, but payment implementation is mock only |
| Real payment gateway | absent | only mock card bind and mock pay exist |
| Verification / KYC | partially works | document/selfie upload and moderation exist, but approval and storage are unsafe |
| Disputes / complaints | works | backend and mobile admin/user flows exist |
| Admin moderation panel | partially works | functional, but security and UX quality are insufficient |
| Notifications | absent | UI labels exist, but no notification backend/push implementation was found |
| Privacy/security/support/about settings pages | absent | menu items visible, but no handlers in profile page |
| Localization infrastructure | works | `flutter_localizations`, `intl`, ARB generation, locale provider |
| Full bilingual coverage | partially works | many screens still use hardcoded or broken strings |
| Route guarding | partially works | splash logic exists, but no centralized auth guard/router policy |
| Automated test coverage | absent/very weak | only a few tests compared to project size |
| CI/CD | absent | no workflow files detected |

## Critical issues

### P0-01 Committed secrets in backend environment file

- Priority: P0
- Location: `backend/.env`
- Description: The repository contains real runtime secrets and credentials, including database connection, JWT secrets, and third-party API keys.
- Why it is a problem: Anyone with repository or backup access can reuse these credentials. This is an immediate security incident, not a code-style issue.
- Consequences: Full API compromise, token forgery, database access, third-party billing abuse.
- Recommended fix:
  - Rotate all exposed secrets immediately.
  - Remove `.env` from version control.
  - Commit only `.env.example` with placeholders.
  - Configure secrets through deployment environment or a secret manager.
- Example fix:
  ```text
  1. Rotate all current secrets.
  2. Add backend/.env to .gitignore.
  3. Commit backend/.env.example without real values.
  4. Reconfigure production/staging with new secrets.
  ```
- Complexity: Small

### P0-02 KYC files are publicly accessible as static uploads

- Priority: P0
- Location: `backend/src/main.ts:33-36`, `backend/src/verification/verification.service.ts:54`, `114`
- Description: All uploaded files under `uploads` are exposed via `/uploads`, including KYC documents and selfies saved under `/uploads/kyc/...`.
- Why it is a problem: Identity documents and selfies must not be publicly retrievable by URL alone.
- Consequences: Privacy breach, legal/compliance risk, identity theft exposure.
- Recommended fix:
  - Move KYC files to private storage.
  - Replace direct URLs with protected download endpoints for admins only.
  - Add signed URLs or per-request authorization checks.
- Example fix:
  ```ts
  // Store only internal object key in DB
  verificationDocumentKey: 'kyc/private/...'

  // Serve through guarded controller
  GET /admin/verification/:userId/document
  ```
- Complexity: Medium

### P0-03 Verification can be approved without a valid pending submission

- Priority: P0
- Location: `backend/src/admin-verifications/admin-verifications.service.ts:257-289`
- Description: `approveVerification()` blocks only already verified users. It does not require `PENDING` status and does not ensure document/selfie files are present.
- Why it is a problem: A moderator can mark an account as verified without a proper KYC package.
- Consequences: False trust signals, moderation abuse, compliance failure.
- Recommended fix:
  - Require `verificationStatus === PENDING`.
  - Require both `verificationDocumentUrl` and `verificationSelfieUrl`.
  - Log admin action separately.
- Example fix:
  ```ts
  if (user.verificationStatus !== VerificationStatus.PENDING) {
    throw new BadRequestException('Verification is not pending');
  }
  if (!user.verificationDocumentUrl || !user.verificationSelfieUrl) {
    throw new BadRequestException('Verification files are missing');
  }
  ```
- Complexity: Small

## Security audit

### P1-01 Auth and OTP endpoints leak account existence and state

- Priority: P1
- Location: `backend/src/auth/auth.service.ts:409`, `427`, `491`, `524`, `641-652`, `872-889`
- Description: The service returns distinct messages for "user not found", "email already registered", "account banned", "email not verified", and similar cases.
- Why it is a problem: These differences allow attacker-driven account enumeration.
- Consequences: Easier credential stuffing, phishing, and targeted abuse.
- Recommended fix:
  - Return neutral user-facing responses for login/register/resend flows.
  - Log internal reason server-side only.
- Complexity: Medium

### P1-02 No visible rate limiting on auth endpoints

- Priority: P1
- Location: `backend/src/main.ts:9-63`, `backend/src/auth/auth.controller.ts:29-170`
- Description: Public auth routes exist, but no throttler middleware, guards, or decorators were found on these endpoints.
- Why it is a problem: OTP resend and login are brute-force targets.
- Consequences: Credential stuffing, OTP spam, increased infrastructure cost.
- Recommended fix:
  - Add Nest throttling globally and stricter limits on auth endpoints.
  - Rate-limit by IP and normalized identity.
- Complexity: Medium

### P1-03 OTP codes are logged in development mode through runtime flag

- Priority: P1
- Location: `backend/src/auth/auth.service.ts:438-440`, `470-472`, `535-537`, `567-569`, `687-692`
- Description: When `OTP_DEV_LOG === 'true'`, generated OTP codes are printed to logs.
- Why it is a problem: Log sinks are often retained, copied, or shared.
- Consequences: OTP interception and accidental disclosure in shared environments.
- Recommended fix:
  - Disable OTP logging outside local development.
  - Gate it behind stricter environment checks.
  - Prefer masked audit logs over raw codes.
- Complexity: Small

### P1-04 Refresh tokens are stored raw in the database

- Priority: P1
- Location: `backend/prisma/schema.prisma:228-237`
- Description: `RefreshToken.token` stores the full token as a unique string.
- Why it is a problem: Database compromise immediately becomes session compromise.
- Consequences: Token replay from DB dump.
- Recommended fix:
  - Store a hash of the refresh token, not the token itself.
  - Compare hashed values on refresh.
- Complexity: Medium

### P1-05 New login invalidates all user sessions

- Priority: P1
- Location: `backend/src/auth/auth.service.ts:999`
- Description: `generateTokens()` deletes all refresh tokens for the user before issuing a new one.
- Why it is a problem: Multi-device use becomes fragile and confusing.
- Consequences: User is silently logged out on other devices; poor UX; harder support.
- Recommended fix:
  - Store refresh tokens per device/session.
  - Revoke only the current session or selected sessions.
- Complexity: Medium

### P1-06 Admin JWT is stored in browser localStorage

- Priority: P1
- Location: `backend/admin-web/index.html:974`, `1221`, `1860`, `1887`
- Description: The admin web panel stores the bearer token in `localStorage`.
- Why it is a problem: Any XSS in the panel or same-origin page can steal the admin token.
- Consequences: Full admin account takeover.
- Recommended fix:
  - Move admin auth to secure HTTP-only cookies or isolate the panel on a hardened origin.
  - Add CSP and XSS hardening.
- Complexity: Medium

### P1-07 CORS policy is too permissive for credentialed traffic

- Priority: P1
- Location: `backend/src/main.ts:13-16`
- Description: Backend enables `origin: true` and `credentials: true` without an allowlist.
- Why it is a problem: Credentialed cross-origin traffic should be restricted explicitly.
- Consequences: Expanded CSRF/XSS blast radius and difficult origin governance.
- Recommended fix:
  - Replace dynamic permissive CORS with environment-based allowlist.
- Complexity: Small

### P1-08 Uploaded KYC files are stored on local disk without privacy hardening

- Priority: P1
- Location: `backend/src/verification/verification.controller.ts:41-77`, `backend/src/verification/verification.service.ts:54-60`, `114-120`
- Description: Files are saved directly to server filesystem with simple MIME filtering only.
- Why it is a problem: There is no EXIF stripping, antivirus scanning, encryption at rest, or private object storage.
- Consequences: Sensitive file leakage and operational fragility.
- Recommended fix:
  - Move to private object storage.
  - Strip metadata and validate file signatures.
  - Add retention and deletion policy.
- Complexity: Large

### P1-09 Mock payment endpoints are still part of the main product flow

- Priority: P1
- Location: `backend/src/payments/payments.service.ts:29-44`, `134-165`
- Description: Card binding and payment completion are explicitly mock implementations.
- Why it is a problem: This is acceptable for demo mode, but dangerous if treated as real payment functionality.
- Consequences: Users/admins may assume financial actions are real; production misuse risk.
- Recommended fix:
  - Hide mock endpoints behind non-production flags.
  - Clearly separate sandbox/demo mode from real environments.
- Complexity: Small

## Database audit

### P2-01 User table is overloaded with too many unrelated domains

- Priority: P2
- Location: `backend/prisma/schema.prisma:10-85`
- Description: Account data, profile, moderation, search preferences, onboarding, and verification live in one `User` model.
- Why it is a problem: This increases coupling, migration risk, and service complexity.
- Consequences: Harder evolution, more regressions, wider blast radius per schema change.
- Recommended fix:
  - Split into domain tables such as `UserProfile`, `UserPreference`, `UserVerification`, `UserModerationState`.
- Complexity: Large

### P2-02 No soft delete strategy on core business data

- Priority: P2
- Location: `backend/prisma/schema.prisma` core models
- Description: Core models do not appear to use `deletedAt`/archival semantics.
- Why it is a problem: Hard deletes complicate auditability and user recovery.
- Consequences: Lost moderation context and reduced compliance flexibility.
- Recommended fix:
  - Add soft-delete strategy for users, agreements, disputes, and possibly conversations.
- Complexity: Large

### P2-03 Migration history looks inconsistent and difficult to audit

- Priority: P2
- Location: `backend/prisma/migrations/*`
- Description: Migration history includes multiple init-like migrations and an unnamed timestamp-only folder `20260224110733`.
- Why it is a problem: This increases schema drift risk across environments.
- Consequences: Failed deployments and hard-to-reproduce database state.
- Recommended fix:
  - Audit migration chain.
  - Rename/document ambiguous migrations.
  - Validate clean bootstrap from empty DB.
- Complexity: Medium

### P2-04 No separate audit log model for admin actions

- Priority: P2
- Location: `backend/prisma/schema.prisma`, `backend/src/admin-verifications/admin-verifications.service.ts`
- Description: Admin moderation actions update user state directly without a first-class immutable audit trail model.
- Why it is a problem: Sensitive actions should be reconstructable.
- Consequences: Weak accountability and poor forensic capability.
- Recommended fix:
  - Add `AdminAction` / `ModerationEvent` model with actor, target, action, reason, timestamp.
- Complexity: Medium

## Authentication audit

### P2-05 No visible password reset / forgot-password flow

- Priority: P2
- Location: `backend/src/auth/auth.controller.ts`, Flutter auth screens under `lib/features/auth`
- Description: Register, OTP verify, social auth, login, refresh, and logout exist, but a full forgot-password flow was not found.
- Why it is a problem: Users can be locked out permanently.
- Consequences: Support burden and weaker retention.
- Recommended fix:
  - Add reset request, OTP/email verification, and password update flow.
- Complexity: Medium

### P3-01 Some frontend fallback auth/profile strings are still broken or not localized

- Priority: P3
- Location: `lib/features/auth/data/auth_repository.dart:42-50`, `lib/features/profile/data/me_repository.dart:50-55`
- Description: Fallback strings still use hardcoded English or mojibake placeholders.
- Why it is a problem: It degrades perceived quality and breaks bilingual consistency.
- Consequences: Poor UX on incomplete profiles and error states.
- Recommended fix:
  - Route all fallback strings through ARB localization.
- Complexity: Small

## Matching audit

### P1-10 Required mismatches are penalized, not strictly excluded

- Priority: P1
- Location: `backend/src/users/users.service.ts:1580-1588`
- Description: Mandatory preference mismatches lower score through a penalty ratio instead of hard-eliminating candidates.
- Why it is a problem: Users may still see matches that violate "must-have" requirements.
- Consequences: Trust loss in recommendation quality.
- Recommended fix:
  - For explicitly required criteria, filter candidates out before ranking.
  - Keep scoring only for non-blocking criteria.
- Complexity: Medium

### P2-06 AI search naming overstates what the engine is actually doing

- Priority: P2
- Location: `backend/src/ai_search/ai.controller.ts:25-39`, `backend/src/ai_search/ai-search.service.ts:170`, `backend/src/users/users.service.ts:1286-1688`
- Description: Search is hybrid and partly AI-assisted, but the dominant layer is rule scoring with optional embeddings and fallback compatibility scoring.
- Why it is a problem: For product and diploma claims, wording should match implementation.
- Consequences: Overclaim risk during review or defense.
- Recommended fix:
  - Describe the feature as hybrid search: structured filters + compatibility scoring + embedding enhancement.
- Complexity: Small

### P2-07 Home recommendations silently fall back when profile load fails

- Priority: P2
- Location: `lib/features/home/data/home_providers.dart:33-37`, `65-67`
- Description: If `meProvider` fails, the provider still returns `HomeAutoState.loaded`.
- Why it is a problem: Users may get a seemingly valid home state while core user context is unavailable.
- Consequences: Confusing UX and harder incident diagnosis.
- Recommended fix:
  - Distinguish between `loaded` and `profileLoadFailed`.
  - Surface a localized recovery state.
- Complexity: Small

## Chat audit

### P1-11 Direct conversations are deduplicated in memory, not guaranteed in schema

- Priority: P1
- Location: `backend/src/chat/chat.service.ts:34-65`, `98-105`
- Description: Existing direct chats are found by reading many conversations and comparing participant sets in memory.
- Why it is a problem: There is no hard uniqueness invariant for a direct pair conversation.
- Consequences: Duplicate chats, race conditions, messy user history.
- Recommended fix:
  - Add explicit direct-conversation key or dedicated unique constraint.
  - Resolve creation inside a transaction.
- Complexity: Medium

### P2-08 Conversation list does N+1 unread-count queries

- Priority: P2
- Location: `backend/src/chat/chat.service.ts:144-166`
- Description: `listConversations()` runs `message.count()` for each row separately.
- Why it is a problem: The cost grows linearly with the number of conversations.
- Consequences: Slow inbox loading for active users.
- Recommended fix:
  - Precompute unread counts or aggregate in a single query.
- Complexity: Medium

### P2-09 Mobile chat uses 4-second polling instead of realtime delivery

- Priority: P2
- Location: `lib/features/chat/chat_detail_page.dart:86-90`
- Description: The screen refreshes messages and agreement status every four seconds.
- Why it is a problem: Polling is wasteful and increases latency and battery/network usage.
- Consequences: Worse UX and backend load.
- Recommended fix:
  - Introduce WebSocket/SSE-based updates.
  - Keep polling only as fallback.
- Complexity: Large

### P2-10 Chat screen still contains broken and hardcoded text

- Priority: P2
- Location: `lib/features/chat/chat_detail_page.dart:78-80`, `167`, `183`, `235`
- Description: Error and title strings still contain mojibake and are not localized.
- Why it is a problem: This directly affects a core feature.
- Consequences: Broken text in production UI.
- Recommended fix:
  - Move all user-facing chat strings into ARB files and normalize existing source text encoding.
- Complexity: Medium

## Verification audit

### P1-12 "Pending verifications" list includes users who never submitted verification

- Priority: P1
- Location: `backend/src/admin-verifications/admin-verifications.service.ts:37-43`
- Description: `getPendingVerifications()` includes both `PENDING` and `NONE`.
- Why it is a problem: Moderators see unsubmitted users as actionable verification requests.
- Consequences: Incorrect moderation queue, accidental approval risk.
- Recommended fix:
  - Restrict the list to `VerificationStatus.PENDING`.
- Complexity: Small

### P2-11 Verification service resets rejected users back to NONE on file re-upload

- Priority: P2
- Location: `backend/src/verification/verification.service.ts:28-32`, `59-63`, `88-92`, `119-123`
- Description: Re-uploading a file after rejection resets state to `NONE`.
- Why it is a problem: This weakens workflow traceability and makes moderation history less explicit.
- Consequences: Ambiguous state transitions for KYC.
- Recommended fix:
  - Introduce explicit `RESUBMITTED` or keep `REJECTED` until formal re-submit.
- Complexity: Medium

## Complaints and admin audit

### P2-12 Admin panel is functional but still contains hardcoded and broken text

- Priority: P2
- Location: `backend/admin-web/index.html`
- Description: The static admin panel still contains hardcoded Russian text and mojibake fragments.
- Why it is a problem: Admin tools are part of the product quality surface too.
- Consequences: Lower trust and harder operator onboarding.
- Recommended fix:
  - Normalize encoding and extract strings into a maintainable config or translation layer.
- Complexity: Medium

### P2-13 Admin panel is served from the same backend process and origin

- Priority: P2
- Location: `backend/src/main.ts:38-50`
- Description: The operational admin UI is served directly by the application backend.
- Why it is a problem: This increases coupling and attack surface.
- Consequences: One compromised surface affects both admin and public product runtime.
- Recommended fix:
  - Split admin frontend deployment or harden it behind separate origin/auth controls.
- Complexity: Medium

## Agreement audit

### P2-14 Payments/agreements are product-ready structurally but not financially production-ready

- Priority: P2
- Location: `backend/src/payments/payments.service.ts:29-44`, `134-165`
- Description: Agreement payment flows depend on mock cards and mock payment completion.
- Why it is a problem: The domain exists, but money movement is simulated only.
- Consequences: The feature should be presented as demo-grade, not released billing.
- Recommended fix:
  - Add real payment provider integration or hide payment execution from production UX until ready.
- Complexity: Large

## Flutter UX audit

### P2-15 Several profile menu items are visible but do nothing

- Priority: P2
- Location: `lib/features/profile/presentation/pages/profile_page.dart:259-281`
- Description: Notifications, privacy, security, support, and about menu items have titles and icons but no `onTap`.
- Why it is a problem: Tappable-looking UI elements that do nothing feel broken.
- Consequences: User frustration and incomplete product perception.
- Recommended fix:
  - Either wire real pages or temporarily hide unavailable options.
- Complexity: Small

### P2-16 No centralized navigation guard policy

- Priority: P2
- Location: `lib/app/app.dart:42-81`, `lib/features/roomie_splash_page.dart`
- Description: Routing relies on a static route map and splash-time branching instead of a centralized guard/router layer.
- Why it is a problem: As flows grow, access control becomes harder to reason about.
- Consequences: Risk of inconsistent navigation and accidental access to wrong screens.
- Recommended fix:
  - Add a single route guard strategy around auth/onboarding/verification state.
- Complexity: Medium

### P3-02 Main navigation is icon-only

- Priority: P3
- Location: `lib/features/main/main_shell.dart`
- Description: Bottom navigation uses icons without visible labels.
- Why it is a problem: It reduces clarity and accessibility, especially for new users.
- Consequences: Lower learnability.
- Recommended fix:
  - Add localized labels or stronger accessibility hints.
- Complexity: Small

### P3-03 Several screens still have overflow/deprecated-widget risk

- Priority: P3
- Location: `lib/features/home/presentation/pages/filter_page.dart:143-145`, `lib/features/people/ui/recommended_user_profile_page.dart:103-113`
- Description: `flutter analyze` still reports deprecated API usage and `use_build_context_synchronously` warnings.
- Why it is a problem: Today they are warnings, tomorrow they become breakage or subtle bugs.
- Consequences: Maintenance friction and avoidable runtime issues.
- Recommended fix:
  - Clear analyzer warnings before shipping.
- Complexity: Small

## Localization audit

### P1-13 Full bilingual coverage is not complete yet

- Priority: P1
- Location: multiple Flutter screens outside `lib/l10n`, including `lib/features/chat/chat_detail_page.dart`, `lib/features/home/presentation/pages/filter_page.dart`, `lib/features/people/ui/recommended_user_profile_page.dart`
- Description: Localization infrastructure exists, but many user-facing strings remain hardcoded or broken.
- Why it is a problem: The app now presents itself as bilingual, but coverage is inconsistent.
- Consequences: Mixed-language UI and broken text in critical flows.
- Recommended fix:
  - Finish string extraction screen by screen.
  - Ban direct UI strings in feature code.
- Complexity: Large

### P2-17 Broken mojibake text still exists in both backend and frontend

- Priority: P2
- Location: e.g. `lib/features/chat/chat_detail_page.dart:78-80`, `lib/features/profile/data/me_repository.dart:54`, `backend/src/chat/chat.service.ts:19`, `31`
- Description: Some source files still contain corrupted encoded strings.
- Why it is a problem: This is visible product damage and complicates maintenance.
- Consequences: Broken UX and lower credibility during demos.
- Recommended fix:
  - Normalize file encoding to UTF-8 and replace corrupted literals with localization keys.
- Complexity: Medium

## Performance audit

### P2-18 Backend lint/type safety posture is not yet strong enough for the current complexity

- Priority: P2
- Location: `backend/tsconfig.json:19-23`
- Description: `strictNullChecks` is enabled, but `noImplicitAny` is disabled and linting currently reports many unsafe patterns.
- Why it is a problem: For a system with auth, moderation, payments, and KYC, unsafe typing raises regression risk.
- Consequences: More runtime bugs and weaker refactor confidence.
- Recommended fix:
  - Tighten TypeScript compiler/lint settings gradually.
  - Burn down existing warnings module by module.
- Complexity: Large

### P3-04 Dio error interceptor prints raw failed request details

- Priority: P3
- Location: `lib/core/network/network_providers.dart:33-41`
- Description: Failed request URI/status/response are printed directly.
- Why it is a problem: Useful in dev, but noisy and risky in release diagnostics.
- Consequences: Log clutter and possible sensitive payload leakage.
- Recommended fix:
  - Wrap logging behind debug-only checks and structured error reporting.
- Complexity: Small

## Testing audit

### P1-14 Test coverage is far too small for the project scope

- Priority: P1
- Location: `test/widget_test.dart`, `test/dispute_models_decode_test.dart`, backend unit/e2e test folders
- Description: The repository contains only a handful of Flutter tests and very limited backend automated coverage.
- Why it is a problem: This codebase already includes auth, chat, AI search, moderation, agreements, and localization.
- Consequences: High regression risk for every change.
- Recommended fix:
  - Add tests first for auth, verification, disputes, matching, and route-state flows.
- Complexity: Large

### P2-19 Analyzer and linter are not clean

- Priority: P2
- Location: `analysis_options.yaml`, `backend` lint state
- Description: `flutter analyze` still emits multiple issues and backend lint currently has errors plus many warnings.
- Why it is a problem: Unclean static analysis becomes background noise and hides real regressions.
- Consequences: Quality gates lose value.
- Recommended fix:
  - Make lint/analyze clean and keep them required in CI.
- Complexity: Medium

## Production readiness

### P2-20 No CI/CD workflows detected

- Priority: P2
- Location: repository root and `backend/.github/workflows` not present
- Description: No automated validation pipeline was found.
- Why it is a problem: Builds, tests, and linting depend on manual discipline.
- Consequences: Broken code can land unnoticed.
- Recommended fix:
  - Add CI for Flutter analyze/test and backend lint/test/e2e.
- Complexity: Medium

### P2-21 Documentation is outdated relative to actual project scope

- Priority: P2
- Location: `README.md:3`, `pubspec.yaml:2`, `backend/README.md`
- Description: Root docs still say "A new Flutter project" and backend docs do not reflect current functionality.
- Why it is a problem: Misleading docs weaken onboarding and defense presentation quality.
- Consequences: Reviewers underestimate or misunderstand the system.
- Recommended fix:
  - Rewrite README to describe architecture, features, setup, and known limitations.
- Complexity: Small

### P3-05 No general platform health/readiness endpoint was identified

- Priority: P3
- Location: `backend/src/ai_search/ai.controller.ts:29-32`
- Description: A health endpoint exists only for the AI module.
- Why it is a problem: Production operations usually need broader readiness/liveness reporting.
- Consequences: Harder monitoring and deployment automation.
- Recommended fix:
  - Add `/health` and `/ready` endpoints covering DB and key dependencies.
- Complexity: Small

### P3-06 Docker runtime is minimal but lacks operational hardening

- Priority: P3
- Location: `backend/Dockerfile`, `backend/docker-compose.yml`
- Description: Container setup is serviceable, but no healthcheck, secret handling strategy, or environment hardening is visible.
- Why it is a problem: Good enough for local dev, weak for production.
- Consequences: Lower operational resilience.
- Recommended fix:
  - Add healthchecks, non-default creds, safer env injection, and environment profiles.
- Complexity: Medium

## Diploma defense readiness

Current defense positioning:

- Strong points:
  - Broad feature scope.
  - Real full-stack implementation.
  - Hybrid recommendation/search logic.
  - Agreements, disputes, moderation, and admin tooling give the project depth.
  - Flutter + NestJS + Prisma + Riverpod is a credible stack.

- Weak points:
  - Security maturity is below what a "ready marketplace" claim would require.
  - Localization is incomplete.
  - Some visible UI pieces are still placeholders.
  - Automated testing is too small for confident release claims.

Recommended defense phrasing:

- Call the recommendation system "hybrid roommate matching with AI-assisted semantic search".
- Present payments as demo-mode or simulated billing unless real acquiring is implemented.
- Present moderation/KYC as "implemented workflow requiring security hardening before production release".

## Recommended roadmap

Recommended order of work:

1. Security emergency fixes
   - Rotate secrets.
   - Remove `.env` from version control.
   - Close public KYC file exposure.
   - Restrict verification approval rules.

2. Auth and session hardening
   - Add rate limiting.
   - Neutralize account-enumeration messages.
   - Hash refresh tokens.
   - Introduce per-device sessions.

3. Product correctness fixes
   - Fix pending verification query.
   - Finish localization of all major flows.
   - Remove mojibake strings.
   - Hide or implement dead menu items.

4. Core platform improvements
   - Enforce direct-chat uniqueness.
   - Replace chat polling with realtime transport.
   - Separate mock payments from production behavior.

5. Quality and maintainability
   - Shrink giant services.
   - Clean lint/analyzer warnings.
   - Expand automated tests.
   - Add CI.

6. Architecture evolution
   - Split overloaded `User` model.
   - Add audit logs for moderation.
   - Improve docs and operational endpoints.

## Top 10 issues

1. P0: Committed secrets in `backend/.env`.
2. P0: Public access to KYC files through `/uploads`.
3. P0: Verification approval can bypass true pending-state validation.
4. P1: Auth/OTP flows leak account existence and account state.
5. P1: No visible rate limiting on public auth endpoints.
6. P1: Refresh tokens are stored raw in DB.
7. P1: Direct chat uniqueness is not enforced at schema level.
8. P1: Mock payment behavior is still part of core product flow.
9. P1: Localization is incomplete across many major screens.
10. P1: Automated test coverage is far too small for the project scope.
