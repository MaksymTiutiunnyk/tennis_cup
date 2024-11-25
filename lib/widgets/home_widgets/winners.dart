import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/repositories/tournament_repository.dart';
import 'package:tennis_cup/widgets/home_widgets/winner.dart';

class Winners extends ConsumerWidget {
  const Winners({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final winnersTournaments = TournamentRepository.fetchWinnersTournaments();

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
            child: FutureBuilder(
              future: winnersTournaments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return const Center(child: Text('No winners found'));
                  }
                  return PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: PageController(viewportFraction: 0.90),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Winner(
                        tournament: snapshot.data![index],
                      );
                    },
                  );
                }
                return const Center(child: Text('Ooops, something went wrong'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
