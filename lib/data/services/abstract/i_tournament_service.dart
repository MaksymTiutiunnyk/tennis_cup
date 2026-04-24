import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/page_result.dart';
import 'package:tennis_cup/data/models/tournament.dart';

abstract interface class ITournamentService {
  Future<PageResult<Tournament>> fetchPlayerTournaments({
    required String playerId,
    String? player2Id,
    required PageRequest page,
  });

  Future<Tournament> fetchTournamentById(String id);

  Future<List<Tournament>> fetchScheduledTournaments({
    required DateTime date,
    required Arena arena,
    required Time time,
  });

  Future<List<Tournament>> fetchRecentTournaments({int limit = 10});

  Future<List<Tournament>> fetchUpcomingTournaments({int limit = 10});

  Stream<void> watchTournamentChanges(String tournamentId);
}
