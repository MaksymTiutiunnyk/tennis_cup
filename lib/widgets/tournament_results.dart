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
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 16.0, 0, 0),
          child: Row(
            children: [
              Icon(Icons.table_chart_outlined),
              SizedBox(width: 8),
              Text(
                'Tournament results',
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(width: 0.1),
            columns: [
              const DataColumn(
                label: Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 98, 98, 98),
                  ),
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
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 98, 98, 98),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              const DataColumn(
                label: Text(
                  'Points',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 98, 98, 98),
                  ),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Position',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 98, 98, 98),
                  ),
                ),
              ),
            ],
            rows: widget.tournament.players.map((player) {
              int points = 0;

              List<DataCell> cells = [
                DataCell(
                  Text(
                    '${player.surname} ${player.name}',
                    style: const TextStyle(fontSize: 16),
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
                            style: const TextStyle(fontSize: 16),
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
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '0',
                        style: TextStyle(fontSize: 16),
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
