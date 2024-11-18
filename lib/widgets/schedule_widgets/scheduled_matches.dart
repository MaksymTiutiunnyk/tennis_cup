import 'package:flutter/material.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/widgets/schedule_widgets/scheduled_match.dart';

class ScheduledMatches extends StatelessWidget {
  const ScheduledMatches({super.key, required this.tournament});
  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: tournament.matches!
            .map((match) => ScheduledMatch(match: match))
            .toList(),
      ),
    );
  }
}
