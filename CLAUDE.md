# CLAUDE.md

## Architecture

`RestService / WebSocketService → Repository → Cubit/Bloc → Widget`

- **Services** return DTOs only. **Repositories** map DTOs to domain models — no factory methods on models, no DTOs leaking past the repository boundary.
- **DI**: `service_locator.dart` wires everything before `runApp`. Dependencies injected via constructors — no cubit creates its own repository.

## Routing

`go_router` with two `StatefulShellRoute.indexedStack`: `/view/*` (ViewShell, public) and `/user/*` (UserShell, login-gated). Top-level `GoRoute`s for pushed screens (bottom nav hidden). `UserShell` shows `AuthGate` inline — no hard redirect.

- `context.go()` for tab/mode switches; `context.push()` for pushed routes only. **Never push a shell branch route** — causes duplicate Navigator page keys.
- Pushed routes are siblings of shells in the Navigator tree, not descendants — any cubit they need **must** be provided at app root.

## Auth and roles

Soft auth — view-only screens work without login. Roles: `PLAYER`, `REFEREE`, `ORGANIZER`, `ADMIN`. `ActiveRoleCubit` is synced from `AuthCubit` via `BlocListener` at app root and reflects the current user's roles. Self-registration creates `PLAYER`/`REFEREE` accounts in `PENDING_APPROVAL` state; organizers/admins create active accounts of any role directly.

## Real-time updates

STOMP WebSocket at `ws://localhost:8080/ws`, topic `/topic/matches/{matchId}`. `MatchRepository.watchMatchChanges(id)` returns `Stream<Match>` (DTO never leaves the repo). `LiveMatchCubit` accepts `initialMatch` to skip the initial REST fetch. Consumers: `LiveStreamMatch`, `ScheduledMatch`, `PlayersMatch`, `TournamentResults`. Tournament-level WebSocket (`watchTournamentChanges`) is not yet implemented.

## Push notifications (Android only)

`firebase_messaging` is guarded by `defaultTargetPlatform == TargetPlatform.android` — no-op on iOS. FCM background handler must be a top-level function (FCM requirement).

- Token registered (`POST /devices`) on `AuthAuthenticated` and `onTokenRefresh`.
- Token **deleted before** `AuthCubit.logout()` while the JWT is still valid.
- `TOURNAMENT_INVITATION` data type → navigates to `AppRoutes.userInvitations`. Add new types in `_handleNotificationTap` in `main.dart`.

## State management

- Cubits for simple state; Blocs only for multi-event state machines.
- **Cubits never subscribe to other cubits.** Re-fetches are driven by `BlocListener` in the widget tree, passing filter state as explicit params to cubit methods.
- Prefer Cubits over `StatefulWidget`. Use `StatefulWidget` only when lifecycle hooks or animation controllers are genuinely needed.
- One widget per file.

### Picker widgets

`PlayerPicker` / `RefereePicker` hold no state themselves. The owning form creates `PlayerPickerCubit` / `RefereePickerCubit` in `initState`, closes in `dispose`, and provides them via `MultiBlocProvider`. Pickers read the cubit from context in their own `initState`.

### Forms

**Never wrap `Form` in `ListView`** — `FormField`s that scroll out of viewport unregister from `FormState`, so `validate()` silently skips them. Use `SingleChildScrollView` + `Column`. All forms use `autovalidateMode: AutovalidateMode.onUserInteraction`.

## Data models

- `enumFromString` / `enumFromStringOrNull` in `lib/core/utils/enum_utils.dart` — normalises API strings (`'TECHNICAL_DEFEAT'` → matches `technicalDefeat`). Use everywhere instead of switch/map. String→enum helpers (`arenaColorFromString`, `timeFromString`, `genderFromString`) live in their model files, not DTO files.
- **`User`** is the single model for all roles and search results. Thin objects (from search/rating endpoints) have zeroed stats — guard with `–` in widgets. `User.imageUrl` is `''` when absent — always use `PlayerAvatar`, never `FadeInImage.assetNetwork` directly.
- **`Match`** scores (`blueScore`, `redScore`, `blueSetScores`, `redSetScores`) are computed getters derived from sets, not stored fields.
- **`fetchHeadToHead` workaround**: the endpoint returns no set statuses. `MatchRepository` derives set winners client-side (TT rule: 11+ points with 2+ lead). `// TODO: remove when backend is fixed`.
- **`MatchView` / `WinnerView`**: dashboard-only lightweight view models. Not general-purpose Match/Tournament replacements.
- `UsersSearchCubit` soft-delete: removes item immediately, commits after 4 s. Mid-flight `search()`/`refresh()` cancels the timer, commits immediately, and filters the deleted ID from fresh results. Failure restores the item and sets `deleteError: true` on state.

## Referee match conducting

- **`TournamentMatchesCubit`**: loads and sorts matches for a tournament (active → pending → done, then by `scheduledStart`). Owned by `TournamentManagementScreen`.
- **Mutation pattern**: every mutation calls the API then `_reload()` (full `GET /matches/{id}`). No local-state patching. Exception: the undo stack is client-side and preserved across reloads via `_reload({preserveUndoStack: true})`.
- **Side assignment**: odd sets — red left / blue right; even sets — swap; set 5 — extra swap at 5 pts. `RefereeMatchReady.isDisplaySwapped(setNum, {blueScore, redScore})`. Player columns keyed by `ValueKey('player-${player.id}')`, not position.
- **Scoring lock**: `scoringLocked = setFinishable || matchFinishable` — disables score taps, TD, cards; only undo + finish remain.
- **Sets score display**: center panel shows side-aware `leftSetsWon – rightSetsWon`. Score reveals the just-finished set's result only when the next set starts.

## Testing

Stack: `mocktail` + `bloc_test`. Always call `setUpAll(registerFallbackValues)`.

- **Auto-loading cubits**: stall the constructor in `setUp` with `Completer<T>().future` so it never completes. Re-stub inside `act:` for load tests — avoids `skip:` timing ambiguity.
- **Optimistic-mutation tests**: use `seed:` to set starting state; the stalled constructor never interferes.
- **Guard tests** (wrong state → no-op): stub the repo method anyway — mocktail throws `MissingStubError` otherwise, which the cubit catches and emits error state instead of nothing.
- `widget_test.dart` at root fails (Firebase init) — always run `flutter test test/data test/ui`.

## Partially implemented

- **WebSocket**: STOMP live match updates via `MatchRepository.watchMatchChanges` → `Stream<Match>`. `LiveMatchCubit` accepts `initialMatch` to skip the initial REST fetch. Tournament-level WebSocket not implemented.
- **Ratings**: only the ratings endpoint returns `ratingValue`; the user profile endpoint does not — `User.rating` is `0` in `PlayerDetails`.
- **Avatars**: `imageUrl` is `''` for search/rating results; populated from the profile endpoint. Upload/removal in `EditUserScreen` with deferred bytes (sent only on Save).
