import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/dto/dashboard_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_invitation_dto.dart';

// Note: fetchPlayerTournaments filters by player1Id via Firestore arrayContains.
// player2Id filtering is applied client-side — Firestore only supports one
// arrayContains per query.
class FirebaseTournamentService implements ITournamentService {
  DocumentSnapshot? _tournamentCursor;

  @override
  Future<PageResult<TournamentDto>> fetchPlayerTournaments({
    required String userId,
    String? player2Id,
    required PageRequest page,
    required List<String> statuses,
  }) async {
    if (page.page == 0) _tournamentCursor = null;

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('tournaments')
        .where('players', arrayContains: userId)
        .orderBy('date', descending: true)
        .limit(page.size);

    if (_tournamentCursor != null) {
      query = query.startAfterDocument(_tournamentCursor!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _tournamentCursor = snapshot.docs.last;
    }

    final dtos = <TournamentDto>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();

      final playerIds = (data['players'] as List<dynamic>?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [];

      if (player2Id != null &&
          !playerIds.map((id) => id.toString()).contains(player2Id)) {
        continue;
      }

      dtos.add(_dtoFromDoc(doc.id, data, playerIds));
    }

    return PageResult(
      items: dtos,
      hasMore: snapshot.docs.length == page.size,
    );
  }

  @override
  Future<TournamentDto> fetchTournamentById(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('tournaments')
        .doc(id)
        .get();
    final data = doc.data();
    if (data == null) throw Exception('Tournament $id not found');
    final playerIds = (data['players'] as List<dynamic>?)
            ?.map((e) => int.tryParse(e.toString()) ?? 0)
            .toList() ??
        [];
    return _dtoFromDoc(doc.id, data, playerIds);
  }

  @override
  Future<List<TournamentDto>> fetchScheduledTournaments({
    required DateTime date,
    required Arena arena,
    required Time time,
    required List<String> statuses,
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

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final playerIds = (data['players'] as List<dynamic>?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [];
      return _dtoFromDoc(doc.id, data, playerIds);
    }).toList();
  }

  @override
  Stream<void> watchTournamentChanges(String tournamentId) {
    return FirebaseFirestore.instance
        .collectionGroup('matches')
        .where('tournamentId', isEqualTo: tournamentId)
        .snapshots()
        .map((_) {});
  }

  static TournamentDto _dtoFromDoc(
    String docId,
    Map<String, dynamic> data,
    List<int> playerIds,
  ) {
    final ts = data['date'] as Timestamp?;
    final dateTime = ts?.toDate() ?? DateTime.now();
    final isFinished = data['isFinished'] as bool? ?? false;

    return TournamentDto(
      id: int.tryParse(docId) ?? 0,
      name: data['arena'] as String? ?? '',
      type: _toRestType(data['time'] as String? ?? ''),
      format: 'ROUND_ROBIN',
      status: isFinished ? 'FINISHED' : 'PENDING',
      startTime: dateTime.toIso8601String(),
      arenaId: 0,
      gender: 'MALE',
      requiredPlayersCount: 0,
      setsToWin: 1,
      participants: playerIds
          .map((id) => TournamentParticipantDto(
                userId: id,
                role: 'PLAYER',
                invitationStatus: 'ACCEPTED',
              ))
          .toList(),
      matchDurationMinutes: 30,
    );
  }

  static String _toRestType(String firebaseTime) {
    switch (firebaseTime) {
      case 'Morning':
        return 'MORNING';
      case 'Day':
        return 'DAY';
      case 'Evening':
        return 'EVENING';
      case 'Night':
        return 'NIGHT';
      default:
        return 'MORNING';
    }
  }

  @override
  Future<TournamentDto> createTournament(
          CreateUpdateTournamentRequestDto dto) =>
      throw UnimplementedError('createTournament not implemented for Firebase');

  @override
  Future<TournamentDto> updateTournament(
          int id, CreateUpdateTournamentRequestDto dto) =>
      throw UnimplementedError('updateTournament not implemented for Firebase');

  @override
  Future<void> deleteTournament(int id) =>
      throw UnimplementedError('deleteTournament not implemented for Firebase');

  @override
  Future<TournamentDto> addPlayers(int tournamentId, List<int> playerIds) =>
      throw UnimplementedError('addPlayers not implemented for Firebase');

  @override
  Future<TournamentDto> removePlayers(int tournamentId, List<int> playerIds) =>
      throw UnimplementedError('removePlayers not implemented for Firebase');

  @override
  Future<TournamentDto> startTournament(int id) =>
      throw UnimplementedError('startTournament not implemented for Firebase');

  @override
  Future<TournamentDto> finishTournament(int id) =>
      throw UnimplementedError('finishTournament not implemented for Firebase');

  @override
  Future<List<MyInvitationDto>> fetchInvitations(
          {required String status}) async =>
      const [];

  @override
  Future<void> acceptInvitation(String tournamentId) async {}

  @override
  Future<void> declineInvitation(String tournamentId) async {}

  @override
  Future<List<ArenaMatchViewDto>> fetchCurrentMatches() async => const [];

  @override
  Future<List<ArenaMatchViewDto>> fetchDashboardUpcomingMatches() async =>
      const [];

  @override
  Future<List<ArenaLastWinnerDto>> fetchLastWinners() async => const [];

  @override
  Future<PageResult<TournamentDto>> fetchActiveTournamentsForReferee(
      PageRequest page, String refereeId) {
    throw UnimplementedError(
        'fetchActiveTournamentsForReferee not implemented for Firebase');
  }
}
