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
              const Text('time'),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.co_present_rounded)),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('name1'),
              Text('score1'),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('name2'),
              Text('score2'),
            ],
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
