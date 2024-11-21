import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/providers/player_tournaments_provider.dart';
import 'package:tennis_cup/screens/player_details.dart';

class RankingPlayer extends ConsumerWidget {
  final Player player;
  const RankingPlayer({super.key, required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        ref.read(playerTournamentsProvider.notifier).reset();
        await ref
            .read(playerTournamentsProvider.notifier)
            .fetchTournaments(playerId: player.playerId);
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => PlayerDetails(player: player)));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
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
                    '${player.surname} ${player.name}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rank Tennis Cup:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    player.rankTennis.toString(),
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
                    player.rankUTTF.toString(),
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
                    player.tournaments.toString(),
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
                    player.place,
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
                    player.year.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
