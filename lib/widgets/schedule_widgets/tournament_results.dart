import 'package:flutter/material.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/model/match.dart';

class TournamentResults extends StatefulWidget {
  final Tournament tournament;
  const TournamentResults(this.tournament, {super.key});

  @override
  State<TournamentResults> createState() {
    return _TournamentResults();
  }
}

class _TournamentResults extends State<TournamentResults> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16.0, 0, 0),
          child: Row(
            children: [
              const Icon(Icons.table_chart_outlined),
              const SizedBox(width: 8),
              Text(
                'Tournament results',
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
                  'Name',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              for (int i = 1; i <= widget.tournament.players.length; ++i)
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
                  'Points',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              DataColumn(
                label: Text(
                  'Position',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
            rows: widget.tournament.players.map((player) {
              int points = 0;

              List<DataCell> cells = [
                DataCell(
                  Text(
                    '${player.surname} ${player.name}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                ...widget.tournament.players.map((opponent) {
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
                    Match match = widget.tournament.matches!.firstWhere(
                      (m) =>
                          (m.bluePlayer == player && m.redPlayer == opponent) ||
                          (m.bluePlayer == opponent && m.redPlayer == player),
                    );

                    ++points;
                    if ((match.bluePlayer == player &&
                            match.blueScore > match.redScore) ||
                        (match.redPlayer == player &&
                            match.redScore > match.blueScore)) {
                      ++points;
                    }

                    return DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${match.bluePlayer == player ? match.blueScore : match.redScore} : ${match.bluePlayer == player ? match.redScore : match.blueScore}',
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
                        '0',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                )
              ];

              return DataRow(cells: cells);
            }).toList(),
          ),
        ),
      ],
    );
  }
}