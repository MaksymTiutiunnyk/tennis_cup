import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/page_result.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/firebase/firebase_player_service.dart';

// Note: fetchPlayerTournaments filters by player1Id via Firestore arrayContains.
// player2Id filtering is applied client-side — Firestore only supports one
// arrayContains per query.
class FirebaseTournamentService implements ITournamentService {
  final FirebasePlayerService _playerService;

  DocumentSnapshot? _tournamentCursor;

  FirebaseTournamentService([FirebasePlayerService? playerService])
      : _playerService = playerService ?? FirebasePlayerService();

  @override
  Future<PageResult<Tournament>> fetchPlayerTournaments({
    required String playerId,
    String? player2Id,
    required PageRequest page,
  }) async {
    if (page.page == 0) _tournamentCursor = null;

    Query query = FirebaseFirestore.instance
        .collection('tournaments')
        .where('players', arrayContains: playerId)
        .orderBy('date', descending: true)
        .limit(page.size);

    if (_tournamentCursor != null) {
      query = query.startAfterDocument(_tournamentCursor!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _tournamentCursor = snapshot.docs.last;
    }

    final tournaments = <Tournament>[];
    for (final doc in snapshot.docs) {
      if (player2Id != null) {
        final ids = (doc['players'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        if (!ids.contains(player2Id)) continue;
      }
      final t = await _tournamentFromDoc(doc);
      if (t != null) tournaments.add(t);
    }

    return PageResult(
      items: tournaments,
      hasMore: snapshot.docs.length == page.size,
    );
  }

  @override
  Future<Tournament> fetchTournamentById(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('tournaments')
        .doc(id)
        .get();
    final t = await _tournamentFromDoc(doc);
    if (t == null) throw Exception('Tournament $id not found');
    return t;
  }

  @override
  Future<List<Tournament>> fetchScheduledTournaments({
    required DateTime date,
    required Arena arena,
    required Time time,
  }) async {
    final start =
        Timestamp.fromDate(DateTime(date.year, date.month, date.day, 0, 0, 0));
    final end = Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, 23, 59, 59));

    final snapshot = await FirebaseFirestore.instance
        .collection('tournaments')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .where('time', isEqualTo: time.name)
        .where('arena', isEqualTo: arena.title)
        .get();

    final results = <Tournament>[];
    for (final doc in snapshot.docs) {
      final t = await _tournamentFromDoc(doc);
      if (t != null) results.add(t);
    }
    return results;
  }

  @override
  Future<List<Tournament>> fetchRecentTournaments({int limit = 10}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tournaments')
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    final results = <Tournament>[];
    for (final doc in snapshot.docs) {
      final t = await _tournamentFromDoc(doc);
      if (t != null) results.add(t);
    }
    return results;
  }

  @override
  Future<List<Tournament>> fetchUpcomingTournaments({int limit = 10}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tournaments')
        .where('isFinished', isNotEqualTo: true)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    final results = <Tournament>[];
    for (final doc in snapshot.docs) {
      final t = await _tournamentFromDoc(doc);
      if (t != null) results.add(t);
    }
    return results;
  }

  @override
  Stream<void> watchTournamentChanges(String tournamentId) {
    return FirebaseFirestore.instance
        .collectionGroup('matches')
        .where('tournamentId', isEqualTo: tournamentId)
        .snapshots()
        .map((_) => null);
  }

  Future<Tournament?> _tournamentFromDoc(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    final arenaTitle = data['arena'] as String? ?? '';
    final arena = Arena(title: arenaTitle, color: _colorForArena(arenaTitle));

    final playerIds = (data['players'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final players = <Player>[];
    for (final id in playerIds) {
      try {
        players.add(await _playerService.fetchPlayerById(id));
      } catch (_) {}
    }

    final matchDocs = await FirebaseFirestore.instance
        .collection('tournaments')
        .doc(doc.id)
        .collection('matches')
        .get();

    final matches = matchDocs.docs
        .map((m) => _matchFromDoc(m, players, doc.id))
        .whereType<Match>()
        .toList();

    final ts = data['date'] as Timestamp?;

    return Tournament(
      tournamentId: doc.id,
      players: players,
      date: ts?.toDate() ?? DateTime.now(),
      arena: arena,
      time: _timeFromString(data['time'] as String? ?? ''),
      points: List<int>.from(data['points'] as List? ?? []),
      places: List<int>.from(data['places'] as List? ?? []),
      isFinished: data['isFinished'] as bool? ?? false,
      matches: matches.isEmpty ? null : matches,
    );
  }

  static Match? _matchFromDoc(
    DocumentSnapshot doc,
    List<Player> players,
    String tournamentId,
  ) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    Player? find(String id) =>
        players.where((p) => p.playerId == id).firstOrNull;

    final blue = find(data['bluePlayer'] as String? ?? '');
    final red = find(data['redPlayer'] as String? ?? '');
    if (blue == null || red == null) return null;

    final ts = data['dateTime'] as Timestamp?;

    return Match(
      matchId: doc.id,
      bluePlayer: blue,
      redPlayer: red,
      blueScore: (data['blueScore'] as num?)?.toInt() ?? 0,
      redScore: (data['redScore'] as num?)?.toInt() ?? 0,
      blueSetScores: List<int>.from(data['blueSetScores'] as List? ?? []),
      redSetScores: List<int>.from(data['redSetScores'] as List? ?? []),
      tournamentId: tournamentId,
      dateTime: ts?.toDate() ?? DateTime.now(),
    );
  }

  static Time _timeFromString(String value) {
    switch (value) {
      case 'Morning':
        return Time.Morning;
      case 'Day':
        return Time.Day;
      case 'Evening':
        return Time.Evening;
      case 'Night':
        return Time.Night;
      default:
        return Time.Morning;
    }
  }

  // Firebase arenas were identified by title string; map known titles to colors.
  // See firebase_arena_service.dart for the full hardcoded list.
  static Color _colorForArena(String title) {
    const map = <String, Color>{
      'Europe': Color.fromARGB(255, 4, 6, 114),
      'Australia': Colors.green,
      'America': Colors.red,
      'Africa': Colors.black,
      'Asia': Colors.yellowAccent,
      'Beijing': Colors.greenAccent,
    };
    return map[title] ?? Colors.grey;
  }
}
