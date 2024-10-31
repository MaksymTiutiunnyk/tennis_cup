import 'package:flutter/material.dart';
import 'package:tennis_cup/data/matches.dart';
import 'package:tennis_cup/data/tournaments.dart';
import 'package:tennis_cup/screens/tabs.dart';

void main() {
  runApp(const TennisCup());
}

class TennisCup extends StatelessWidget {
  const TennisCup({super.key});

  @override
  Widget build(BuildContext context) {
    tournaments[0].matches = matches.take(15).toList(); // костиль

    return MaterialApp(
      title: 'Tennis Cup',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const Tabs(),
    );
  }
}
