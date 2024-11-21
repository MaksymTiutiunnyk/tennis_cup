import 'package:flutter/material.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:tennis_cup/screens/player_details.dart';

class TournamentResults extends StatelessWidget {
  final Tournament tournament;
  const TournamentResults(this.tournament, {super.key});

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
            rows: tournament.players.map((player) {
              int playerIndex = tournament.players.indexOf(player);
              int points = tournament.points[playerIndex];
              int position = tournament.places[playerIndex];

              List<DataCell> cells = [
                DataCell(
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => PlayerDetails(player: player)));
                    },
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
                    Match match = tournament.matches!.firstWhere(
                      (m) =>
                          (m.bluePlayer.fullName == player.fullName &&
                              m.redPlayer.fullName == opponent.fullName) ||
                          (m.bluePlayer.fullName == opponent.fullName &&
                              m.redPlayer.fullName == player.fullName),
                    );

                    return DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${match.bluePlayer.fullName == player.fullName ? match.blueScore : match.redScore} : ${match.bluePlayer.fullName == player.fullName ? match.redScore : match.blueScore}',
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
