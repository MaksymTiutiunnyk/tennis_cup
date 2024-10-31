import 'package:flutter/material.dart';
import 'package:tennis_cup/model/arena.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/widgets/scheduled_match.dart';
import 'package:tennis_cup/model/match.dart';

class ScheduledMatches extends StatelessWidget {
  ScheduledMatches({super.key});

  final List<ScheduledMatch> scheduledMatches = [
    ScheduledMatch(
    match: Match(
      bluePlayer: Player(name: 'Andrii', surname: 'Kurtenko'),
      redPlayer: Player(name: 'Vitalii', surname: 'Mukhin'),
      arena: Arena(title: 'Africa', color: Colors.black),
    ),
  ),
  ScheduledMatch(
    match: Match(
      bluePlayer: Player(name: 'Andrii', surname: 'Kurtenko'),
      redPlayer: Player(name: 'Vitalii', surname: 'Mukhin'),
      arena: Arena(title: 'Africa', color: Colors.black),
    ),
  ),
  ScheduledMatch(
    match: Match(
      bluePlayer: Player(name: 'Andrii', surname: 'Kurtenko'),
      redPlayer: Player(name: 'Vitalii', surname: 'Mukhin'),
      arena: Arena(title: 'Africa', color: Colors.black),
    ),
  ),
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(child: ListView(children: scheduledMatches,));
  }
  
}