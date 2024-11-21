import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/custom_icons_icons.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/providers/player_tournaments_provider.dart';
import 'package:tennis_cup/screens/player_details.dart';

class PlayerIntro extends ConsumerWidget {
  final Player player;
  const PlayerIntro(this.player, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          ref.read(playerTournamentsProvider.notifier).reset();
          await ref
              .read(playerTournamentsProvider.notifier)
              .fetchTournaments(playerId: player.playerId);
          if (!context.mounted) {
            return;
          }
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => PlayerDetails(player: player)));
        },
        child: Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: player.imageUrl != ''
                      ? NetworkImage(player.imageUrl)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  player.fullName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CustomIcons.medal,
                      size: 16,
                      color: Colors.yellow.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(player.gold.toString()),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CustomIcons.medal,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(player.silver.toString()),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CustomIcons.medal,
                      size: 16,
                      color: Colors.yellow.shade900,
                    ),
                    const SizedBox(width: 4),
                    Text(player.bronze.toString()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
