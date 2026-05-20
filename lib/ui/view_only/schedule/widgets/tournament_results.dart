import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/live_tournament_results_cubit.dart';

class TournamentResults extends StatelessWidget {
  final Tournament tournament;
  const TournamentResults(this.tournament, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LiveTournamentResultsCubit(
        initial: tournament,
        matchRepository: ServiceLocator.matchRepository,
      ),
      child: BlocBuilder<LiveTournamentResultsCubit, Tournament>(
        builder: (context, live) => _TournamentResultsBody(live),
      ),
    );
  }
}

class _TournamentResultsBody extends StatelessWidget {
  final Tournament tournament;
  const _TournamentResultsBody(this.tournament);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16.0, 0, 0),
          child: Row(
            children: [
              const Icon(Icons.table_chart_outlined),
              const SizedBox(width: 8),
              Text(
                s.tournamentResults,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(width: 0.1),
            columns: [
              DataColumn(
                label: Text(
                  s.labelName,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              for (int i = 1; i <= tournament.players.length; ++i)
                DataColumn(
                  label: Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          i.toString(),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              DataColumn(
                label: Text(
                  s.labelPoints,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              DataColumn(
                label: Text(
                  s.labelPosition,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
            rows: tournament.players.map((player) {
              int playerIndex = tournament.players.indexOf(player);
              int points = tournament.points.elementAtOrNull(playerIndex) ?? 0;
              int position =
                  tournament.places.elementAtOrNull(playerIndex) ?? 0;

              List<DataCell> cells = [
                DataCell(
                  InkWell(
                    onTap: () => context.push(
                      AppRoutes.playerDetails(player.id.toString()),
                    ),
                    child: Text(
                      player.fullName,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                ...tournament.players.map((opponent) {
                  if (player == opponent) {
                    return const DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.blueGrey,
                            size: 10,
                          ),
                        ],
                      ),
                    );
                  } else {
                    final Match? match = tournament.matches
                        ?.where((m) =>
                            (m.bluePlayer.id == player.id &&
                                m.redPlayer.id == opponent.id) ||
                            (m.bluePlayer.id == opponent.id &&
                                m.redPlayer.id == player.id))
                        .firstOrNull;
                    if (match == null) {
                      return const DataCell(Text('–'));
                    }

                    final String cellLabel;
                    if (match.isTechnicalDefeat) {
                      cellLabel =
                          match.winnerId == player.id ? 'W : L' : 'L : W';
                    } else {
                      final playerScore =
                          match.bluePlayer.id == player.id
                              ? match.blueScore
                              : match.redScore;
                      final opponentScore =
                          match.bluePlayer.id == player.id
                              ? match.redScore
                              : match.blueScore;
                      cellLabel = '$playerScore : $opponentScore';
                    }
                    return DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cellLabel,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    );
                  }
                }),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        points.toString(),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        position != 0 ? position.toString() : '',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ];

              return DataRow(cells: cells);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
