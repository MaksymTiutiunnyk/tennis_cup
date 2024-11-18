import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/repositories/tournament_repository.dart';

final liveStreamAndUpcomingMatchesTournamentsProvider =
    FutureProvider((ref) async {
  return await TournamentRepository
      .fetchLiveStreamAndUpcomingMatchesTournaments();
});
