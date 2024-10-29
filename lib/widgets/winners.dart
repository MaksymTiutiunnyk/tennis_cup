import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/widgets/winner.dart';

class Winners extends StatelessWidget {
  const Winners({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Winners',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.85),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Winner(
                player: Player(name: 'Andrii', surname: 'Kurtenko'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
