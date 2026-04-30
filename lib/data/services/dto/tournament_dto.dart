import 'package:tennis_cup/data/models/tournament.dart';

Time timeFromString(String value) {
  switch (value.toUpperCase()) {
    case 'MORNING':
      return Time.Morning;
    case 'DAY':
      return Time.Day;
    case 'EVENING':
      return Time.Evening;
    case 'NIGHT':
      return Time.Night;
    default:
      return Time.Morning;
  }
}

class TournamentDto {
  final int id;
  final String name;
  final String type;
  final String status;
  final String startTime;
  final int arenaId;
  final String gender;
  final List<int> playerIds;

  const TournamentDto({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.startTime,
    required this.arenaId,
    required this.gender,
    required this.playerIds,
  });

  factory TournamentDto.fromJson(Map<String, dynamic> json) => TournamentDto(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        type: json['type'] as String? ?? '',
        status: json['status'] as String? ?? '',
        startTime: json['startTime'] as String? ?? '',
        arenaId: (json['arenaId'] as num?)?.toInt() ?? 0,
        gender: json['gender'] as String? ?? '',
        playerIds: (json['playerIds'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            [],
      );
}
