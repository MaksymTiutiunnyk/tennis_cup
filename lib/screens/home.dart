import 'package:flutter/material.dart';

import 'package:tennis_cup/widgets/live_stream_matches.dart';
import 'package:tennis_cup/widgets/upcoming_matches.dart';
import 'package:tennis_cup/widgets/winners.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  final String title = 'Tennis Cup: Home page';

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

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
