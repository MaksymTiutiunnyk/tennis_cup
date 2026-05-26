import 'package:tennis_cup/core/utils/enum_utils.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/tournament_invitation.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/dto/arena_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';

class InvitationsRepository {
  final ITournamentService _tournamentService;
  final IArenaService _arenaService;

  const InvitationsRepository(this._tournamentService, this._arenaService);

  Future<List<TournamentInvitation>> fetchInvitations(
      {required String status}) async {
    final dtos = await _tournamentService.fetchInvitations(status: status);
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
    MyInvitationDto dto,
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
      name: tournamentDto?.name ?? dto.tournamentName,
      gender: tournamentDto?.gender ?? '',
      status: enumFromString(TournamentStatus.values, tournamentDto?.status, TournamentStatus.pending),
      players: const [],
      date: tournamentDto != null
          ? DateTime.parse(tournamentDto.startTime).toLocal()
          : DateTime.parse(dto.startTime).toLocal(),
      arena: arena,
      time: timeFromString(tournamentDto?.type ?? ''),
      points: const [],
      places: const [],
      requiredPlayersCount: tournamentDto?.requiredPlayersCount,
    );
    return TournamentInvitation(
      id: dto.invitationId.toString(),
      tournamentId: dto.tournamentId.toString(),
      tournament: tournament,
      role: _roleFromString(dto.role),
      status: _statusFromString(dto.status),
    );
  }

  static InvitationRole _roleFromString(String value) {
    return value.toUpperCase() == 'REFEREE'
        ? InvitationRole.referee
        : InvitationRole.player;
  }

  static InvitationStatus _statusFromString(String value) {
    return switch (value.toUpperCase()) {
      'ACCEPTED' => InvitationStatus.accepted,
      'DECLINED' => InvitationStatus.declined,
      _ => InvitationStatus.pending,
    };
  }
}
