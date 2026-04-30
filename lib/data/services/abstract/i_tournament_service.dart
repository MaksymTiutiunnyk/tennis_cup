import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/page_result.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_invitation_dto.dart';

abstract interface class ITournamentService {
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

  Stream<void> watchTournamentChanges(String tournamentId);

  Future<List<TournamentInvitationDto>> fetchInvitations({
    required String playerId,
  });

  Future<void> acceptInvitation(String invitationId);

  Future<void> declineInvitation(String invitationId);
}
