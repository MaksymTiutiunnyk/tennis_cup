import 'package:cloud_firestore/cloud_firestore.dart';

class NewsApi {
  const NewsApi();
  
  Future<QuerySnapshot> fetchNewsWithinPeriod(DateTime period) async {
    final newsCollection = FirebaseFirestore.instance.collection('news');

    QuerySnapshot querySnapshot = await newsCollection
        .where('date',
            isGreaterThanOrEqualTo: DateTime(period.year, period.month, 1))
        .where('date', isLessThan: DateTime(period.year, period.month + 1, 1))
        .orderBy('date', descending: true)
        .get();

    return querySnapshot;
  }

  Future<QuerySnapshot> fetchInterestingNews() async {
    final newsCollection = FirebaseFirestore.instance.collection('news');

    QuerySnapshot querySnapshot = await newsCollection
        .where('title', isNotEqualTo: 'Attention!')
        .limit(10)
        .get();

    return querySnapshot;
  }
}
