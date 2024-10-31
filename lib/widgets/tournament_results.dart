import 'package:flutter/material.dart';
import 'package:tennis_cup/model/tournament.dart';

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
            rows: [
              _buildDataRow('Volynets Oleh',
                  ['.', '2:3', '3:2', '0:3', '0:3', '3:1', '7', '4']),
              _buildDataRow('Varlamov Oleh 🥉',
                  ['3:2', '.', '3:0', '2:3', '1:3', '0:3', '7', '3']),
              _buildDataRow('Skorobahatyi Yevhen',
                  ['2:3', '0:3', '.', '2:3', '3:1', '3:0', '7', '5']),
              _buildDataRow('Lobanov Arsenii 🥈',
                  ['3:0', '3:2', '3:2', '.', '2:3', '1:3', '8', '2']),
              _buildDataRow('Habrelyan Daniil 🥇',
                  ['3:0', '3:1', '3:1', '3:2', '.', '3:1', '9', '1']),
              _buildDataRow('Tiutiunnyk Maksym',
                  ['1:3', '3:0', '3:0', '1:3', '1:3', '.', '7', '6']),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(String name, List<String> results) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        ...results.map((result) => DataCell(Center(child: Text(result)))),
      ],
    );
  }
}
