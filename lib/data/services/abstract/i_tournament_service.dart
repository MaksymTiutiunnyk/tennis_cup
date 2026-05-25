import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/services/dto/dashboard_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';

abstract interface class ITournamentService {
  // ---- Read ----

  Future<PageResult<TournamentDto>> fetchPlayerTournaments({
    required String userId,
    required PageRequest page,
    required List<String> statuses,
  });

  Future<TournamentDto> fetchTournamentById(String id);

  Future<List<TournamentDto>> fetchScheduledTournaments({
    required DateTime date,
    required Arena arena,
    required Time time,
    required List<String> statuses,
  });

  Future<List<ArenaMatchViewDto>> fetchCurrentMatches();

  Future<List<ArenaMatchViewDto>> fetchDashboardUpcomingMatches();

  Future<List<ArenaLastWinnerDto>> fetchLastWinners();

  Future<PageResult<TournamentDto>> fetchRefereeTournaments({
    required PageRequest page,
    required String refereeId,
    required List<String> statuses,
  });

  Stream<void> watchTournamentChanges(String tournamentId);

  Future<List<MyInvitationDto>> fetchInvitations({required String status});

  Future<void> acceptInvitation(String invitationId);

  Future<void> declineInvitation(String invitationId);

  // ---- Write ----

  Future<TournamentDto> createTournament(CreateUpdateTournamentRequestDto dto);

  Future<TournamentDto> updateTournament(
      int id, CreateUpdateTournamentRequestDto dto);

  Future<void> deleteTournament(int id);

  Future<TournamentDto> addPlayers(int tournamentId, List<int> playerIds);

  Future<TournamentDto> removePlayers(int tournamentId, List<int> playerIds);

  Future<TournamentDto> startTournament(int id);

  Future<TournamentDto> finishTournament(int id);
}
