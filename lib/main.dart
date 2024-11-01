import 'package:flutter/material.dart';
import 'package:tennis_cup/data/matches.dart';
import 'package:tennis_cup/data/tournaments.dart';
import 'package:tennis_cup/screens/tabs.dart';

ColorScheme kcolorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 4, 5, 100),
);

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
      theme: ThemeData().copyWith(
        colorScheme: kcolorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kcolorScheme.onBackground,
          foregroundColor: kcolorScheme.background,
        ),
        iconTheme: const IconThemeData()
            .copyWith(color: kcolorScheme.onPrimaryContainer),
        iconButtonTheme: IconButtonThemeData(
          style: const ButtonStyle()
              .copyWith(visualDensity: VisualDensity.compact),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
          type: BottomNavigationBarType.fixed,
          backgroundColor: kcolorScheme.onSecondary,
        ),
      ),
      home: const Tabs(),
    );
  }
}
