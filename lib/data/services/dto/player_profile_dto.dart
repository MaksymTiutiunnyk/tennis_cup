class PlayerProfileDto {
  final int id;
  final String firstName;
  final String lastName;
  final String? patronymicName;
  final String? gender;
  final String? birthDate;
  final String? city;
  final String? country;
  final List<String> roles;
  final String? status;
  final double? rating;
  final String? avatarUrl;
  final PlayerStatisticsDto? statistics;

  const PlayerProfileDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.patronymicName,
    this.gender,
    this.birthDate,
    this.city,
    this.country,
    this.roles = const [],
    this.status,
    this.rating,
    this.avatarUrl,
    this.statistics,
  });

  factory PlayerProfileDto.fromJson(Map<String, dynamic> json) =>
      PlayerProfileDto(
        id: (json['id'] as num).toInt(),
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        patronymicName: json['patronymicName'] as String?,
        gender: json['gender'] as String?,
        birthDate: json['birthDate'] as String?,
        city: json['city'] as String?,
        country: json['country'] as String?,
        roles: (json['roles'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
        status: json['status'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
        avatarUrl: json['avatarUrl'] as String?,
        statistics: json['statistics'] == null
            ? null
            : PlayerStatisticsDto.fromJson(
                json['statistics'] as Map<String, dynamic>),
      );
}

class PlayerStatisticsDto {
  final int totalFinishedTournaments;
  final int totalMatches;
  final int wins;
  final int losses;
  final int firstPlaceCount;
  final int secondPlaceCount;
  final int thirdPlaceCount;

  const PlayerStatisticsDto({
    this.totalFinishedTournaments = 0,
    this.totalMatches = 0,
    this.wins = 0,
    this.losses = 0,
    this.firstPlaceCount = 0,
    this.secondPlaceCount = 0,
    this.thirdPlaceCount = 0,
  });

  factory PlayerStatisticsDto.fromJson(Map<String, dynamic> json) =>
      PlayerStatisticsDto(
        totalFinishedTournaments:
            (json['totalFinishedTournaments'] as num?)?.toInt() ?? 0,
        totalMatches: (json['totalMatches'] as num?)?.toInt() ?? 0,
        wins: (json['wins'] as num?)?.toInt() ?? 0,
        losses: (json['losses'] as num?)?.toInt() ?? 0,
        firstPlaceCount: (json['firstPlaceCount'] as num?)?.toInt() ?? 0,
        secondPlaceCount: (json['secondPlaceCount'] as num?)?.toInt() ?? 0,
        thirdPlaceCount: (json['thirdPlaceCount'] as num?)?.toInt() ?? 0,
      );
}
