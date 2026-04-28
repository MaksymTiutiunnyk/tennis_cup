import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/page_result.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';

class StubMatchService implements IMatchService {
  const StubMatchService();

  @override
  Future<Match?> fetchMatchById(String id) async => null;

  @override
  Stream<void> watchMatchChanges(String matchId) => const Stream.empty();

  @override
  Future<PageResult<Match>> fetchPlayersMatches(
      {required String playerId,
      String? player2Id,
      required PageRequest page}) async {
    return const PageResult(items: [], hasMore: false);
  }
}
