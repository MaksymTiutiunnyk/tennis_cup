import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/data_providers/tournament_api.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';
import 'package:tennis_cup/presentation/widgets/home_widgets/winner.dart';

class Winners extends ConsumerWidget {
  final tournamentRepository =
      const TournamentRepository(tournamentApi: TournamentApi());

  final bool isScreenWide;
  const Winners({super.key, this.isScreenWide = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final winnersTournaments = tournamentRepository.fetchWinnersTournaments();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
          height: isScreenWide ? 220 : 190,
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
                  scrollDirection:
                      isScreenWide ? Axis.vertical : Axis.horizontal,
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
    );
  }
}
