import 'package:flutter/material.dart';
import 'package:tennis_cup/model/news.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class SingleInterestingNews extends StatelessWidget {
  final News news;
  const SingleInterestingNews({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: NetworkImage(news.imageUrl),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
            child: Text(
              formatter.format(news.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(news.title),
          ),
        ],
      ),
    );
  }
}
