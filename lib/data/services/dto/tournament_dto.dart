import 'package:tennis_cup/data/models/tournament.dart';

class CreateTournamentRequestDto {
  final String name;
  final String type;
  final String gender;
  final String startTime;
  final int arenaId;
  final int refereeId;
  final int matchDurationMinutes;
  final List<int>? playerIds;

  const CreateTournamentRequestDto({
    required this.name,
    required this.type,
    required this.gender,
    required this.startTime,
    required this.arenaId,
    required this.refereeId,
    required this.matchDurationMinutes,
    this.playerIds,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'gender': gender,
        'startTime': startTime,
        'arenaId': arenaId,
        'refereeId': refereeId,
        'matchDurationMinutes': matchDurationMinutes,
        if (playerIds != null) 'playerIds': playerIds,
      };
}

class UpdateTournamentRequestDto {
  final String? name;
  final String? type;
  final String? gender;
  final String? startTime;
  final int? arenaId;
  final int? refereeId;
  final List<int>? playerIds;

  const UpdateTournamentRequestDto({
    this.name,
    this.type,
    this.gender,
    this.startTime,
    this.arenaId,
    this.refereeId,
    this.playerIds,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (type != null) 'type': type,
        if (gender != null) 'gender': gender,
        if (startTime != null) 'startTime': startTime,
        if (arenaId != null) 'arenaId': arenaId,
        if (refereeId != null) 'refereeId': refereeId,
        if (playerIds != null) 'playerIds': playerIds,
      };
}

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

class TournamentParticipantDto {
  final int playerId;
  final String invitationStatus;
  final int? place;

  const TournamentParticipantDto({
    required this.playerId,
    required this.invitationStatus,
    this.place,
  });

  factory TournamentParticipantDto.fromJson(Map<String, dynamic> json) =>
      TournamentParticipantDto(
        playerId: (json['playerId'] as num).toInt(),
        invitationStatus: json['invitationStatus'] as String? ?? 'PENDING',
        place: (json['place'] as num?)?.toInt(),
      );
}

class TournamentDto {
  final int id;
  final String name;
  final String type;
  final String format;
  final String status;
  final String startTime;
  final int arenaId;
  final String gender;
  final int refereeId;
  final List<TournamentParticipantDto> participants;

  const TournamentDto({
    required this.id,
    required this.name,
    required this.type,
    required this.format,
    required this.status,
    required this.startTime,
    required this.arenaId,
    required this.gender,
    required this.refereeId,
    required this.participants,
  });

  List<int> get playerIds => participants.map((p) => p.playerId).toList();

  factory TournamentDto.fromJson(Map<String, dynamic> json) => TournamentDto(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        type: json['type'] as String? ?? '',
        format: json['format'] as String? ?? 'ROUND_ROBIN',
        status: json['status'] as String? ?? '',
        startTime: json['startTime'] as String? ?? '',
        arenaId: (json['arenaId'] as num?)?.toInt() ?? 0,
        gender: json['gender'] as String? ?? '',
        refereeId: (json['refereeId'] as num?)?.toInt() ?? 0,
        participants: (json['participants'] as List<dynamic>?)
                ?.map((e) => TournamentParticipantDto.fromJson(
                    e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
