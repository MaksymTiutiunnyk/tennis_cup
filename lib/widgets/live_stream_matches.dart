import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tennis_cup/model/arena.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/widgets/live_stream_match.dart';

class LiveStreamMatches extends StatelessWidget {
  const LiveStreamMatches({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const Text('Tennis Cup live stream'),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
