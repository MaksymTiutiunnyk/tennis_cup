import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';

class StubMatchService implements IMatchService {
  const StubMatchService();

  @override
  Future<Match?> fetchMatchById(String id) async => null;

  @override
  Stream<void> watchMatchChanges(String matchId) => Stream.empty();
}
