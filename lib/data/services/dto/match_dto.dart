class MatchSetDto {
  final int id;
  final int matchId;
  final int number;
  final int bluePlayerScore;
  final int redPlayerScore;
  final String status;
  final int? winnerId;

  const MatchSetDto({
    required this.id,
    required this.matchId,
    required this.number,
    required this.bluePlayerScore,
    required this.redPlayerScore,
    required this.status,
    this.winnerId,
  });

  factory MatchSetDto.fromJson(Map<String, dynamic> json) => MatchSetDto(
        id: (json['id'] as num).toInt(),
        matchId: (json['matchId'] as num).toInt(),
        number: (json['number'] as num).toInt(),
        bluePlayerScore: (json['bluePlayerScore'] as num?)?.toInt() ?? 0,
        redPlayerScore: (json['redPlayerScore'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? '',
        winnerId: (json['winnerId'] as num?)?.toInt(),
      );
}

class MatchDto {
  final int id;
  final int tournamentId;
  final String status;
  final int bluePlayerId;
  final int redPlayerId;
  final int? winnerId;
  final String scheduledStart;
  final List<MatchSetDto> sets;

  const MatchDto({
    required this.id,
    required this.tournamentId,
    required this.status,
    required this.bluePlayerId,
    required this.redPlayerId,
    required this.scheduledStart,
    required this.sets,
    this.winnerId,
  });

  factory MatchDto.fromJson(Map<String, dynamic> json) => MatchDto(
        id: (json['id'] as num).toInt(),
        tournamentId: (json['tournamentId'] as num).toInt(),
        status: json['status'] as String? ?? '',
        bluePlayerId: (json['bluePlayerId'] as num).toInt(),
        redPlayerId: (json['redPlayerId'] as num).toInt(),
        winnerId: (json['winnerId'] as num?)?.toInt(),
        scheduledStart: json['scheduledStart'] as String? ?? '',
        sets: (json['sets'] as List<dynamic>?)
                ?.map((s) => MatchSetDto.fromJson(s as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
