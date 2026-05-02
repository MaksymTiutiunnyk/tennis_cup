import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/services/abstract/i_news_service.dart';
import 'package:tennis_cup/data/services/dto/news_dto.dart';

class FirebaseNewsService implements INewsService {
  const FirebaseNewsService();

  @override
  Future<List<NewsDto>> fetchNewsWithinPeriod(DateTime start, DateTime end) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('news')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map(_dtofromDoc).whereType<NewsDto>().toList();
  }

  @override
  Future<List<NewsDto>> fetchInterestingNews() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('news')
        .where('importance', isEqualTo: 'INTERESTING')
        .limit(10)
        .get();

    return snapshot.docs.map(_dtofromDoc).whereType<NewsDto>().toList();
  }

  static NewsDto? _dtofromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    final ts = data['date'] as Timestamp?;

    return NewsDto(
      id: doc.id.hashCode,
      title: data['title'] as String? ?? '',
      body: data['text'] as String? ?? '',
      newsTimestamp: ts?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'] as String?,
      importance: data['importance'] as String? ?? 'REGULAR',
    );
  }
}
