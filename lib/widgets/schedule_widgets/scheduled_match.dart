import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:tennis_cup/providers/player_tournaments_provider.dart';
import 'package:tennis_cup/providers/players_tournaments_provider.dart';
import 'package:tennis_cup/screens/player_details.dart';
import 'package:tennis_cup/screens/players_comparison.dart';

DateFormat formatter = DateFormat('HH:mm');

class ScheduledMatch extends ConsumerWidget {
  final Match match;
  const ScheduledMatch({super.key, required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatter.format(match.dateTime),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  IconButton(
                    onPressed: () async {
                      ref.read(playersTournamentsProvider.notifier).reset();
                      await ref
                          .read(playersTournamentsProvider.notifier)
                          .fetchTournaments(
                            player1Id: match.bluePlayer.playerId,
                            player2Id: match.redPlayer.playerId,
                          );
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => PlayersComparison(
                            player1: match.bluePlayer,
                            player2: match.redPlayer,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      ref.read(playerTournamentsProvider.notifier).reset();
                      await ref
                          .read(playerTournamentsProvider.notifier)
                          .fetchTournaments(playerId: match.bluePlayer.playerId);
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) =>
                              PlayerDetails(player: match.bluePlayer)));
                    },
                    child: Text(
                      match.bluePlayer.fullName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      match.blueScore.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      ref.read(playerTournamentsProvider.notifier).reset();
                      await ref
                          .read(playerTournamentsProvider.notifier)
                          .fetchTournaments(playerId: match.redPlayer.playerId);
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) =>
                              PlayerDetails(player: match.redPlayer)));
                    },
                    child: Text(
                      match.redPlayer.fullName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      match.redScore.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 2),
      ],
    );
  }
}
