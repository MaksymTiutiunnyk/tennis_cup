import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/news.dart';

final interestingNewsProvider = FutureProvider<List<News>>((ref) async {
  final newsCollection = FirebaseFirestore.instance.collection('news');

  QuerySnapshot querySnapshot = await newsCollection
      .where('title', isNotEqualTo: 'Attention!')
      .limit(10)
      .get();

  List<News> interestingNews = querySnapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return News(
      title: data['title'] == "" ? 'Attention!' : data['title'],
      text: data['text'],
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
    );
  }).toList();

  return interestingNews;
});
