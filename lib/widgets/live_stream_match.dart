import 'package:flutter/material.dart';
import 'package:tennis_cup/model/match.dart';

class LiveStreamMatch extends StatelessWidget {
  const LiveStreamMatch({super.key, required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, color: match.tournament.arena.color, size: 8),
                  const SizedBox(width: 8),
                  Text(
                    "Arena: ${match.tournament.arena.title}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Row(
                children: [
                  Icon(Icons.video_library, color: Colors.red),
                  SizedBox(width: 8),
                  Text("38'", style: TextStyle(color: Colors.red)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text("2023-12-31. Men. Evening",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          buildPlayerRow(
              "assets/kurtenko_andrii.png",
              "${match.bluePlayer.surname} ${match.bluePlayer.name}",
              match.blueScore),
          const SizedBox(height: 8),
          buildPlayerRow(
              "assets/mukhin_vitalii.png",
              "${match.redPlayer.surname} ${match.redPlayer.name}",
              match.redScore),
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
            Text(name, style: const TextStyle(fontSize: 16)),
          ],
        ),
        Text(
          score.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
