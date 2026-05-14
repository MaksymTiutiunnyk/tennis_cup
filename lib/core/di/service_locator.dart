import 'package:dio/dio.dart';
import 'package:tennis_cup/config/app_config.dart';
import 'package:tennis_cup/core/network/dio_client.dart';
import 'package:tennis_cup/data/repositories/admin_repository.dart';
import 'package:tennis_cup/data/repositories/arena_repository.dart';
import 'package:tennis_cup/data/repositories/invitations_repository.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';
import 'package:tennis_cup/data/repositories/news_repository.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';
import 'package:tennis_cup/data/repositories/referee_repository.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';
import 'package:tennis_cup/data/services/abstract/i_admin_service.dart';
import 'package:tennis_cup/data/services/abstract/i_notification_service.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';
import 'package:tennis_cup/data/services/abstract/i_news_service.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/rest/rest_admin_service.dart';
import 'package:tennis_cup/data/services/rest/rest_notification_service.dart';
import 'package:tennis_cup/data/services/rest/rest_arena_service.dart';
import 'package:tennis_cup/data/services/rest/rest_player_service.dart';
import 'package:tennis_cup/data/services/rest/rest_tournament_service.dart';
import 'package:tennis_cup/data/services/rest/rest_match_service.dart';
import 'package:tennis_cup/data/services/rest/rest_news_service.dart';
import 'package:tennis_cup/data/services/websocket/match_websocket_service.dart';
import 'package:tennis_cup/data/auth/auth_token_store.dart';
import 'package:tennis_cup/data/services/rest/rest_auth_service.dart';

class ServiceLocator {
  static late AuthTokenStore tokenStore;
  static late RestAuthService authService;
  static late IPlayerService playerService;
  static late ITournamentService tournamentService;
  static late IArenaService arenaService;
  static late IMatchService matchService;
  static late INewsService newsService;
  static late IAdminService adminService;
  static late INotificationService notificationService;

  static late PlayerRepository playerRepository;
  static late TournamentRepository tournamentRepository;
  static late ArenaRepository arenaRepository;
  static late MatchRepository matchRepository;
  static late NewsRepository newsRepository;
  static late InvitationsRepository invitationsRepository;
  static late AdminRepository adminRepository;
  static late RefereeRepository refereeRepository;

  static void init() {
    tokenStore = const AuthTokenStore();

    final authDio = Dio(BaseOptions(
      baseUrl: gatewayUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    authService = RestAuthService(dio: authDio, tokenStore: tokenStore);

    final playerDio = DioClient.create(
      baseUrl: gatewayUrl,
      tokenStore: tokenStore,
      refreshToken: authService.refreshAccessToken,
    );
    final tournamentDio = DioClient.create(
      baseUrl: gatewayUrl,
      tokenStore: tokenStore,
      refreshToken: authService.refreshAccessToken,
    );
    final arenaDio = DioClient.create(
      baseUrl: gatewayUrl,
      tokenStore: tokenStore,
      refreshToken: authService.refreshAccessToken,
    );

    arenaService = RestArenaService(arenaDio);
    arenaRepository = ArenaRepository(arenaService);

    playerService = RestPlayerService(playerDio);
    tournamentService = RestTournamentService(tournamentDio);
    final matchDio = DioClient.create(
      baseUrl: gatewayUrl,
      tokenStore: tokenStore,
      refreshToken: authService.refreshAccessToken,
    );
    final matchWsService = MatchWebSocketService();
    matchService = RestMatchService(matchDio, matchWsService);
    final newsDio = DioClient.create(
      baseUrl: gatewayUrl,
      tokenStore: tokenStore,
      refreshToken: authService.refreshAccessToken,
    );
    newsService = RestNewsService(newsDio);

    final adminDio = DioClient.create(
      baseUrl: gatewayUrl,
      tokenStore: tokenStore,
      refreshToken: authService.refreshAccessToken,
    );
    adminService = RestAdminService(adminDio);

    final notificationDio = DioClient.create(
      baseUrl: gatewayUrl,
      tokenStore: tokenStore,
      refreshToken: authService.refreshAccessToken,
    );
    notificationService = RestNotificationService(notificationDio);

    playerRepository = PlayerRepository(playerService);
    tournamentRepository = TournamentRepository(tournamentService, arenaService, playerService, matchService);
    matchRepository = MatchRepository(matchService, playerService);
    newsRepository = NewsRepository(newsService);
    invitationsRepository =
        InvitationsRepository(tournamentService, arenaService);
    adminRepository = AdminRepository(adminService);
    refereeRepository =
        RefereeRepository(tournamentService, matchService, playerService);

    matchWsService.connect();
  }
}
