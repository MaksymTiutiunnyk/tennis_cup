import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/winners_tournaments_provider.dart';
import 'package:tennis_cup/widgets/home_widgets/winner.dart';

class Winners extends ConsumerWidget {
  const Winners({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Tournament>> asyncValue =
        ref.watch(winnersTournamentsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Tennis Cup: Winners',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 195,
            child: asyncValue.when(
              data: (tournaments) {
                if (tournaments.isEmpty) {
                  return const Center(child: Text('No winners found'));
                }
                return PageView.builder(
                  controller: PageController(viewportFraction: 0.90),
                  scrollDirection: Axis.horizontal,
                  itemCount: tournaments.length,
                  itemBuilder: (context, index) =>
                      Winner(tournament: tournaments[index]),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('error $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
