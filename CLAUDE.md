# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter run                        # Run the app
flutter build apk                  # Build Android APK
flutter build ios                  # Build iOS
flutter test                       # Run tests
flutter analyze                    # Static analysis
```

## Architecture

Flutter app following the [Flutter app architecture guide](https://docs.flutter.dev/app-architecture/guide): **Services** (API wrappers) → **Repositories** (domain model source of truth) → **Cubits/BLoC** (ViewModels) → **Widgets** (Views).

State management uses **BLoC/Cubit**. Backend is a set of REST microservices (no Firebase). Routing uses **go_router**.

```
RestService → Repository → Cubit/Bloc → UI Widget
```

### Folder structure

Feature-first layout grouped by access mode:

```
lib/
├── main.dart
├── config/                        # app-wide constants (base URLs etc.)
├── core/
│   ├── di/service_locator.dart    # wires all services; called before runApp
│   ├── network/                   # DioClient, AuthInterceptor
│   └── pagination/                # PageRequest, PageResult
├── data/
│   ├── auth/auth_token_store.dart
│   ├── models/                    # pure domain model classes
│   ├── repositories/              # assemble domain models from DTOs
│   └── services/
│       ├── abstract/              # interfaces (IPlayerService, etc.)
│       ├── dto/                   # raw API data transfer objects
│       └── rest/                  # REST implementations
├── routing/app_router.dart        # GoRouter config + AppRoutes constants
└── ui/
    ├── core/
    │   ├── themes/app_theme.dart
    │   └── widgets/               # ConnectionMonitor, CustomNavigatorObserver, PlayerAvatar
    ├── auth/                      # AuthCubit, LoginScreen, RegisterScreen, AuthGate
    ├── shell/widgets/             # ViewShell, UserShell (StatefulShellRoute builders)
    ├── settings/widgets/          # ModeSwitcher
    ├── view_only/                 # public screens, no login required
    │   ├── home/
    │   ├── schedule/
    │   ├── ranking/
    │   ├── news/
    │   ├── player_details/
    │   ├── player_comparison/
    │   └── player_search/
    └── user/                      # login-gated screens
        ├── core/                  # shared user widgets (ChangePassword, SettingsTab)
        ├── player/                # player invitations, tournaments tab
        ├── referee/               # placeholder
        └── organizer/             # placeholder
```

### Routing

`lib/routing/app_router.dart` defines all routes. `AppRoutes` holds path constants.

- **Two `StatefulShellRoute.indexedStack`**: one for view-only mode (`/view/*`), one for user mode (`/user/*`). Each wraps its tabs in a shell widget (`ViewShell` / `UserShell`) that provides the `AppBar` and `BottomNavigationBar`.
- **Top-level `GoRoute`s** for pushed screens (`/players/:id`, `/comparison/:p1Id/:p2Id`) — these render over the root Navigator so the bottom nav disappears.
- App mode is URL-driven: `/view/*` = view-only, `/user/*` = user mode. No cubit needed; `ModeSwitcher` reads `GoRouterState.of(context).matchedLocation`.
- Use `context.go()` to switch tabs or modes (replaces the stack). Use `context.push()` only for top-level pushed routes that need a back button. **Never `context.push()` a shell branch route** — it causes duplicate Navigator page keys.
- `UserShell` shows `AuthGate` inline when unauthenticated instead of redirecting, preserving the soft-auth UX.

### Dependency injection

`lib/core/di/service_locator.dart` wires all services and is called in `main.dart` before `runApp`. Repositories and cubits receive their dependencies via constructor injection — no cubit instantiates its own repository internally.

### State management conventions

- Use **Cubits** for simple state driven by filters or pagination
- Use **Blocs** only when multiple distinct event types drive the same state machine
- Cubits do **not** subscribe to other cubits internally. The widget tree drives re-fetches via `BlocListener` / `MultiBlocListener`, passing current filter states as explicit params to cubit methods
- Pagination uses `PageRequest(page, size)` / `PageResult<T>(items, hasMore)`
- **Prefer Cubits over `StatefulWidget`** for all UI state. Use `StatefulWidget` only when lifecycle hooks (`initState`, `dispose`, `didUpdateWidget`) or animation controllers are genuinely needed and cannot be lifted into a cubit
- **One widget per file** — every public widget class lives in its own dedicated `.dart` file

### Global providers

Provided at app root in `main.dart` (accessible to all routes including pushed screens):

- `AuthCubit` — session state
- `NewsCubit` — news feed
- `ScheduleDateCubit`, `ArenaFilterCubit`, `TimeFilterCubit` — schedule filters (must be global so pushed screens like PlayerDetails can update them)
- `SexFilterCubit` — ranking filter
- `VideoPlayerCubit`, `LiveStreamMatchIndexCubit` — YouTube live stream state

Any cubit needed by a pushed route (`/players/:id`, `/comparison/...`) **must** be at root level — pushed routes are siblings of the shells in the Navigator tree, not descendants, so shell-level providers are invisible to them.

### Data models

Models in `lib/data/models/` are pure data classes — no factory methods. Services parse API responses into DTOs (`lib/data/services/dto/`); repositories map DTOs to domain models via private static methods. Shared string→value helpers (e.g. `arenaColorFromString`, `timeFromString`) live as top-level functions in the relevant DTO file.

`Player` built from full REST responses has all stats fields populated. `Player` built from brief API responses (e.g. `PlayerBriefDto` used by the home dashboard) has stats fields zeroed (`year`, `wins`, `loses`, `gold`, `silver`, `bronze`, `rankTennis`, `rankUTTF` all `0`). Widgets that render stats should guard against zero values and show `–` when appropriate.

`Player.imageUrl` is `''` for REST-sourced players (no image API yet). Use `PlayerAvatar` widget instead of `FadeInImage.assetNetwork` directly — it guards against the empty URL.

`MatchView` and `WinnerView` (`lib/data/models/`) are lightweight view models for the home dashboard — they carry only what those widgets need and are mapped directly from the dashboard DTOs in `TournamentRepository`. They are not general-purpose replacements for `Tournament` or `Match`.

`Tournament.refereeId` is `int?` and is mapped from `TournamentDto.refereeId` (stored as `0` when absent in the DTO — the repository converts `0` → `null`). In the organizer tournament form, edit mode shows "Referee #ID" as a placeholder because the current API has no endpoint to look up a user's name by ID (`GET /api/v1/users/{id}` returns `login`/`status`/`roles` only, no name fields).

`AdminRepository.searchReferees` calls `GET /api/v1/admin/search` **without** a `roles` query param and filters to REFEREE client-side. The endpoint is ADMIN-only — if the logged-in user is ORGANIZER the call returns 403. If referee search needs to work for organizers, the backend must expose a new endpoint.

### Partially implemented features

All services are on REST. The following behaviours are still incomplete:

- Real-time updates — no auto-refresh (`watchMatchChanges` / `watchTournamentChanges` return `Stream.empty()`; manual pull-to-refresh only)
- Player stats: wins, losses, medals, rankUTTF, year, place — shows `–` (`hasDetailedStats = false` for REST-sourced players)
- Player avatars — shows default asset (`imageUrl` is always `''` from REST)
- News images are served from a local GCS-compatible storage emulator at `localhost:4443`. On Android emulator, `localhost` resolves to the emulator's own loopback — replace it with `10.0.2.2`. The `SingleInterestingNews` widget falls back to `default_image.jpg` on any load failure.

Home screen widgets (`LiveStreamMatches`, `UpcomingMatches`, `Winners`) use dedicated dashboard endpoints (`GET /api/v1/dashboard/arenas/current-matches`, `/dashboard/tournaments/upcoming-matches`, `/dashboard/arenas/last-winners`) that return pre-aggregated data. `TournamentRepository` maps these to `MatchView` / `WinnerView` and resolves arena color via `fetchArenaById`. Widgets fall back to "No matches found" / "No winners found" on empty results.

### HTTP client

`lib/core/network/dio_client.dart` creates one `Dio` instance per microservice. `lib/core/network/auth_interceptor.dart` uses `QueuedInterceptorsWrapper` to attach JWT tokens and handle token refresh (serialises concurrent 401 retries).

Service base URLs are configured via `lib/config/`:

```dart
// Override at build time: flutter run --dart-define=GATEWAY_URL=http://prod:8080
const gatewayUrl           = String.fromEnvironment('GATEWAY_URL',    defaultValue: 'http://localhost:8080');
const playerServiceUrl     = String.fromEnvironment('PLAYER_URL',     defaultValue: 'http://localhost:8082');
const tournamentServiceUrl = String.fromEnvironment('TOURNAMENT_URL', defaultValue: 'http://localhost:8084');
const arenaServiceUrl      = String.fromEnvironment('ARENA_URL',      defaultValue: 'http://localhost:8083');
const authServiceUrl       = String.fromEnvironment('AUTH_URL',       defaultValue: 'http://localhost:8081');
const matchServiceUrl      = String.fromEnvironment('MATCH_URL',      defaultValue: 'http://localhost:8085');
```

All `DioClient` instances in `ServiceLocator` currently use `gatewayUrl` as their base URL — every service call goes through the API gateway. The individual service URL constants exist for direct-to-service access if the gateway is bypassed.

### Auth

`lib/ui/auth/` — soft auth: browsing (rankings, schedule, news) works without login; user-mode screens require authentication.

- `AuthCubit` is provided at app root
- Auth does **not** hard-redirect — `UserShell` shows `AuthGate` inline when unauthenticated
- Registration creates PLAYER accounts only; new accounts are `PENDING_APPROVAL` until an admin approves them
- JWT tokens are stored in `flutter_secure_storage` via `AuthTokenStore`

### Connectivity

`ConnectionMonitor` wraps the app via `MaterialApp.router`'s `builder`. Because that context is above the Navigator, it uses a shared `GlobalKey<NavigatorState>` (created in `_TennisCupState`, passed to both `buildAppRouter` and `ConnectionMonitor`) to call `showModalBottomSheet` with a valid context.
