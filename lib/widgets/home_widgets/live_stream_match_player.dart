import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/providers/player_tournaments_provider.dart';
import 'package:tennis_cup/screens/player_details.dart';

class LiveStreamMatchPlayer extends ConsumerWidget {
  final Player player;
  final int score;

  const LiveStreamMatchPlayer(
      {required this.player, required this.score, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        ref.read(playerTournamentsProvider.notifier).reset();
        await ref
            .read(playerTournamentsProvider.notifier)
            .fetchTournaments(playerId: player.id);
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => PlayerDetails(player: player)));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: player.imageUrl != ''
                    ? NetworkImage(player.imageUrl)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                player.fullName,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.white),
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
      ),
    );
  }
}
