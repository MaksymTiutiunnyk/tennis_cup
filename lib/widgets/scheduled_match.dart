import 'package:flutter/material.dart';
import 'package:tennis_cup/model/match.dart';

class ScheduledMatch extends StatefulWidget {
  final Match match;
  const ScheduledMatch({super.key, required this.match});

  @override
  State<ScheduledMatch> createState() {
    return _ScheduledMatch();
  }
}

class _ScheduledMatch extends State<ScheduledMatch> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.match.getFormattedTime()),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.co_present_rounded)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.match.bluePlayer.surname +
                  widget.match.bluePlayer.name),
              Text(widget.match.blueScore.toString()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  widget.match.redPlayer.surname + widget.match.redPlayer.name),
              Text(widget.match.redScore.toString()),
            ],
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}