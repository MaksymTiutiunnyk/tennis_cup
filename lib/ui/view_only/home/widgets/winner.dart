import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/data/models/arena_winner.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/core/widgets/player_avatar.dart';

final _formatter = DateFormat('yyyy-MM-dd');

String _formatGender(String gender) =>
    gender.toLowerCase() == 'female' ? 'Women' : 'Men';

class Winner extends StatelessWidget {
  final ArenaWinner view;
  const Winner({super.key, required this.view});

  @override
  Widget build(BuildContext context) {
    final User winner = view.winners.first;

    return InkWell(
      onTap: () => context.push(
        AppRoutes.playerDetails(winner.id.toString()),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Column(
          children: [
            PlayerAvatar(imageUrl: winner.imageUrl, radius: 40),
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
                  '${_formatGender(view.tournamentGender)}, ${view.tournamentTime.name}',
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
                  Text(view.arenaName,
                      style: Theme.of(context).textTheme.bodySmall!),
                  Text(_formatter.format(view.tournamentStart),
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
