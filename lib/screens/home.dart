import 'package:flutter/material.dart';
import 'package:tennis_cup/widgets/home_widgets/live_stream_matches.dart';
import 'package:tennis_cup/widgets/home_widgets/upcoming_matches.dart';
import 'package:tennis_cup/widgets/home_widgets/winners.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 800 && constraints.maxHeight >= 500) {
            return const Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: LiveStreamMatches(isWideScreen: true)),
                    Expanded(child: Winners(isWideScreen: true))
                  ],
                ),
                UpcomingMatches()
              ],
            );
          }
          if (constraints.maxHeight >= 650) {
            return const Column(
              children: [
                LiveStreamMatches(),
                UpcomingMatches(),
                Winners(),
              ],
            );
          }
          return const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LiveStreamMatches(),
                Winners(),
                UpcomingMatches(isScrollable: false),
              ],
            ),
          );
        },
      ),
    );
  }
}
