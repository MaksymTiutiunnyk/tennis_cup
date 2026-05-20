import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/data/auth/auth_token_store.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/tournament_request.dart';
import 'package:tennis_cup/data/repositories/admin_repository.dart';
import 'package:tennis_cup/data/repositories/arena_repository.dart';
import 'package:tennis_cup/data/repositories/invitations_repository.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';
import 'package:tennis_cup/data/repositories/news_repository.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';
import 'package:tennis_cup/data/services/abstract/i_admin_service.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';
import 'package:tennis_cup/data/services/abstract/i_news_service.dart';
import 'package:tennis_cup/data/services/abstract/i_notification_service.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/dto/admin_dto.dart';
import 'package:tennis_cup/data/services/rest/rest_auth_service.dart';
import 'package:tennis_cup/data/services/websocket/match_websocket_service.dart';

// ---- Infrastructure ----

class MockDio extends Mock implements Dio {}

class MockAuthTokenStore extends Mock implements AuthTokenStore {}

// ---- WebSocket ----

class MockMatchWebSocketService extends Mock implements MatchWebSocketService {}

// ---- Abstract services ----

class MockIMatchService extends Mock implements IMatchService {}

class MockIPlayerService extends Mock implements IPlayerService {}

class MockINewsService extends Mock implements INewsService {}

class MockIAdminService extends Mock implements IAdminService {}

class MockIArenaService extends Mock implements IArenaService {}

class MockITournamentService extends Mock implements ITournamentService {}

class MockINotificationService extends Mock implements INotificationService {}

// ---- Repositories ----

class MockMatchRepository extends Mock implements MatchRepository {}

class MockNewsRepository extends Mock implements NewsRepository {}

class MockPlayerRepository extends Mock implements PlayerRepository {}

class MockTournamentRepository extends Mock implements TournamentRepository {}

class MockArenaRepository extends Mock implements ArenaRepository {}

class MockAdminRepository extends Mock implements AdminRepository {}

class MockInvitationsRepository extends Mock implements InvitationsRepository {}

// ---- Concrete services ----

class MockRestAuthService extends Mock implements RestAuthService {}

// ---- Fallback values ----

Future<void> registerFallbackValues() async {
  // Initialize localization so any code path that touches S.current
  // (e.g. errorMessage in cubits) doesn't trip the _current != null assert.
  await S.load(const Locale('en'));
  // Initialize intl date locale data so DateFormat(...) constructors don't
  // throw `LocaleDataException` in non-Flutter test contexts.
  await initializeDateFormatting();

  registerFallbackValue(Options());
  registerFallbackValue(RequestOptions(path: ''));
  registerFallbackValue(const PageRequest(page: 0, size: 10));
  registerFallbackValue(<int>{});
  registerFallbackValue(const CreateUserRequestDto(
    role: '',
    login: '',
    password: '',
    firstName: '',
    lastName: '',
  ));
  registerFallbackValue(const Arena(id: '1', title: 'Arena', color: ArenaColor.red));
  registerFallbackValue(Time.Morning);
  registerFallbackValue(CreateUpdateTournamentRequest(
    name: '',
    type: '',
    gender: '',
    startTime: DateTime.utc(2024),
    arenaId: 1,
    refereeIds: [],
    matchDurationMinutes: 0,
    requiredPlayersCount: 0,
    setsToWin: 1,
    playerIds: [],
  ));
}
