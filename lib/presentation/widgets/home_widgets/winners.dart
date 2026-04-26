import 'package:flutter/material.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/presentation/widgets/home_widgets/winner.dart';

class Winners extends StatelessWidget {
  final bool isScreenWide;
  const Winners({super.key, this.isScreenWide = false});

  @override
  Widget build(BuildContext context) {
    final winnersTournaments =
        ServiceLocator.tournamentRepository.fetchWinnersTournaments();

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
                final tournaments = snapshot.data!
                    .where((t) =>
                        t.places.contains(1) && t.players.isNotEmpty)
                    .toList();
                if (tournaments.isEmpty) {
                  return const Center(child: Text('No winners found'));
                }
                return PageView.builder(
                  scrollDirection:
                      isScreenWide ? Axis.vertical : Axis.horizontal,
                  controller: PageController(viewportFraction: 0.90),
                  itemCount: tournaments.length,
                  itemBuilder: (context, index) {
                    return Winner(tournament: tournaments[index]);
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
