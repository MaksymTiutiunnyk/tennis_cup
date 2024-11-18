import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/widgets/player_widgets/player_tournament.dart';

class PlayerTournaments extends StatefulWidget {
  final String playerId;

  const PlayerTournaments({super.key, required this.playerId});

  @override
  State createState() => _PlayerTournamentsState();
}

class _PlayerTournamentsState extends State<PlayerTournaments> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Tournament> _tournaments = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchTournaments();
  }

  Future<void> _fetchTournaments() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    Query query = _firestore
        .collection('tournaments')
        .where('players', arrayContains: widget.playerId)
        .orderBy('date')
        .limit(10);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;

      // Fetch tournament objects by awaiting the futures
      final fetchedTournaments = await Future.wait(
          querySnapshot.docs.map((doc) => Tournament.fromFirestore(doc)));

      setState(() {
        _tournaments.addAll(fetchedTournaments);
        _hasMore = querySnapshot.docs.length == 10;
      });
    } else {
      setState(() {
        _hasMore = false;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8.0, 16, 8, 8),
            child: Row(
              children: [
                Icon(Icons.emoji_events),
                SizedBox(width: 8),
                Text('Tournaments'),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _tournaments.length + 1,
              itemBuilder: (context, index) {
                if (index == _tournaments.length) {
                  return _hasMore
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : const Center(
                          child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No more tournaments'),
                        ));
                }
                return PlayerTournament(_tournaments[index]);
              },
              physics: const ClampingScrollPhysics(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
