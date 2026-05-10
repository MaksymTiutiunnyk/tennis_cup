import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/player.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

// ignore: constant_identifier_names
enum Time { Morning, Evening, Day, Midnight, Night }

class TournamentParticipant {
  final int playerId;
  final String status;

  const TournamentParticipant({required this.playerId, required this.status});
}

class TournamentRefereeInvitation {
  final int refereeId;
  final String status;

  const TournamentRefereeInvitation(
      {required this.refereeId, required this.status});
}

class Tournament extends Equatable {
  final String tournamentId;
  final String name;
  final String gender;
  final String status;
  final List<Player> players;
  final List<Match>? matches;
  final DateTime date;
  final Arena arena;
  final Time time;
  final List<int> points;
  final List<int> places;
  final bool isFinished;
  final int? refereeId;
  final int? setsToWin;
  final int? requiredPlayersCount;
  final List<TournamentParticipant> participantInvitations;
  final List<TournamentRefereeInvitation> refereeInvitations;

  const Tournament({
    required this.tournamentId,
    required this.players,
    required this.date,
    required this.arena,
    required this.time,
    required this.points,
    required this.places,
    this.name = '',
    this.gender = '',
    this.status = 'PENDING',
    this.isFinished = false,
    this.matches,
    this.refereeId,
    this.setsToWin,
    this.requiredPlayersCount,
    this.participantInvitations = const [],
    this.refereeInvitations = const [],
  });

  @override
  List<Object?> get props => [
        tournamentId,
        name,
        gender,
        status,
        players,
        matches,
        date,
        arena,
        time,
        points,
        places,
        isFinished,
        refereeId,
        participantInvitations,
        refereeInvitations,
      ];
}
