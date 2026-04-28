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

State management uses **BLoC/Cubit**. Backend is a set of REST microservices (no Firebase).

```
RestService → Repository → Cubit/Bloc → UI Widget
```

### Layer responsibilities

- `lib/data/services/abstract/` — abstract interfaces (`IPlayerService`, `ITournamentService`, `IArenaService`, `IMatchService`, `INewsService`)
- `lib/data/services/dto/` — raw API data transfer objects (`TournamentDto`, `ArenaDto`); services return DTOs, never domain models
- `lib/data/services/rest/` — REST implementations of those interfaces; stub implementations for features not yet backed by a REST API
- `lib/data/repositories/` — assembles domain models from DTOs (may call multiple services), owns pagination state
- `lib/logic/cubit/` — 28+ cubits for UI state (filters, pagination, feature state)
- `lib/logic/bloc/` — `PlayerSearchBloc` for name/surname search
- `lib/presentation/screens/` — 6 screens: Home, Schedule, Ranking, News, Player Details, Player Comparison
- `lib/presentation/widgets/` — widgets grouped by screen (`ranking_widgets/`, `home_widgets/`, etc.)

### Dependency injection

`lib/core/di/service_locator.dart` wires all services and is called in `main.dart` before `runApp`. Repositories and cubits receive their dependencies via constructor injection — no cubit instantiates its own repository internally.

### State management conventions

- Use **Cubits** for simple state driven by filters or pagination
- Use **Blocs** only when multiple distinct event types drive the same state machine
- Cubits do **not** subscribe to other cubits internally. The widget tree drives re-fetches via `BlocListener` / `MultiBlocListener`, passing current filter states as explicit params to cubit methods
- Pagination uses `PageRequest(page, size)` / `PageResult<T>(items, hasMore)` — no Firebase cursor types anywhere above the service layer
- **Prefer Cubits over `StatefulWidget`** for all UI state. Use `StatefulWidget` only when lifecycle hooks (`initState`, `dispose`, `didUpdateWidget`) or animation controllers are genuinely needed and cannot be lifted into a cubit
- **One widget per file** — every public widget class lives in its own dedicated `.dart` file

### Data models

Models in `lib/data/models/` are pure data classes — no factory methods. Services parse API responses into DTOs (`lib/data/services/dto/`); repositories map DTOs to domain models via private static methods. Shared string→value helpers (e.g. `arenaColorFromString`, `timeFromString`) live as top-level functions in the relevant DTO file.

`Player` has a `hasDetailedStats` flag (`false` for REST-sourced players). Widgets check this before rendering stats fields (wins/losses/medals/rankUTTF) and show `–` when false.

### Features without REST API yet

`StubMatchService` and `StubNewsService` return empty data; affected UI falls back gracefully:
- News screen — shows empty state (no news API)
- Match detail / scores — not shown (no match API; `StubMatchService.fetchMatchById` returns `null`)
- Real-time updates — no auto-refresh (`watchTournamentChanges` / `watchMatchChanges` return `Stream.empty()`; manual pull-to-refresh only)
- Player stats: wins, losses, medals, rankUTTF, year, place — shows `–` (not in player/ratings API; `hasDetailedStats = false`)

Home screen widgets (`LiveStreamMatches`, `UpcomingMatches`, `Winners`) fetch real tournament data from the REST API. They fall back to "No matches found" / "No winners found" when `tournament.matches` is `null` (match detail not loaded by the tournament endpoint) or `tournament.players`/`places` are empty.

### HTTP client

`lib/core/network/dio_client.dart` creates one `Dio` instance per microservice. `lib/core/network/auth_interceptor.dart` uses `QueuedInterceptorsWrapper` to attach JWT tokens and handle token refresh (serialises concurrent 401 retries).

Service base URLs are configured via `lib/core/config.dart`:

```dart
// Override at build time: flutter run --dart-define=PLAYER_URL=http://prod:8082
const playerServiceUrl    = String.fromEnvironment('PLAYER_URL',     defaultValue: 'http://localhost:8082');
const tournamentServiceUrl = String.fromEnvironment('TOURNAMENT_URL', defaultValue: 'http://localhost:8084');
const arenaServiceUrl     = String.fromEnvironment('ARENA_URL',      defaultValue: 'http://localhost:8083');
const authServiceUrl      = String.fromEnvironment('AUTH_URL',       defaultValue: 'http://localhost:8081');
```

### Auth feature

`lib/features/auth/` — soft auth: browsing (rankings, schedule, news) works without login; player-specific actions require authentication.

- `AuthCubit` is provided at app root alongside `NewsCubit`
- Auth does **not** gate the main app content — the cubit only tracks session state
- Registration creates PLAYER accounts only (referees have a separate app); new accounts are `PENDING_APPROVAL` until an admin approves them
- JWT tokens are stored in `flutter_secure_storage` via `AuthTokenStore`

### Global providers

`NewsCubit` and `AuthCubit` are provided at the app root in `main.dart`. All other cubits/blocs are provided at screen level.

### Connectivity

`ConnectionMonitor` widget (wraps the whole app) watches `connectivity_plus` and shows a banner when offline.

### macOS

Minimum deployment target is **10.15** (set in `macos/Podfile` and `macos/Runner.xcodeproj/project.pbxproj`). Firebase SDK 11 requires 10.15; the default Flutter-generated target of 10.14 will not build.
