import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/widgets/home_widgets/upcoming_match.dart';
import 'package:tennis_cup/model/match.dart';

class UpcomingMatches extends StatefulWidget {
  const UpcomingMatches({super.key});

  @override
  State<UpcomingMatches> createState() => _UpcomingMatchesState();
}

class _UpcomingMatchesState extends State<UpcomingMatches> {
  Future<List<Match>>? _upcomingMatchesFuture;
  Tournament? _tournament;

  @override
  void initState() {
    super.initState();
    _upcomingMatchesFuture = _fetchMatches();
  }

  Future<List<Match>> _fetchMatches() async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;

      final tournamentDoc =
          await db.collection('tournaments').doc('zFY3TKcYjiuX2ggO4VMe').get();
      _tournament = await Tournament.fromFirestore(tournamentDoc);

      if (!tournamentDoc.exists) {
        throw Exception('Tournament not found.');
      }

      final matchesQuery = await db
          .collection('tournaments')
          .doc('zFY3TKcYjiuX2ggO4VMe')
          .collection('matches')
          .get();

      final List<Match> mappedMatches = [];
      for (var matchDoc in matchesQuery.docs) {
        final match = await Match.fromFirestore(matchDoc);
        mappedMatches.add(match);
      }

      return mappedMatches;
    } catch (e) {
      debugPrint('Error fetching matches: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Match>>(
        future: _upcomingMatchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final matches = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text(
                        'Tennis Cup: Upcoming matches',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      return UpcomingMatch(
                        match: matches[index],
                        tournament: _tournament!,
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text('No upcoming matches available.'),
            );
          }
        },
      ),
    );
  }
}
