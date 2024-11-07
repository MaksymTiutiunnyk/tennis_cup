import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/main.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/providers/arena_filter_provider.dart';
import 'package:tennis_cup/providers/schedule_date_provider.dart';
import 'package:tennis_cup/providers/tab_index_provider.dart';
import 'package:tennis_cup/providers/time_filter_provider.dart';
import 'package:tennis_cup/screens/player_details.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class LiveStreamMatch extends ConsumerWidget {
  final Match match;

  const LiveStreamMatch({super.key, required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: kcolorScheme.onPrimaryContainer),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      onTap: () {
                        ref
                            .read(scheduleDateProvider.notifier)
                            .selectDate(match.tournament.date);
                        ref
                            .read(timeFilterProvider.notifier)
                            .selectTime(match.tournament.time);
                        ref
                            .read(arenaFilterProvider.notifier)
                            .selectArena(match.tournament.arena);
                        ref.read(tabIndexProvider.notifier).selectTab(1);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.circle,
                                  color: match.tournament.arena.color, size: 8),
                              const SizedBox(width: 8),
                              Text(
                                'Arena: ${match.tournament.arena.title}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Text(
                            '${formatter.format(match.dateTime)} Men, ${match.tournament.time.name}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.video_library, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          "38'",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: kcolorScheme.onPrimaryContainer),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildPlayerRow(
                    context,
                    "assets/kurtenko_andrii.png",
                    match.bluePlayer,
                    match.blueScore,
                  ),
                  const SizedBox(height: 8),
                  buildPlayerRow(
                    context,
                    "assets/mukhin_vitalii.png",
                    match.redPlayer,
                    match.redScore,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlayerRow(
    BuildContext context,
    String imagePath,
    Player player,
    int score,
  ) {
    return InkWell(
      onTap: () {
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
                backgroundImage: AssetImage(imagePath),
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
