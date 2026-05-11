class CreateUpdateTournamentRequest {
  final String name;
  final String type;
  final String gender;
  final DateTime startTime;
  final int arenaId;
  final List<int> refereeIds;
  final int matchDurationMinutes;
  final int requiredPlayersCount;
  final int setsToWin;
  final List<int> playerIds;

  const CreateUpdateTournamentRequest({
    required this.name,
    required this.type,
    required this.gender,
    required this.startTime,
    required this.arenaId,
    required this.refereeIds,
    required this.matchDurationMinutes,
    required this.requiredPlayersCount,
    required this.setsToWin,
    required this.playerIds,
  });
}
