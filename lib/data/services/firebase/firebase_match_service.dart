import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';
import 'package:tennis_cup/data/services/firebase/firebase_player_service.dart';

class FirebaseMatchService implements IMatchService {
  final FirebasePlayerService _playerService;

  FirebaseMatchService([FirebasePlayerService? playerService])
      : _playerService = playerService ?? FirebasePlayerService();

  @override
  Future<Match?> fetchMatchById(String id) async {
    final querySnapshot =
        await FirebaseFirestore.instance.collectionGroup('matches').get();

    for (final doc in querySnapshot.docs) {
      if (doc.id == id) return _matchFromDoc(doc);
    }
    return null;
  }

  @override
  Stream<void> watchMatchChanges(String matchId) {
    return FirebaseFirestore.instance
        .collectionGroup('matches')
        .snapshots()
        .map((_) => null);
  }

  Future<Match?> _matchFromDoc(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    Future<Player?> fetchPlayer(String id) async {
      try {
        return await _playerService.fetchPlayerById(id);
      } catch (_) {
        return null;
      }
    }

    final blue = await fetchPlayer(data['bluePlayer'] as String? ?? '');
    final red = await fetchPlayer(data['redPlayer'] as String? ?? '');
    if (blue == null || red == null) return null;

    final ts = data['dateTime'] as Timestamp?;

    return Match(
      matchId: doc.id,
      bluePlayer: blue,
      redPlayer: red,
      blueScore: (data['blueScore'] as num?)?.toInt() ?? 0,
      redScore: (data['redScore'] as num?)?.toInt() ?? 0,
      blueSetScores: List<int>.from(data['blueSetScores'] as List? ?? []),
      redSetScores: List<int>.from(data['redSetScores'] as List? ?? []),
      tournamentId: data['tournamentId'] as String? ?? '',
      dateTime: ts?.toDate() ?? DateTime.now(),
    );
  }
}
