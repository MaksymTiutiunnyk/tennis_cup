import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/widgets/winner.dart';

class Winners extends StatelessWidget {
  const Winners({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const Text('Winners'),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                Winner(player: Player(name: 'Andrii', surname: 'Kurtenko')),
                Winner(player: Player(name: 'Andrii', surname: 'Kurtenko')),
                Winner(player: Player(name: 'Andrii', surname: 'Kurtenko')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
