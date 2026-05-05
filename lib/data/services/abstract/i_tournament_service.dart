import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/services/dto/dashboard_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_invitation_dto.dart';

abstract interface class ITournamentService {
  // ---- Read ----

  Future<PageResult<TournamentDto>> fetchPlayerTournaments({
    required String playerId,
    String? player2Id,
    required PageRequest page,
  });

  Future<TournamentDto> fetchTournamentById(String id);

  Future<List<TournamentDto>> fetchScheduledTournaments({
    required DateTime date,
    required Arena arena,
    required Time time,
  });

  Future<List<TournamentDto>> fetchRecentTournaments({int limit = 10});

  Future<List<TournamentDto>> fetchUpcomingTournaments({int limit = 10});

  Future<List<ArenaMatchViewDto>> fetchCurrentMatches();

  Future<List<ArenaMatchViewDto>> fetchDashboardUpcomingMatches();

  Future<List<ArenaLastWinnerDto>> fetchLastWinners();

  Future<PageResult<TournamentDto>> fetchTournamentsPaged(
    PageRequest page, {
    String? status,
  });

  Stream<void> watchTournamentChanges(String tournamentId);

  Future<List<TournamentInvitationDto>> fetchInvitations({
    required String playerId,
  });

  Future<void> acceptInvitation(String invitationId);

  Future<void> declineInvitation(String invitationId);

  // ---- Write ----

  Future<TournamentDto> createTournament(CreateTournamentRequestDto dto);

  Future<TournamentDto> updateTournament(int id, UpdateTournamentRequestDto dto);

  Future<void> deleteTournament(int id);

  Future<TournamentDto> addPlayers(int tournamentId, List<int> playerIds);

  Future<TournamentDto> removePlayers(int tournamentId, List<int> playerIds);

  Future<TournamentDto> startTournament(int id);

  Future<TournamentDto> finishTournament(int id);
}
