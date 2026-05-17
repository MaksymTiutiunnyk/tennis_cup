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

class TournamentParticipantDto {
  final int userId;
  final String role;
  final String invitationStatus;
  final int? place;

  const TournamentParticipantDto({
    required this.userId,
    required this.role,
    required this.invitationStatus,
    this.place,
  });

  factory TournamentParticipantDto.fromJson(Map<String, dynamic> json) =>
      TournamentParticipantDto(
        userId: (json['userId'] as num).toInt(),
        role: json['role'] as String? ?? 'PLAYER',
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
  final int? refereeId;
  final int requiredPlayersCount;
  final int setsToWin;
  final int matchDurationMinutes;
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
    required this.requiredPlayersCount,
    required this.setsToWin,
    required this.matchDurationMinutes,
    required this.participants,
    this.refereeId,
  });

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
      );
}

class MyInvitationDto {
  final int invitationId;
  final int tournamentId;
  final String tournamentName;
  final String startTime;
  final String role;
  final String status;
  final String createdAt;

  const MyInvitationDto({
    required this.invitationId,
    required this.tournamentId,
    required this.tournamentName,
    required this.startTime,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  factory MyInvitationDto.fromJson(Map<String, dynamic> json) =>
      MyInvitationDto(
        invitationId: (json['invitationId'] as num).toInt(),
        tournamentId: (json['tournamentId'] as num).toInt(),
        tournamentName: json['tournamentName'] as String? ?? '',
        startTime: json['startTime'] as String? ?? '',
        role: json['role'] as String? ?? 'PLAYER',
        status: json['status'] as String? ?? 'PENDING',
        createdAt: json['createdAt'] as String? ?? '',
      );
}
