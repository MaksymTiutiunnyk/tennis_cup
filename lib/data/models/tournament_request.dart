class CreateTournamentRequest {
  final String name;
  final String type;
  final String gender;
  final DateTime startTime;
  final int arenaId;
  final int refereeId;
  final int matchDurationMinutes;
  final List<int>? playerIds;

  const CreateTournamentRequest({
    required this.name,
    required this.type,
    required this.gender,
    required this.startTime,
    required this.arenaId,
    required this.refereeId,
    required this.matchDurationMinutes,
    this.playerIds,
  });
}

class UpdateTournamentRequest {
  final String? name;
  final String? type;
  final String? gender;
  final DateTime? startTime;
  final int? arenaId;
  final int? refereeId;
  final List<int>? playerIds;

  const UpdateTournamentRequest({
    this.name,
    this.type,
    this.gender,
    this.startTime,
    this.arenaId,
    this.refereeId,
    this.playerIds,
  });
}
