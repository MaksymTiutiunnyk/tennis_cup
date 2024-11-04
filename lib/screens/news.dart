import 'package:flutter/material.dart';
import 'package:tennis_cup/widgets/all_news.dart';
import 'package:tennis_cup/widgets/interesting_news.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() {
    return _NewsState();
  }
}

class _NewsState extends State<News> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        InterestingNews(),
        AllNews(),
      ],
    );
  }
}
