import 'package:cloud_firestore/cloud_firestore.dart';

class MatchApi {
  const MatchApi();

  Future<DocumentSnapshot?> fetchMatchById(String matchId) async {
    final querySnapshot =
        await FirebaseFirestore.instance.collectionGroup('matches').get();

    for (final doc in querySnapshot.docs) {
      if (doc.id == matchId) {
        return doc;
      }
    }

    return null;
  }

  Stream<DocumentSnapshot?> watchMatchChanges(String matchId) {
    return FirebaseFirestore.instance
        .collectionGroup('matches')
        .snapshots()
        .map((querySnapshot) {
      for (final doc in querySnapshot.docs) {
        if (doc.id == matchId) {
          return doc;
        }
      }
      return null;
    });
  }
}
