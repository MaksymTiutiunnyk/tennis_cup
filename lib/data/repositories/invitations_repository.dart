import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/tournament_invitation.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/dto/arena_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_invitation_dto.dart';

class InvitationsRepository {
  final ITournamentService _tournamentService;
  final IArenaService _arenaService;

  const InvitationsRepository(this._tournamentService, this._arenaService);

  Future<List<TournamentInvitation>> fetchInvitations({
    required String playerId,
  }) async {
    final dtos = await _tournamentService.fetchInvitations(playerId: playerId);
    if (dtos.isEmpty) return const [];

    final tournamentIds = dtos.map((d) => d.tournamentId).toSet();
    final tournamentDtosF = Future.wait(tournamentIds.map(
      (id) => _tournamentService.fetchTournamentById(id.toString()),
    ));
    final arenaDtosF = _arenaService.fetchAllArenas();

    final tournamentDtos = await tournamentDtosF;
    final arenaDtos = await arenaDtosF;

    final tournamentById = {for (final t in tournamentDtos) t.id: t};
    final arenaById = {for (final a in arenaDtos) a.id: a};

    return dtos.map((dto) {
      final tournamentDto = tournamentById[dto.tournamentId];
      final arenaDto =
          tournamentDto != null ? arenaById[tournamentDto.arenaId] : null;
      return _toDomain(dto, tournamentDto, arenaDto);
    }).toList();
  }

  Future<void> acceptInvitation(String invitationId) {
    return _tournamentService.acceptInvitation(invitationId);
  }

  Future<void> declineInvitation(String invitationId) {
    return _tournamentService.declineInvitation(invitationId);
  }

  static TournamentInvitation _toDomain(
    TournamentInvitationDto dto,
    TournamentDto? tournamentDto,
    ArenaDto? arenaDto,
  ) {
    final arena = Arena(
      id: arenaDto?.id.toString() ?? '',
      title: arenaDto?.name ?? '',
      color: arenaColorFromString(arenaDto?.color ?? ''),
      city: arenaDto?.city,
    );
    final tournament = Tournament(
      tournamentId: dto.tournamentId.toString(),
      players: const [],
      date: tournamentDto != null
          ? DateTime.parse(tournamentDto.startTime)
          : DateTime.parse(dto.startTime),
      arena: arena,
      time: timeFromString(tournamentDto?.type ?? ''),
      points: const [],
      places: const [],
    );
    return TournamentInvitation(
      id: dto.id.toString(),
      tournament: tournament,
      playerNumber: dto.playerNumber,
      startTime: DateTime.parse(dto.startTime),
      endTime: DateTime.parse(dto.endTime),
      deadline: DateTime.parse(dto.deadline),
      status: _statusFromString(dto.status),
    );
  }

  static InvitationStatus _statusFromString(String value) {
    return switch (value.toUpperCase()) {
      'ACCEPTED' => InvitationStatus.accepted,
      'DECLINED' => InvitationStatus.declined,
      _ => InvitationStatus.pending,
    };
  }
}
