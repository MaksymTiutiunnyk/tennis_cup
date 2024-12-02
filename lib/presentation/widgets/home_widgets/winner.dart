import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/presentation/screens/player_details.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class Winner extends StatelessWidget {
  final Tournament tournament;
  const Winner({super.key, required this.tournament});

  Player _defineWinner() {
    return tournament
        .players[tournament.places.indexWhere((place) => place == 1)];
  }

  @override
  Widget build(BuildContext context) {
    final winner = _defineWinner();

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => PlayerDetails(player: winner)));
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              child: ClipOval(
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/default_avatar.jpg',
                  image: winner.imageUrl,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) =>
                      Image.asset(
                    'assets/default_avatar.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              winner.fullName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${winner.sex.name}, ${tournament.time.name}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tournament.arena.title,
                      style: Theme.of(context).textTheme.bodySmall!),
                  Text(formatter.format(tournament.date),
                      style: Theme.of(context).textTheme.bodySmall!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
