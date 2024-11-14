import 'package:flutter/material.dart';
import 'package:tennis_cup/widgets/home_widgets/live_stream_match.dart';
import 'package:tennis_cup/data/matches.dart';

class LiveStreamMatches extends StatelessWidget {
  const LiveStreamMatches({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.live_tv),
              const SizedBox(width: 8),
              Text(
                'Tennis Cup: Live stream',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 170,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: PageController(viewportFraction: 0.90),
            itemCount: 5,
            itemBuilder: (context, index) {
              return LiveStreamMatch(match: matches[index]);
            },
          ),
        ),
      ],
    );
  }
}
