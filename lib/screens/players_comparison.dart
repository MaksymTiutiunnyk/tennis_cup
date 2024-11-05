import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';

class PlayersComparison extends StatelessWidget {
  final Player player1, player2;
  const PlayersComparison(
      {super.key, required this.player1, required this.player2});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tennis Cup: Players comparison'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              AssetImage('assets/kurtenko_andrii.png'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          player2.fullName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Text(30.toString()),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Text(20.toString()),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Text(17.toString()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      const CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            AssetImage('assets/kurtenko_andrii.png'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        player1.fullName,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Text('Rank Tennis Cup:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Color.fromARGB(255, 31, 148, 148),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_outlined,
                        color: Colors.white,
                      ),
                      Text(
                        (30.3).toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container()
              ],
            )
          ],
        ),
      ),
    );
  }
}
