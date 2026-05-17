import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/core/widgets/player_avatar.dart';

class RankingPlayer extends StatelessWidget {
  final User player;
  const RankingPlayer({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return InkWell(
      onTap: () => context.push(
        AppRoutes.playerDetails(player.id.toString()),
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
                    '${player.lastName} ${player.firstName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.labelTennisCupRank,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    player.rating.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.tournaments,
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
                    s.labelCityCountry,
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
                    s.labelYearOfBirth,
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
