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

State management uses **BLoC/Cubit**. Backend is a set of REST microservices. Firebase is initialized at runtime for Cloud Messaging (FCM) only — Firestore/Storage service implementations exist in `lib/data/services/firebase/` as legacy code but are not active. Routing uses **go_router**.

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
        ├── referee/               # referee tournaments + invitations tabs
        └── organizer/             # user management, tournament management, news
```

### Routing

`lib/routing/app_router.dart` defines all routes. `AppRoutes` holds path constants.

- **Two `StatefulShellRoute.indexedStack`**: one for view-only mode (`/view/*`), one for user mode (`/user/*`). Each wraps its tabs in a shell widget (`ViewShell` / `UserShell`) that provides the `AppBar` and `BottomNavigationBar`.
- **Top-level `GoRoute`s** for pushed screens (`/players/:id`, `/comparison/:p1Id/:p2Id`, `/organizer/create-user`, `/organizer/edit-user/:userId`) — these render over the root Navigator so the bottom nav disappears.
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
- `ActiveRoleCubit` — current user roles, synced from `AuthCubit` via `BlocListener`
- `NotificationCubit` — FCM token lifecycle; `init()` triggered on `AuthAuthenticated`, `unregisterDevice()` called before logout in `SettingsTab`
- `NewsCubit` — news feed
- `ScheduleDateCubit`, `ArenaFilterCubit`, `TimeFilterCubit` — schedule filters (must be global so pushed screens like PlayerDetails can update them)
- `SexFilterCubit` — ranking filter
- `VideoPlayerCubit`, `LiveStreamMatchIndexCubit` — YouTube live stream state

Any cubit needed by a pushed route (`/players/:id`, `/comparison/...`) **must** be at root level — pushed routes are siblings of the shells in the Navigator tree, not descendants, so shell-level providers are invisible to them.

### Data models

Models in `lib/data/models/` are pure data classes — no factory methods. Services parse API responses into DTOs (`lib/data/services/dto/`); repositories map DTOs to domain models via private static methods. Shared string→value helpers (e.g. `arenaColorFromString`, `timeFromString`) live as top-level functions in the relevant DTO file.

`Player` is always constructed from `GET /api/v1/users/{id}` via `_playerFromProfileJson` when full profile data is needed. It carries raw editable fields: `birthDate: String?` (ISO date), `city: String`, `country: String`, `patronymicName: String`. `year: int` and `place: String` are computed getters derived from these. `genderString: String?` returns `'MALE'`/`'FEMALE'`/`null` from the `Sex` enum.

Thin `Player` objects (built by `_playerFromRatingRecord` from the rating endpoint, or `_playerFromSearchResult` from the search endpoint) have zeroed stats and are used **only for list display** (ranking cards, search results). They are never passed as route extras. `PlayerDetailsRoute` and `PlayersComparisonRoute` always fetch fresh via `fetchPlayerById` — there is no cache optimisation. Widgets that render stats should guard against zero values and show `–` when appropriate.

`Player.imageUrl` is `''` for REST-sourced players (no image API yet). Use `PlayerAvatar` widget instead of `FadeInImage.assetNetwork` directly — it guards against the empty URL.

`MatchView` and `WinnerView` (`lib/data/models/`) are lightweight view models for the home dashboard — they carry only what those widgets need and are mapped directly from the dashboard DTOs in `TournamentRepository`. They are not general-purpose replacements for `Tournament` or `Match`.

`Tournament.refereeId` is `int?` and is mapped from `TournamentDto.refereeId` (stored as `0` when absent in the DTO — the repository converts `0` → `null`). In the organizer tournament form, edit mode shows "Referee #ID" as a placeholder because there is no convenient search-by-ID-to-name flow surfaced in the UI yet.

`AdminRepository.searchReferees` calls `GET /api/v1/users/search?roles=REFEREE`. `AdminRepository.searchAllUsers` calls `GET /api/v1/users/search` (no role filter). Both are accessible to ADMIN and ORGANIZER roles.

`CombinedUser` (`lib/data/models/combined_user.dart`) is the user model used in search results — carries `userId`, name, `avatarUrl`, and `roles: List<UserRole>`. `isDeletable` is true for organizers and admins. It is passed as a GoRouter route `extra` when navigating to `EditUserScreen` so the initial role set is available without an extra API call.

`PlayerRepository.updateProfile` calls `PATCH /api/v1/admin/users/{id}` (admin endpoint, works for any role). The same PATCH accepts a `roles` array to replace the user's role set (must have at least one role per API spec). Role updates are included in the same PATCH body as profile field changes — no separate endpoint exists.

`UserRegistrationFormBody` (`lib/ui/core/widgets/`) is a shared form widget used by `RegisterScreen` (self-registration), `CreateUserScreen` (admin creates user), and `EditUserScreen` (admin edits user). Edit mode is activated by passing `UserProfileInitialValues`; in edit mode the login/password/role fields are hidden and profile fields are pre-filled. The submit callback typedef makes `role`/`login`/`password` nullable — create callers use `role!`/`login!`/`password!`, edit callers ignore them.

`UsersSearchCubit` implements a soft-delete pattern: `softDelete` removes the item from the list and starts a 4-second commit timer. When `search()` or `refresh()` is called while a delete is pending, the timer is cancelled and the delete is committed immediately (fire-and-forget), and the pending user ID is filtered out of the fresh server results to handle the race. Commit failures restore the item to the list and set `deleteError: true` on the state (shown as a snackbar, not a full-screen error).

### Referee match conducting

`lib/ui/user/referee/` — referee's live scoring UI for an active match.

**State pattern**: every mutation (add point, issue card, finish set, etc.) calls the API and then `_reload()` (full `GET /matches/{id}`). There is no partial local-state patching. The only exception is the score undo stack, which is a client-side `List<({int blue, int red})>` maintained across reloads via `_reload({preserveUndoStack})`.

**Layout**: all match states use a 3-column `Row` — left player panel | center controls | right player panel. Side assignment:
- Odd sets: red on left, blue on right.
- Even sets: blue on left, red on right (sides swap).
- Set 5: extra swap when either player reaches 5 points in that set.
- `RefereeMatchReady.isDisplaySwapped(setNum, {blueScore, redScore})` encapsulates this rule.
- Between-sets view mirrors the just-finished set's side arrangement.
- Player column widgets use `ValueKey('player-${player.userId}')` (not position-based) so Flutter rebuilds correctly on swap.

**Cards**: `MatchCardDto` (in `match_dto.dart`) carries `id, matchId, playerId, cardType, issuedAt, setNumber?`. Card rules enforced client-side:
- WHITE and YELLOW: max 1 per player (`canIssueWhite`, `canIssueYellow` computed on `RefereeMatchReady`).
- RED: only available after the player already has a YELLOW (`canIssueRed`, `eligibleRedPlayers`).
- Issuing a WHITE card triggers a 1-minute `TimeoutOverlay` after the backend confirms.
- Tapping an issued card in the player column → revoke confirm → `cubit.revokeCard(card.id)`.

**Scoring lock**: `scoringLocked = setFinishable || matchFinishable`. When locked, score taps and all non-essential buttons (medical, tech pause, TD match, cards) are disabled; only undo and the finish button remain active.

**Timeout overlays** (`timeout_overlay.dart`): full-screen modal, tap anywhere to dismiss.
- Medical: red bg, 10-min countdown, auto-dismisses at 0.
- Tech pause: blue bg, counts up, never auto-dismisses.
- General (white card): amber bg, 1-min countdown, auto-dismisses at 0.

**Sets score display**: the center panel shows `leftSetsWon – rightSetsWon` (side-aware, not always blue–red). Between sets, the score shown reflects sets won *before* the just-finished set (the last set's result is revealed once the next set starts).

### Partially implemented features

All services are on REST. The following behaviours are still incomplete:

- Real-time updates — no auto-refresh (`watchMatchChanges` / `watchTournamentChanges` return `Stream.empty()`; manual pull-to-refresh only)
- Player ratings (`rankTennis`, `rankUTTF`) — always `0` in `PlayerDetails` because `GET /api/v1/users/{id}` does not include rating; only the rating-service endpoint (`GET /api/v1/ratings`) returns `ratingValue`, and that is used for ranking list display only
- Player avatars — `imageUrl` is always `''` for ranking/search results; `avatarUrl` is returned by `GET /api/v1/users/{id}` and stored in `Player.imageUrl`. Avatar upload (`PUT /api/v1/users/{id}/avatar`) and removal (send `avatarUrl: null` in profile PATCH) are implemented in `EditUserScreen` with deferred upload — bytes are held in cubit state and only sent to the server when the user taps Save.
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
- Self-registration (`/api/v1/auth/register`) creates PLAYER or REFEREE accounts; new accounts are `PENDING_APPROVAL` until an organizer/admin approves them
- Admin/organizer can create active accounts of any role directly via `POST /api/v1/admin/users` (`CreateUserScreen`)
- JWT tokens are stored in `flutter_secure_storage` via `AuthTokenStore`

### Push notifications (Android only)

`firebase_messaging` is active at runtime. Firebase is initialized in `main()` before `ServiceLocator.init()`. A top-level `_firebaseMessagingBackgroundHandler` is registered in `initState` — it must be a top-level function (FCM requirement).

**Token lifecycle** (`NotificationCubit` / `INotificationService` / `RestNotificationService`):
- `POST /api/v1/devices` — called on `AuthAuthenticated` and on every `onTokenRefresh` event
- `DELETE /api/v1/devices/{token}` — called in `SettingsTab._confirmLogout` *before* `AuthCubit.logout()`, while the JWT is still valid
- Android-only guard: `if (!Platform.isAndroid) return;` at the top of `init()`

**Notification handling** (wired in `_TennisCupState._setupNotificationHandlers`):
- `onMessage` (foreground) → snackbar via `ScaffoldMessenger.of(_navigatorKey.currentContext!)` with a "View" action for `TOURNAMENT_INVITATION`
- `onMessageOpenedApp` (background tap) → `_router.go(AppRoutes.userInvitations)`
- `getInitialMessage()` (cold-start tap) → same routing, guarded with `mounted` check

**Notification routing**: `data.type == 'TOURNAMENT_INVITATION'` navigates to `AppRoutes.userInvitations`. Add new types to `_handleNotificationTap` in `main.dart`.

### Connectivity

`ConnectionMonitor` wraps the app via `MaterialApp.router`'s `builder`. Because that context is above the Navigator, it uses a shared `GlobalKey<NavigatorState>` (created in `_TennisCupState`, passed to both `buildAppRouter` and `ConnectionMonitor`) to call `showModalBottomSheet` with a valid context.
