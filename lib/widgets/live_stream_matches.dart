import 'package:flutter/material.dart';
import 'package:tennis_cup/model/arena.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/widgets/live_stream_match.dart';

List<LiveStreamMatch> matches = [
  LiveStreamMatch(
    match: Match(
      bluePlayer: Player(name: 'Andrii', surname: 'Kurtenko'),
      redPlayer: Player(name: 'Vitalii', surname: 'Mukhin'),
      arena: Arena(title: 'Africa', color: Colors.black),
    ),
  ),
  LiveStreamMatch(
    match: Match(
      bluePlayer: Player(name: 'Andrii', surname: 'Kurtenko'),
      redPlayer: Player(name: 'Vitalii', surname: 'Mukhin'),
      arena: Arena(title: 'Africa', color: Colors.black),
    ),
  ),
  LiveStreamMatch(
    match: Match(
      bluePlayer: Player(name: 'Andrii', surname: 'Kurtenko'),
      redPlayer: Player(name: 'Vitalii', surname: 'Mukhin'),
      arena: Arena(title: 'Africa', color: Colors.black),
    ),
  ),
];

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
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return matches[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}
