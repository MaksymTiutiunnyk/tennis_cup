import 'package:tennis_cup/data/models/tournament.dart';

class CreateUpdateTournamentRequestDto {
  final String name;
  final String type;
  final String gender;
  final String startTime;
  final int arenaId;
  final List<int> refereeIds;
  final int matchDurationMinutes;
  final int requiredPlayersCount;
  final int setsToWin;
  final List<int> playerIds;

  const CreateUpdateTournamentRequestDto({
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

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'gender': gender,
        'startTime': startTime,
        'arenaId': arenaId,
        'refereeIds': refereeIds,
        'matchDurationMinutes': matchDurationMinutes,
        'requiredPlayersCount': requiredPlayersCount,
        'setsToWin': setsToWin,
        'playerIds': playerIds,
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
        playerId: (json['userId'] as num).toInt(),
        invitationStatus: json['invitationStatus'] as String? ?? 'PENDING',
        place: (json['place'] as num?)?.toInt(),
      );
}

class TournamentRefereeInvitationDto {
  final int id;
  final int refereeId;
  final String status;

  const TournamentRefereeInvitationDto({
    required this.id,
    required this.refereeId,
    required this.status,
  });

  factory TournamentRefereeInvitationDto.fromJson(Map<String, dynamic> json) =>
      TournamentRefereeInvitationDto(
        id: (json['id'] as num).toInt(),
        refereeId: (json['refereeId'] as num).toInt(),
        status: json['status'] as String? ?? 'PENDING',
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
  final int? refereeId;
  final int requiredPlayersCount;
  final int setsToWin;
  final int matchDurationMinutes;
  final List<TournamentParticipantDto> participants;
  final List<TournamentRefereeInvitationDto> refereeInvitations;

  const TournamentDto({
    required this.id,
    required this.name,
    required this.type,
    required this.format,
    required this.status,
    required this.startTime,
    required this.arenaId,
    required this.gender,
    required this.requiredPlayersCount,
    required this.setsToWin,
    required this.matchDurationMinutes,
    required this.participants,
    required this.refereeInvitations,
    this.refereeId,
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
        refereeId: (json['refereeId'] as num?)?.toInt(),
        requiredPlayersCount:
            (json['requiredPlayersCount'] as num?)?.toInt() ?? 0,
        setsToWin: (json['setsToWin'] as num?)?.toInt() ?? 1,
        matchDurationMinutes:
            (json['matchDurationMinutes'] as num?)?.toInt() ?? 30,
        participants: (json['participants'] as List<dynamic>?)
                ?.map((e) => TournamentParticipantDto.fromJson(
                    e as Map<String, dynamic>))
                .toList() ??
            [],
        refereeInvitations: (json['refereeInvitations'] as List<dynamic>?)
                ?.map((e) => TournamentRefereeInvitationDto.fromJson(
                    e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
