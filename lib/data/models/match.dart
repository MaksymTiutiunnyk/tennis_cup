import 'package:equatable/equatable.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament_time.dart';
import 'package:tennis_cup/data/models/user.dart';

enum MatchStatus { pending, active, finished, technicalDefeat }

enum SetStatus { pending, active, finished, technicalDefeat }

class MatchSet extends Equatable {
  final int id;
  final int matchId;
  final int number;
  final int blueScore;
  final int redScore;
  final SetStatus status;
  final int? winnerId;

  const MatchSet({
    required this.id,
    required this.matchId,
    required this.number,
    required this.blueScore,
    required this.redScore,
    this.status = SetStatus.pending,
    this.winnerId,
  });

  @override
  List<Object?> get props =>
      [id, matchId, number, blueScore, redScore, status, winnerId];
}

class MatchCard extends Equatable {
  final int id;
  final int matchId;
  final int playerId;
  final String cardType;
  final DateTime issuedAt;
  final int? setNumber;

  const MatchCard({
    required this.id,
    required this.matchId,
    required this.playerId,
    required this.cardType,
    required this.issuedAt,
    this.setNumber,
  });

  @override
  List<Object?> get props =>
      [id, matchId, playerId, cardType, issuedAt, setNumber];
}

class Match extends Equatable {
  final int id;
  final User bluePlayer;
  final User redPlayer;
  final String arenaId;
  final String arenaName;
  final ArenaColor arenaColor;
  final int tournamentId;
  final String tournamentName;
  final String tournamentGender;
  final Time tournamentTime;
  final DateTime scheduledStart;
  final DateTime? scheduledEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final MatchStatus status;
  final int setsToWin;
  final int? refereeId;
  final int? firstServerId;
  final int? winnerId;
  final List<MatchSet> sets;
  final List<MatchCard> cards;

  const Match({
    required this.id,
    required this.bluePlayer,
    required this.redPlayer,
    required this.scheduledStart,
    this.arenaId = '',
    this.arenaName = '',
    this.arenaColor = ArenaColor.grey,
    this.tournamentId = 0,
    this.tournamentName = '',
    this.tournamentGender = '',
    this.tournamentTime = Time.Morning,
    this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    this.status = MatchStatus.pending,
    this.setsToWin = 0,
    this.refereeId,
    this.firstServerId,
    this.winnerId,
    this.sets = const [],
    this.cards = const [],
  });

  bool get isTechnicalDefeat => status == MatchStatus.technicalDefeat;
  List<int> get blueSetScores => sets.map((s) => s.blueScore).toList();
  List<int> get redSetScores => sets.map((s) => s.redScore).toList();
  int get blueScore =>
      sets.where((s) => s.winnerId == bluePlayer.id).length;
  int get redScore =>
      sets.where((s) => s.winnerId == redPlayer.id).length;

  @override
  List<Object?> get props => [
        id,
        bluePlayer,
        redPlayer,
        arenaId,
        arenaName,
        arenaColor,
        tournamentId,
        tournamentName,
        tournamentGender,
        tournamentTime,
        scheduledStart,
        scheduledEnd,
        actualStart,
        actualEnd,
        status,
        setsToWin,
        refereeId,
        firstServerId,
        winnerId,
        sets,
        cards,
      ];
}
