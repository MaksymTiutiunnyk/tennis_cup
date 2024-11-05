import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/screens/players_comparison.dart';
import 'package:tennis_cup/widgets/player_search.dart';

class PlayerDetails extends StatelessWidget {
  final Player player;
  const PlayerDetails({super.key, required this.player});

  void comparePlayers(BuildContext context, Player player) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PlayersComparison(
        player1: this.player,
        player2: player,
      ),
    ));
  }

  void showSearchField(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => PlayerSearch(onSelectPlayer: comparePlayers),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/kurtenko_andrii.png'),
            ),
            Text(player.fullName),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rank Tennis Cup:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        (35.6).toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rank UTTF:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        (35.6).toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tournaments:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        1.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Divider(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'City, Country:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Kyiv, Ukraine',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Year of birth:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        1995.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Wins:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        300.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.green),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Loses:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        231.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const CircleAvatar(
              radius: 30,
              child: Text('VS'),
            ),
            ElevatedButton(
              onPressed: () {
                showSearchField(context);
              },
              child: const Text('Participant to compare'),
            ),
            const Row(
              children: [
                Icon(Icons.emoji_events),
                Text('Tournaments'),
              ],
            )
          ],
        ),
      ),
    );
  }
}
