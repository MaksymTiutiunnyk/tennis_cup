import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennis_cup/widgets/schedule_widgets/scheduled_match.dart';
import 'package:tennis_cup/model/match.dart';

class ScheduledMatches extends StatefulWidget {
  const ScheduledMatches({super.key});

  @override
  State<ScheduledMatches> createState() => _ScheduledMatchesState();
}

class _ScheduledMatchesState extends State<ScheduledMatches> {
  QuerySnapshot<Map<String, dynamic>>? _matches;
  Future<List<ScheduledMatch>>? _scheduledMatches;

  @override
  void initState() {
    super.initState();
    _scheduledMatches = _getMatches();
  }

  Future<List<ScheduledMatch>> _getMatches() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    _matches = await db
        .collection('tournaments')
        .doc('zFY3TKcYjiuX2ggO4VMe')
        .collection('matches')
        .get();

    final List<Match> mappedMatches = [];
    List<ScheduledMatch> scheduledMatches;

    for (int i = 0; i < _matches!.size; ++i) {
      mappedMatches.add(await Match.fromFirestore(_matches!.docs[i]));
    }
    scheduledMatches =
        mappedMatches.map((match) => ScheduledMatch(match: match)).toList();

    return scheduledMatches;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        future: _scheduledMatches,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!,
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
