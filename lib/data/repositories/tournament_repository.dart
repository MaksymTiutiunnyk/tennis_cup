import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/data_providers/tournament_api.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';

class TournamentRepository {
  final TournamentApi tournamentApi;

  const TournamentRepository({required this.tournamentApi});

  Future<List<Tournament>> fetchScheduledTournament(
      {required DateTime tournamentDate,
      required Arena tournamentArena,
      required Time tournamentTime}) async {
    final querySnapshot = await tournamentApi.fetchScheduledTournament(
        tournamentDate: tournamentDate,
        tournamentArena: tournamentArena,
        tournamentTime: tournamentTime);

    List<Tournament> mappedTournaments = await Future.wait(
        querySnapshot.docs.map((doc) async => Tournament.fromFirestore(doc)));

    return mappedTournaments;
  }

  Future<List<Tournament>> fetchLiveStreamMatchesTournaments() async {
    final QuerySnapshot querySnapshot =
        await tournamentApi.fetchLiveStreamMatchesTournaments();

    List<Tournament> mappedTournaments = await Future.wait(
        querySnapshot.docs.map((doc) async => Tournament.fromFirestore(doc)));

    return mappedTournaments;
  }

  Future<List<Tournament>> fetchUpcomingMatchesTournaments() async {
    final QuerySnapshot querySnapshot =
        await tournamentApi.fetchUpcomingMatchesTournaments();

    List<Tournament> mappedTournaments = await Future.wait(
        querySnapshot.docs.map((doc) async => Tournament.fromFirestore(doc)));

    return mappedTournaments;
  }

  Future<List<Tournament>> fetchWinnersTournaments() async {
    final QuerySnapshot querySnapshot =
        await tournamentApi.fetchWinnersTournaments();

    List<Tournament> mappedTournaments = await Future.wait(
        querySnapshot.docs.map((doc) async => Tournament.fromFirestore(doc)));

    return mappedTournaments;
  }

  Stream<void> watchTournamentChanges(String tournamentId) {
    return tournamentApi.watchTournamentChanges(tournamentId);
  }

  Future<Map<String, dynamic>> fetchPlayersTournaments({
    required String player1Id,
    String? player2Id,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    final querySnapshot = await tournamentApi.fetchPlayerTournaments(
        playerId: player1Id, limit: limit, startAfter: startAfter);

    final tournaments = <Tournament>[];

    for (final doc in querySnapshot.docs) {
      final tournament = await Tournament.fromFirestore(doc);
      if (player2Id != null) {
        if (tournament.players.any((player) => player.playerId == player2Id)) {
          tournaments.add(tournament);
        }
      } else {
        tournaments.add(tournament);
      }
    }

    return {
      'tournaments': tournaments,
      'lastDocument':
          querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
    };
  }

  Future<Tournament> fetchTournamentById({
    required String tournamentId,
  }) async {
    DocumentSnapshot tournamentSnapshot =
        await tournamentApi.fetchTournamentById(tournamentId: tournamentId);

    return await Tournament.fromFirestore(tournamentSnapshot);
  }
}
