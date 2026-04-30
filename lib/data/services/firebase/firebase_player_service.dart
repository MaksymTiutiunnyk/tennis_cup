import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/page_result.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';

// Firebase uses cursor-based pagination, not page-number-based.
// This service tracks the last DocumentSnapshot internally and advances it
// on each call. Requesting page 0 resets the cursor (starts from the beginning).
class FirebasePlayerService implements IPlayerService {
  DocumentSnapshot? _rankingCursor;

  @override
  Future<PageResult<Player>> fetchRankingPlayers({
    required PageRequest page,
    Sex? sexFilter,
  }) async {
    if (page.page == 0) _rankingCursor = null;

    Query query = FirebaseFirestore.instance
        .collection('players')
        .orderBy('rank_tennis', descending: true)
        .limit(page.size);

    if (sexFilter != null && sexFilter != Sex.All) {
      query = query.where('sex', isEqualTo: sexFilter.name);
    }

    if (_rankingCursor != null) {
      query = query.startAfterDocument(_rankingCursor!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _rankingCursor = snapshot.docs.last;
    }

    final players = snapshot.docs
        .map((doc) => _playerFromDoc(doc))
        .whereType<Player>()
        .toList();

    return PageResult(
      items: players,
      hasMore: snapshot.docs.length == page.size,
    );
  }

  @override
  Future<List<Player>> searchPlayersByName({
    required String query,
    bool isSurname = false,
  }) async {
    final field = isSurname ? 'surname' : 'name';
    final snapshot = await FirebaseFirestore.instance
        .collection('players')
        .where(field, isGreaterThanOrEqualTo: query)
        .where(field, isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    return snapshot.docs
        .map((doc) => _playerFromDoc(doc))
        .whereType<Player>()
        .toList();
  }

  @override
  Future<Player> fetchPlayerById(String id) async {
    final doc =
        await FirebaseFirestore.instance.collection('players').doc(id).get();
    final player = _playerFromDoc(doc);
    if (player == null) throw Exception('Player $id not found');
    return player;
  }

  static Player? _playerFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    final sexStr = data['sex'] as String? ?? '';
    return Player(
      playerId: doc.id,
      name: data['name'] as String? ?? '',
      surname: data['surname'] as String? ?? '',
      sex: sexStr == 'Men'
          ? Sex.Men
          : sexStr == 'Women'
              ? Sex.Women
              : Sex.All,
      year: (data['year'] as num?)?.toInt() ?? 0,
      tournaments: (data['tournaments'] as num?)?.toInt() ?? 0,
      matches: (data['matches'] as num?)?.toInt() ?? 0,
      wins: (data['wins'] as num?)?.toInt() ?? 0,
      loses: (data['loses'] as num?)?.toInt() ?? 0,
      place: data['place'] as String? ?? '',
      gold: (data['gold'] as num?)?.toInt() ?? 0,
      silver: (data['silver'] as num?)?.toInt() ?? 0,
      bronze: (data['bronze'] as num?)?.toInt() ?? 0,
      rankTennis: (data['rank_tennis'] as num?)?.toDouble() ?? 0,
      rankUTTF: (data['rank_uttf'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }
}
