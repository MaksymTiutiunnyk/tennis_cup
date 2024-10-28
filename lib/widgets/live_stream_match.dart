import 'package:flutter/material.dart';

class LiveStreamMatch extends StatelessWidget {
  const LiveStreamMatch({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, color: Colors.red, size: 8),
                  SizedBox(width: 8),
                  Text("Arena: Africa", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.video_library, color: Colors.red),
                  SizedBox(width: 8),
                  Text("38'", style: TextStyle(color: Colors.red)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text("2023-12-31. Men. Evening (Finished)", style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 16),
          buildPlayerRow("assets/kurtenko_andrii.png", "Kurtenko Andrii", 3),
          const SizedBox(height: 8),
          buildPlayerRow("assets/mukhin_vitalii.png", "Mukhin Vitalii", 0),
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
        Text(score.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
