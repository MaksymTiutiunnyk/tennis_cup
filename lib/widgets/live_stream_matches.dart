import 'package:flutter/material.dart';
import 'package:tennis_cup/widgets/live_stream_match.dart';

import '../data/matches.dart';

class LiveStreamMatches extends StatelessWidget {
  const LiveStreamMatches({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.live_tv,
                  color: Color.fromARGB(255, 1, 1, 98),
                ),
                SizedBox(width: 8),
                Text(
                  'Tennis Cup: Live stream',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.85),
              itemCount: 5,
              itemBuilder: (context, index) {
                return LiveStreamMatch(match: matches[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
