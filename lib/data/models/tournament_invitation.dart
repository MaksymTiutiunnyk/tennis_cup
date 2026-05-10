import 'package:equatable/equatable.dart';
import 'package:tennis_cup/data/models/tournament.dart';

enum InvitationRole { player, referee }

enum InvitationStatus { pending, accepted, declined }

class TournamentInvitation extends Equatable {
  final String id;
  final String tournamentId;
  final Tournament tournament;
  final InvitationRole role;
  final InvitationStatus status;

  const TournamentInvitation({
    required this.id,
    required this.tournamentId,
    required this.tournament,
    required this.role,
    this.status = InvitationStatus.pending,
  });

  TournamentInvitation copyWith({InvitationStatus? status}) {
    return TournamentInvitation(
      id: id,
      tournamentId: tournamentId,
      tournament: tournament,
      role: role,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, tournamentId, tournament, role, status];
}
