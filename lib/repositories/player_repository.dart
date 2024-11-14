import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/model/player.dart';

class PlayerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchPlayers({
    required int limit,
    DocumentSnapshot? startAfter,
    Sex? sexFilter,
  }) async {
    Query query =
        _firestore.collection('players').orderBy('rank_tennis').limit(limit);

    if (sexFilter != null && sexFilter != Sex.All) {
      query = query.where('sex', isEqualTo: sexFilter.toString());
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.get();
    final players = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Player(
        id: data['id'],
        bronze: data['bronze'],
        gold: data['gold'],
        name: data['name'],
        surname: data['surname'],
        imageUrl: data['imageUrl'],
        loses: data['loses'],
        matches: data['matches'],
        place: data['place'],
        rankTennis: data['rank_tennis'],
        rankUTTF: data['rank_uttf'],
        silver: data['silver'],
        tournaments: data['tournaments'],
        wins: data['wins'],
        year: data['year'],
        sex: Sex.values.firstWhere((value) => value.name == data['sex']),
      );
    }).toList();

    return {
      'players': players,
      'lastDocument':
          querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
    };
  }
}
