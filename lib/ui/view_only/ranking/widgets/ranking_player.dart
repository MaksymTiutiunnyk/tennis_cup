import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/core/widgets/player_avatar.dart';

class RankingPlayer extends StatelessWidget {
  final Player player;
  const RankingPlayer({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(
        AppRoutes.playerDetails(player.userId.toString()),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  PlayerAvatar(imageUrl: player.imageUrl, radius: 20),
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
