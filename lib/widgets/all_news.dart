import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/news.dart';
import 'package:tennis_cup/widgets/single_news.dart';

DateFormat formatter = DateFormat('MMMM yyyy');

class AllNews extends StatefulWidget {
  const AllNews({super.key});

  @override
  State<AllNews> createState() {
    return _AllNewsState();
  }
}

class _AllNewsState extends State<AllNews> {
  String period = formatter.format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 8, 0, 2),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(width: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                Text(period),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward_ios)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: news.length,
              itemBuilder: (ctx, index) {
                return SingleNews(news: news[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
