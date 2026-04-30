import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/data/services/abstract/i_news_service.dart';

class FirebaseNewsService implements INewsService {
  const FirebaseNewsService();

  @override
  Future<List<News>> fetchNewsWithinPeriod(DateTime start, DateTime end) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('news')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map(_newsFromDoc).whereType<News>().toList();
  }

  @override
  Future<List<News>> fetchInterestingNews() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('news')
        .where('title', isNotEqualTo: 'Attention!')
        .limit(10)
        .get();

    return snapshot.docs.map(_newsFromDoc).whereType<News>().toList();
  }

  static News? _newsFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    final ts = data['date'] as Timestamp?;

    return News(
      title: data['title'] as String? ?? 'Attention!',
      text: data['text'] as String? ?? '',
      date: ts?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }
}
