import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tennis_cup/main.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:intl/intl.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class LiveStreamMatch extends StatelessWidget {
  const LiveStreamMatch({super.key, required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          border: Border.all(color: kcolorScheme.onPrimaryContainer)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.circle,
                                color: match.tournament.arena.color, size: 8),
                            const SizedBox(width: 8),
                            Text(
                              'Arena: ${match.tournament.arena.title}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${formatter.format(match.dateTime)} Men, ${match.tournament.time.name}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const Column(
                      children: [
                        Icon(Icons.video_library, color: Colors.red),
                        SizedBox(width: 8),
                        Text("38'", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kcolorScheme.onPrimaryContainer),
              child: Column(
                children: [
                  buildPlayerRow(
                    "assets/kurtenko_andrii.png",
                    '${match.bluePlayer.surname} ${match.bluePlayer.name}',
                    match.blueScore,
                  ),
                  const SizedBox(height: 8),
                  buildPlayerRow(
                    "assets/mukhin_vitalii.png",
                    '${match.redPlayer.surname} ${match.redPlayer.name}',
                    match.redScore,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlayerRow(String imagePath, String name, int score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(imagePath),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
