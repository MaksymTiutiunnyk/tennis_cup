import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/page_result.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';

class FirebaseMatchService implements IMatchService {
  const FirebaseMatchService();

  @override
  Future<MatchDto?> fetchMatchById(String id) async {
    throw UnimplementedError('FirebaseMatchService is deprecated; use RestMatchService.');
  }

  @override
  Stream<void> watchMatchChanges(String matchId) {
    return FirebaseFirestore.instance
        .collectionGroup('matches')
        .snapshots()
        .map((_) {});
  }

  @override
  Future<List<MatchDto>> fetchTournamentMatches(String tournamentId) async {
    throw UnimplementedError('FirebaseMatchService is deprecated; use RestMatchService.');
  }

  @override
  Future<PageResult<MatchDto>> fetchPlayersMatches({
    required String playerId,
    String? player2Id,
    required PageRequest page,
  }) {
    throw UnimplementedError('FirebaseMatchService is deprecated; use RestMatchService.');
  }
}
