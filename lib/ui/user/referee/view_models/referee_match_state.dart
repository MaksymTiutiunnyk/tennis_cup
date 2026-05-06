part of 'referee_match_cubit.dart';

enum MatchCard { yellow, red1, red2, whiteTimeout }

typedef CardState = Set<MatchCard>;

sealed class RefereeMatchState {}

class RefereeMatchLoading extends RefereeMatchState {}

class RefereeMatchError extends RefereeMatchState {
  final String message;
  RefereeMatchError(this.message);
}

class RefereeMatchReady extends RefereeMatchState {
  final MatchDto match;
  final Player bluePlayer;
  final Player redPlayer;
  final int? firstServerPlayerId;
  final CardState blueIssuedCards;
  final CardState redIssuedCards;
  final List<({int blue, int red})> scoreUndoStack;
  // Transient message shown as SnackBar; cleared on the next meaningful action.
  final String? notification;

  RefereeMatchReady({
    required this.match,
    required this.bluePlayer,
    required this.redPlayer,
    required this.blueIssuedCards,
    required this.redIssuedCards,
    required this.scoreUndoStack,
    this.firstServerPlayerId,
    this.notification,
  });

  bool isDisplaySwapped(int setNumber) => setNumber.isEven;

  int? currentServerId() {
    if (firstServerPlayerId == null) return null;
    final activeSet =
        match.sets.where((s) => s.status == 'ACTIVE').firstOrNull;
    if (activeSet == null) return null;
    final setIndex = activeSet.number - 1;
    final blueId = int.tryParse(bluePlayer.playerId) ?? -1;
    final redId = int.tryParse(redPlayer.playerId) ?? -1;
    final otherServerId = firstServerPlayerId == blueId ? redId : blueId;
    final gameFirstServer =
        (setIndex % 2 == 0) ? firstServerPlayerId! : otherServerId;
    final total = activeSet.bluePlayerScore + activeSet.redPlayerScore;
    final isDeuce =
        activeSet.bluePlayerScore >= 10 && activeSet.redPlayerScore >= 10;
    final pointsPerServe = isDeuce ? 1 : 2;
    final changes = total ~/ pointsPerServe;
    return (changes % 2 == 0) ? gameFirstServer : otherServerId;
  }

  RefereeMatchReady copyWith({
    MatchDto? match,
    int? firstServerPlayerId,
    CardState? blueIssuedCards,
    CardState? redIssuedCards,
    List<({int blue, int red})>? scoreUndoStack,
    String? notification,
  }) =>
      RefereeMatchReady(
        match: match ?? this.match,
        bluePlayer: bluePlayer,
        redPlayer: redPlayer,
        firstServerPlayerId: firstServerPlayerId ?? this.firstServerPlayerId,
        blueIssuedCards: blueIssuedCards ?? this.blueIssuedCards,
        redIssuedCards: redIssuedCards ?? this.redIssuedCards,
        scoreUndoStack: scoreUndoStack ?? this.scoreUndoStack,
        // notification defaults to null so it clears on every normal action
        notification: notification,
      );
}
