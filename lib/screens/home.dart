import 'package:flutter/material.dart';

import 'package:tennis_cup/widgets/home_widgets/live_stream_matches.dart';
import 'package:tennis_cup/widgets/home_widgets/upcoming_matches.dart';
import 'package:tennis_cup/widgets/home_widgets/winners.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          LiveStreamMatches(),
          UpcomingMatches(),
          Winners(),
        ],
      ),
    );
  }
}
