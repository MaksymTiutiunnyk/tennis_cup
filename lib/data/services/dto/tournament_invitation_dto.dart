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
