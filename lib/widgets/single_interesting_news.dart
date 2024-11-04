import 'package:flutter/material.dart';
import 'package:tennis_cup/model/news.dart';
import 'package:intl/intl.dart';

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
            child: Image.network(
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                'https://tabletennis.setkacup.com/api/Image/news/1024x597/aHR0cHM6Ly9iZXRlci1zdHJhcGktaW1hZ2VzLXByb2QuczMuZXUtY2VudHJhbC0xLmFtYXpvbmF3cy5jb20vZGVhZl90ZW5uaXNfc2l0ZV9jMTcwMGY1OWZhLnBuZw=='),
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
