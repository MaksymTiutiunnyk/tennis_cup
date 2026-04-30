import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/winners_cubit.dart';
import 'package:tennis_cup/ui/view_only/home/widgets/winner.dart';

class Winners extends StatelessWidget {
  final bool isScreenWide;
  const Winners({super.key, this.isScreenWide = false});

  @override
  Widget build(BuildContext context) {
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
          child: BlocBuilder<WinnersCubit, WinnersState>(
            builder: (context, state) => switch (state) {
              WinnersLoading() =>
                const Center(child: CircularProgressIndicator()),
              WinnersError() =>
                const Center(child: Text('Ooops, something went wrong')),
              WinnersLoaded(:final tournaments) => _buildContent(tournaments),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContent(List<Tournament> tournaments) {
    final filtered = tournaments
        .where((t) => t.places.contains(1) && t.players.isNotEmpty)
        .toList();
    if (filtered.isEmpty) {
      return const Center(child: Text('No winners found'));
    }
    return PageView.builder(
      scrollDirection: isScreenWide ? Axis.vertical : Axis.horizontal,
      controller: PageController(viewportFraction: 0.90),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return Winner(tournament: filtered[index]);
      },
    );
  }
}
