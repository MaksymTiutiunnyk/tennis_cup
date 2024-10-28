import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
              children: const [
                LiveStreamMatch(),
              ],
              shrinkWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
