class CreateTournamentRequest {
  final String name;
  final String type;
  final String gender;
  final DateTime startTime;
  final int arenaId;
  final List<int> refereeIds;
  final int matchDurationMinutes;
  final int requiredPlayersCount;
  final int setsToWin;
  final List<int>? playerIds;

  const CreateTournamentRequest({
    required this.name,
    required this.type,
    required this.gender,
    required this.startTime,
    required this.arenaId,
    required this.refereeIds,
    required this.matchDurationMinutes,
    required this.requiredPlayersCount,
    required this.setsToWin,
    this.playerIds,
  });
}

class UpdateTournamentRequest {
  final String? name;
  final String? type;
  final String? gender;
  final DateTime? startTime;
  final int? arenaId;
  final List<int>? refereeIds;
  final List<int>? playerIds;

  const UpdateTournamentRequest({
    this.name,
    this.type,
    this.gender,
    this.startTime,
    this.arenaId,
    this.refereeIds,
    this.playerIds,
  });
}
