import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/news.dart';
import 'package:tennis_cup/providers/news_period_provider.dart';

final newsProvider = FutureProvider<List<News>>((ref) async {
  DateTime period = ref.watch(newsPeriodProvider);

  final newsCollection = FirebaseFirestore.instance.collection('news');

  QuerySnapshot querySnapshot = await newsCollection
      .where('date',
          isGreaterThanOrEqualTo: DateTime(period.year, period.month, 1))
      .where('date', isLessThan: DateTime(period.year, period.month + 1, 1))
      .orderBy('date', descending: true)
      .get();

  List<News> newsList = querySnapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return News(
        title: data['title'] == "" ? 'Attention!' : data['title'],
        text: data['text'],
        date: (data['date'] as Timestamp).toDate(),
        imageUrl: data['imageUrl']);
  }).toList();

  return newsList;
});
