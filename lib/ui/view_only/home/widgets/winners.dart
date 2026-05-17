import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/arena_winner.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/winners_cubit.dart';
import 'package:tennis_cup/ui/view_only/home/widgets/winner.dart';

class Winners extends StatelessWidget {
  final bool isScreenWide;
  const Winners({super.key, this.isScreenWide = false});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
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
                s.winnersTitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        SizedBox(
          height: isScreenWide ? 220 : 190,
          child: BlocBuilder<WinnersCubit, WinnersState>(
            builder: (context, state) => switch (state) {
              WinnersLoading() =>
                const Center(child: CircularProgressIndicator()),
              WinnersError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ),
              WinnersLoaded(:final winners) => _buildContent(context, winners),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List<ArenaWinner> winners) {
    if (winners.isEmpty) {
      return Center(child: Text(S.of(context).noWinnersFound));
    }
    return PageView.builder(
      scrollDirection: isScreenWide ? Axis.vertical : Axis.horizontal,
      controller: PageController(viewportFraction: 0.90),
      itemCount: winners.length,
      itemBuilder: (context, index) {
        return Winner(view: winners[index]);
      },
    );
  }
}
