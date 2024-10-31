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
              Text('Tournament results')
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              const DataColumn(label: Text('Name')),
              for (int i = 1; i <= widget.tournament.players.length; ++i)
                DataColumn(label: Text(i.toString())),
              const DataColumn(label: Text('Points')),
              const DataColumn(label: Text('Position')),
            ],
            rows: widget.tournament.players.map((player) {
              int points = 0;

              List<DataCell> cells = [
                DataCell(Text('${player.surname} ${player.name}')),
                ...widget.tournament.players.map((opponent) {
                  if (player == opponent) {
                    return const DataCell(Text('•'));
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
                      Text(
                          '${match.bluePlayer == player ? match.blueScore : match.redScore} : ${match.bluePlayer == player ? match.redScore : match.blueScore}'),
                    );
                  }
                }),
                DataCell(Text(points.toString())),
                const DataCell(Text(''))
              ];

              return DataRow(cells: cells);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
