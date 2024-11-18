import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/widgets/comparison_widgets.dart/players_match.dart';

class PlayersMatches extends StatefulWidget {
  final Player player1, player2;
  const PlayersMatches(
      {super.key, required this.player1, required this.player2});

  @override
  State<PlayersMatches> createState() => _PlayersMatchesState();
}

class _PlayersMatchesState extends State<PlayersMatches> {
  DocumentSnapshot<Map<String, dynamic>>? _tournamentDoc;
  Tournament? _tournament;
  QuerySnapshot<Map<String, dynamic>>? _matches;
  final List<Match> _mappedMatches = [];

  @override
  void initState() {
    super.initState();
    _getMatches();
  }

  void _getMatches() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    _tournamentDoc =
        await db.collection('tournaments').doc('zFY3TKcYjiuX2ggO4VMe').get();
    _tournament = await Tournament.fromFirestore(_tournamentDoc!);
    _matches = await db
        .collection('tournaments')
        .doc('zFY3TKcYjiuX2ggO4VMe')
        .collection('matches')
        .get();
    for (int i = 0; i < _matches!.size; ++i) {
      _mappedMatches
          .add(await Match.fromFirestore(_matches!.docs[i]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              const Icon(Icons.people),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "Players' matches: ${widget.player1.fullName} vs ${widget.player2.fullName}",
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
        for (Match match in _mappedMatches)
          PlayersMatch(
            player1: widget.player1,
            player2: widget.player2,
            match: match,
            tournament: _tournament!,
          )
      ],
    );
  }
}
