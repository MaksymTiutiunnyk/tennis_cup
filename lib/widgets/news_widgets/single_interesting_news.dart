import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                child: LayoutBuilder(builder: (context, constraints) {
                  return Image.network(
                    news.imageUrl,
                    width: double.infinity,
                    // height: constraints.maxHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/default_image.jpg',
                        width: double.infinity,
                        // height: 200,
                        fit: BoxFit.cover,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return SizedBox(
                        // height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatter.format(news.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(news.title),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
