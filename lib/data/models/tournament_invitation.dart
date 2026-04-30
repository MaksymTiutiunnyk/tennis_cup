import 'package:equatable/equatable.dart';
import 'package:tennis_cup/data/models/tournament.dart';

enum InvitationStatus { pending, accepted, declined }

class TournamentInvitation extends Equatable {
  final String id;
  final Tournament tournament;
  final int playerNumber;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime deadline;
  final InvitationStatus status;

  const TournamentInvitation({
    required this.id,
    required this.tournament,
    required this.playerNumber,
    required this.startTime,
    required this.endTime,
    required this.deadline,
    this.status = InvitationStatus.pending,
  });

  TournamentInvitation copyWith({InvitationStatus? status}) {
    return TournamentInvitation(
      id: id,
      tournament: tournament,
      playerNumber: playerNumber,
      startTime: startTime,
      endTime: endTime,
      deadline: deadline,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tournament,
        playerNumber,
        startTime,
        endTime,
        deadline,
        status,
      ];
}
