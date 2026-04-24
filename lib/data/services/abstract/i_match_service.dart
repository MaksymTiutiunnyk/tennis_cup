import 'package:tennis_cup/data/models/match.dart';

abstract interface class IMatchService {
  Future<Match?> fetchMatchById(String id);
  Stream<void> watchMatchChanges(String matchId);
}
