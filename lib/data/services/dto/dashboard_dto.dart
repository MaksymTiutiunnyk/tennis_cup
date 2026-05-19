class PlayerBriefDto {
  final int id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;

  const PlayerBriefDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
  });

  factory PlayerBriefDto.fromJson(Map<String, dynamic> json) => PlayerBriefDto(
        id: (json['id'] as num).toInt(),
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
      );
}

class ArenaBriefDto {
  final int id;
  final String name;

  const ArenaBriefDto({required this.id, required this.name});

  factory ArenaBriefDto.fromJson(Map<String, dynamic> json) => ArenaBriefDto(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
      );
}

class TournamentBriefDto {
  final int id;
  final String name;
  final String gender;
  final String type;
  final String start;
  final String? youTubeUrl;

  const TournamentBriefDto({
    required this.id,
    required this.name,
    required this.gender,
    required this.type,
    required this.start,
    this.youTubeUrl,
  });

  factory TournamentBriefDto.fromJson(Map<String, dynamic> json) =>
      TournamentBriefDto(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        gender: json['gender'] as String? ?? '',
        type: json['type'] as String? ?? '',
        start: json['start'] as String? ?? '',
        youTubeUrl: json['youTubeUrl'] as String?,
      );
}

class SetScoreDto {
  final int blueSets;
  final int redSets;

  const SetScoreDto({required this.blueSets, required this.redSets});

  factory SetScoreDto.fromJson(Map<String, dynamic> json) => SetScoreDto(
        blueSets: (json['blueSets'] as num?)?.toInt() ?? 0,
        redSets: (json['redSets'] as num?)?.toInt() ?? 0,
      );
}

class ArenaMatchViewDto {
  final int matchId;
  final ArenaBriefDto arena;
  final TournamentBriefDto tournament;
  final PlayerBriefDto bluePlayer;
  final PlayerBriefDto redPlayer;
  final SetScoreDto score;

  const ArenaMatchViewDto({
    required this.matchId,
    required this.arena,
    required this.tournament,
    required this.bluePlayer,
    required this.redPlayer,
    required this.score,
  });

  factory ArenaMatchViewDto.fromJson(Map<String, dynamic> json) =>
      ArenaMatchViewDto(
        matchId: (json['matchId'] as num).toInt(),
        arena: ArenaBriefDto.fromJson(json['arena'] as Map<String, dynamic>),
        tournament: TournamentBriefDto.fromJson(
            json['tournament'] as Map<String, dynamic>),
        bluePlayer: PlayerBriefDto.fromJson(
            json['bluePlayer'] as Map<String, dynamic>),
        redPlayer: PlayerBriefDto.fromJson(
            json['redPlayer'] as Map<String, dynamic>),
        score: SetScoreDto.fromJson(json['score'] as Map<String, dynamic>),
      );
}

class ArenaLastWinnerDto {
  final ArenaBriefDto arena;
  final TournamentBriefDto? tournament;
  final List<PlayerBriefDto>? winners;

  const ArenaLastWinnerDto({
    required this.arena,
    this.tournament,
    this.winners,
  });

  factory ArenaLastWinnerDto.fromJson(Map<String, dynamic> json) =>
      ArenaLastWinnerDto(
        arena: ArenaBriefDto.fromJson(json['arena'] as Map<String, dynamic>),
        tournament: json['tournament'] != null
            ? TournamentBriefDto.fromJson(
                json['tournament'] as Map<String, dynamic>)
            : null,
        winners: (json['winners'] as List<dynamic>?)
            ?.map((e) => PlayerBriefDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
