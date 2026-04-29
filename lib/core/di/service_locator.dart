// To switch to Firebase, replace the REST service instantiations in init()
// with their Firebase counterparts, e.g.:
//   playerService = FirebasePlayerService();
//   tournamentService = FirebaseTournamentService();
//   arenaService = FirebaseArenaService();
//   matchService = FirebaseMatchService();
//   newsService = FirebaseNewsService();
// Also call Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
// in main.dart before ServiceLocator.init().
// Firebase service implementations live in lib/data/services/firebase/.

import 'package:dio/dio.dart';
import 'package:tennis_cup/core/config.dart';
import 'package:tennis_cup/core/network/dio_client.dart';
import 'package:tennis_cup/data/repositories/arena_repository.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';
import 'package:tennis_cup/data/repositories/news_repository.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';
import 'package:tennis_cup/data/services/abstract/i_news_service.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/rest/rest_arena_service.dart';
import 'package:tennis_cup/data/services/rest/rest_player_service.dart';
import 'package:tennis_cup/data/services/rest/rest_tournament_service.dart';
import 'package:tennis_cup/data/services/rest/rest_match_service.dart';
import 'package:tennis_cup/data/services/rest/stub_news_service.dart';
import 'package:tennis_cup/features/auth/data/auth_token_store.dart';
import 'package:tennis_cup/features/auth/data/rest_auth_service.dart';

class ServiceLocator {
  static late AuthTokenStore tokenStore;
  static late RestAuthService authService;
  static late IPlayerService playerService;
  static late ITournamentService tournamentService;
  static late IArenaService arenaService;
  static late IMatchService matchService;
  static late INewsService newsService;

  static late PlayerRepository playerRepository;
  static late TournamentRepository tournamentRepository;
  static late ArenaRepository arenaRepository;
  static late MatchRepository matchRepository;
  static late NewsRepository newsRepository;

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
    matchService = RestMatchService(matchDio);
    newsService = const StubNewsService();

    playerRepository = PlayerRepository(playerService);
    tournamentRepository = TournamentRepository(tournamentService, arenaService, playerService, matchService);
    matchRepository = MatchRepository(matchService, playerService);
    newsRepository = NewsRepository(newsService);
  }
}
