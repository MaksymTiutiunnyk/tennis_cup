import 'package:flutter/material.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/widgets/schedule_widgets/scheduled_match.dart';

class ScheduledMatches extends StatelessWidget {
  final bool isScrollable;
  const ScheduledMatches({
    super.key,
    required this.tournament,
    this.isScrollable = true,
  });
  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: ListView.builder(
        shrinkWrap: true,
        physics: isScrollable ? null : const NeverScrollableScrollPhysics(),
        itemCount: tournament.matches!.length,
        itemBuilder: (context, index) =>
            ScheduledMatch(match: tournament.matches![index]),
      ),
    );
  }
}
