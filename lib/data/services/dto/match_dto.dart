class HeadToHeadSetDto {
  final int setNumber;
  final int player1Score;
  final int player2Score;
  final bool technicalDefeat;

  const HeadToHeadSetDto({
    required this.setNumber,
    required this.player1Score,
    required this.player2Score,
    required this.technicalDefeat,
  });

  factory HeadToHeadSetDto.fromJson(Map<String, dynamic> json) =>
      HeadToHeadSetDto(
        setNumber: (json['setNumber'] as num).toInt(),
        player1Score: (json['player1Score'] as num?)?.toInt() ?? 0,
        player2Score: (json['player2Score'] as num?)?.toInt() ?? 0,
        technicalDefeat: json['technicalDefeat'] as bool? ?? false,
      );
}

class HeadToHeadMatchDto {
  final int matchId;
  final int tournamentId;
  final String? tournamentName;
  final DateTime matchDate;
  final int player1SetsWon;
  final int player2SetsWon;
  final int? winnerId;
  final bool technicalDefeat;
  final List<HeadToHeadSetDto> sets;

  const HeadToHeadMatchDto({
    required this.matchId,
    required this.tournamentId,
    required this.matchDate,
    required this.player1SetsWon,
    required this.player2SetsWon,
    required this.technicalDefeat,
    required this.sets,
    this.tournamentName,
    this.winnerId,
  });

  factory HeadToHeadMatchDto.fromJson(Map<String, dynamic> json) =>
      HeadToHeadMatchDto(
        matchId: (json['matchId'] as num).toInt(),
        tournamentId: (json['tournamentId'] as num).toInt(),
        tournamentName: json['tournamentName'] as String?,
        matchDate: DateTime.parse(json['matchDate'] as String),
        player1SetsWon: (json['player1SetsWon'] as num?)?.toInt() ?? 0,
        player2SetsWon: (json['player2SetsWon'] as num?)?.toInt() ?? 0,
        winnerId: (json['winnerId'] as num?)?.toInt(),
        technicalDefeat: json['technicalDefeat'] as bool? ?? false,
        sets: (json['sets'] as List<dynamic>?)
                ?.map((e) =>
                    HeadToHeadSetDto.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

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
  final int refereeId;
  final String status;
  final int bluePlayerId;
  final int redPlayerId;
  final int? winnerId;
  final String scheduledStart;
  final String scheduledEnd;
  final String? actualStart;
  final String? actualEnd;
  final List<MatchSetDto> sets;

  const MatchDto({
    required this.id,
    required this.tournamentId,
    required this.refereeId,
    required this.status,
    required this.bluePlayerId,
    required this.redPlayerId,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.sets,
    this.winnerId,
    this.actualStart,
    this.actualEnd,
  });

  factory MatchDto.fromJson(Map<String, dynamic> json) => MatchDto(
        id: (json['id'] as num).toInt(),
        tournamentId: (json['tournamentId'] as num).toInt(),
        refereeId: (json['refereeId'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? '',
        bluePlayerId: (json['bluePlayerId'] as num).toInt(),
        redPlayerId: (json['redPlayerId'] as num).toInt(),
        winnerId: (json['winnerId'] as num?)?.toInt(),
        scheduledStart: json['scheduledStart'] as String? ?? '',
        scheduledEnd: json['scheduledEnd'] as String? ?? '',
        actualStart: json['actualStart'] as String?,
        actualEnd: json['actualEnd'] as String?,
        sets: (json['sets'] as List<dynamic>?)
                ?.map((s) => MatchSetDto.fromJson(s as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
