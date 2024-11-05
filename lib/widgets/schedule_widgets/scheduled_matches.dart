import 'package:flutter/material.dart';
import 'package:tennis_cup/data/matches.dart';
import 'package:tennis_cup/widgets/schedule_widgets/scheduled_match.dart';

class ScheduledMatches extends StatelessWidget {
  const ScheduledMatches({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: matches.map((match) => ScheduledMatch(match: match)).toList(),
      ),
    );
  }
}
