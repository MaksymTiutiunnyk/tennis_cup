import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/widgets/home_widgets/live_stream_match.dart';

class LiveStreamMatches extends StatefulWidget {
  const LiveStreamMatches({super.key});

  @override
  State<LiveStreamMatches> createState() => _LiveStreamMatchesState();
}

class _LiveStreamMatchesState extends State<LiveStreamMatches> {
  Future<List<Match>>? _liveStreamMatchesFuture;
  Tournament? _tournament;

  @override
  void initState() {
    super.initState();
    _liveStreamMatchesFuture = _fetchMatches();
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
    return FutureBuilder<List<Match>>(
      future: _liveStreamMatchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final matches = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.live_tv),
                    const SizedBox(width: 8),
                    Text(
                      'Tennis Cup: Live stream',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 170,
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: PageController(viewportFraction: 0.90),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    return LiveStreamMatch(
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
            child: Text('No live stream matches available.'),
          );
        }
      },
    );
  }
}
