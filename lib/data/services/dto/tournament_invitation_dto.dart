class TournamentInvitationDto {
  final int id;
  final int tournamentId;
  final int playerId;
  final int playerNumber;
  final String startTime;
  final String endTime;
  final String deadline;
  final String status;

  const TournamentInvitationDto({
    required this.id,
    required this.tournamentId,
    required this.playerId,
    required this.playerNumber,
    required this.startTime,
    required this.endTime,
    required this.deadline,
    required this.status,
  });

  factory TournamentInvitationDto.fromJson(Map<String, dynamic> json) {
    return TournamentInvitationDto(
      id: (json['id'] as num).toInt(),
      tournamentId: (json['tournamentId'] as num?)?.toInt() ?? 0,
      playerId: (json['playerId'] as num?)?.toInt() ?? 0,
      playerNumber: (json['playerNumber'] as num?)?.toInt() ?? 0,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      deadline: json['deadline'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
    );
  }
}
